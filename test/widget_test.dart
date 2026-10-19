import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:messegeme_app/main.dart';
import 'package:messegeme_app/services/chat_service.dart';

class FailingService extends DemoChatService {
  String? suppliedPassword;
  int sends = 0;
  @override
  Future<void> authenticate(
    String email,
    String password, {
    required bool register,
  }) async {
    suppliedPassword = password;
    throw FirebaseAuthException(code: 'invalid-credential');
  }

  @override
  Future<void> send(String text) async {
    sends++;
    throw StateError('Deliberate test failure');
  }
}

void main() {
  test(
    'email/password validation preserves significant password whitespace',
    () {
      expect(validateEmail('bad'), isNotNull);
      expect(validateEmail(' demo@example.com '), isNull);
      expect(validatePassword('', register: false), isNotNull);
      expect(validatePassword('short', register: true), isNotNull);
      expect(validatePassword(' pass word ', register: true), isNull);
    },
  );

  test('message validation rejects blank and oversized messages', () {
    expect(() => validateMessage('  '), throwsArgumentError);
    expect(() => validateMessage('x' * 2001), throwsArgumentError);
    expect(validateMessage(' hello '), 'hello');
  });

  test(
    'demo session and messages stay local and enforce authentication',
    () async {
      final service = DemoChatService();
      addTearDown(service.dispose);
      expect(service.signedIn, isFalse);
      await expectLater(service.send('hello'), throwsStateError);
      await service.authenticate(
        'demo@example.com',
        'not-stored',
        register: true,
      );
      expect(service.signedIn, isTrue);
      await service.send(' New message ');
      final messages = await service.messages().first;
      expect(messages.first.text, 'New message');
      expect(messages.first.isMe, isTrue);
      await service.signOut();
      expect(service.signedIn, isFalse);
    },
  );

  test('authentication error does not expose raw SDK details', () {
    final error = FirebaseAuthException(
      code: 'wrong-password',
      message: 'private-details',
    );
    expect(safeAuthError(error), isNot(contains('private-details')));
    expect(
      safeAuthError(error),
      safeAuthError(FirebaseAuthException(code: 'user-not-found')),
    );
    expect(
      safeAuthError(FirebaseAuthException(code: 'network-request-failed')),
      contains('internet'),
    );
  });

  testWidgets('welcome and registration validate inputs', (tester) async {
    final service = DemoChatService();
    addTearDown(service.dispose);
    await tester.pumpWidget(MyApp(service: service));
    expect(
      find.text('Good conversations.\nCloser connections.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Create an account'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Create account'));
    await tester.tap(find.text('Create account'));
    await tester.pumpAndSettle();
    expect(find.text('Enter a valid email address.'), findsOneWidget);
    expect(service.signedIn, isFalse);
  });

  testWidgets('auth failure retains form and does not trim password', (
    tester,
  ) async {
    final service = FailingService();
    addTearDown(service.dispose);
    await tester.pumpWidget(MyApp(service: service));
    await tester.tap(find.text('Sign In'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byType(TextFormField).at(0),
      'demo@example.com',
    );
    await tester.enterText(find.byType(TextFormField).at(1), ' password ');
    await tester.ensureVisible(find.text('Sign In'));
    await tester.tap(find.text('Sign In'));
    await tester.pumpAndSettle();
    expect(service.suppliedPassword, ' password ');
    expect(find.textContaining('Check your details'), findsOneWidget);
    expect(service.signedIn, isFalse);
  });

  testWidgets('sign in, send once, and sign out clear protected navigation', (
    tester,
  ) async {
    final service = DemoChatService();
    addTearDown(service.dispose);
    await tester.pumpWidget(MyApp(service: service));
    await tester.tap(find.text('Sign In'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byType(TextFormField).at(0),
      'demo@example.com',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'demo-password');
    await tester.ensureVisible(find.text('Sign In'));
    await tester.tap(find.text('Sign In'));
    await tester.pumpAndSettle();
    expect(find.text('Community chat'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'Hello from test');
    await tester.tap(find.byTooltip('Send message'));
    await tester.pumpAndSettle();
    expect(find.text('Hello from test'), findsOneWidget);
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      isEmpty,
    );
    await tester.tap(find.byTooltip('Send message'));
    await tester.pumpAndSettle();
    expect(
      (await service.messages().first)
          .where((m) => m.text == 'Hello from test')
          .length,
      1,
    );
    await tester.tap(find.byTooltip('Sign out'));
    await tester.pumpAndSettle();
    expect(service.signedIn, isFalse);
    expect(find.text('Community chat'), findsNothing);
    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    expect(navigator.canPop(), isFalse);
  });

  testWidgets('send failure keeps the draft visible', (tester) async {
    final failing = SendFailingService();
    addTearDown(failing.dispose);
    await failing.authenticate(
      'demo@example.com',
      'demo-password',
      register: false,
    );
    await tester.pumpWidget(MyApp(service: failing));
    await tester.tap(find.text('Open conversation'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Keep this draft');
    await tester.tap(find.byTooltip('Send message'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      'Keep this draft',
    );
    expect(find.textContaining('could not be sent'), findsOneWidget);
  });

  testWidgets('missing Firebase setup renders a helpful page', (tester) async {
    await tester.pumpWidget(const ConfigurationApp());
    expect(find.text('Firebase setup required'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('direct chat navigation requires authentication', (tester) async {
    final service = DemoChatService();
    addTearDown(service.dispose);
    await tester.pumpWidget(MyApp(service: service));
    tester.state<NavigatorState>(find.byType(Navigator)).pushNamed('/chat');
    await tester.pumpAndSettle();
    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Community chat'), findsNothing);
  });

  testWidgets('Firestore stream failures show an error instead of a spinner', (
    tester,
  ) async {
    final service = ReadFailingService();
    addTearDown(service.dispose);
    await service.authenticate(
      'demo@example.com',
      'sample-only',
      register: false,
    );
    await tester.pumpWidget(MyApp(service: service));
    await tester.tap(find.text('Open conversation'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Unable to load messages'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('welcome and registration fit a narrow viewport', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final service = DemoChatService();
    addTearDown(service.dispose);
    await tester.pumpWidget(MyApp(service: service));
    await tester.ensureVisible(find.text('Create an account'));
    await tester.tap(find.text('Create an account'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Create account'));
    await tester.tap(find.text('Create account'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(service.signedIn, isFalse);
  });
}

class SendFailingService extends DemoChatService {
  @override
  Future<void> send(String text) async => throw StateError('Test failure');
}

class ReadFailingService extends DemoChatService {
  @override
  Stream<List<ChatMessage>> messages() =>
      Stream.error(StateError('Test read failure'));
}
