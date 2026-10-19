import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class ChatMessage {
  const ChatMessage({required this.text, required this.isMe});
  final String text;
  final bool isMe;
}

abstract class ChatService extends ChangeNotifier {
  bool get isDemo => false;
  bool get signedIn;
  Future<void> authenticate(
    String email,
    String password, {
    required bool register,
  });
  Future<void> signOut();
  Stream<List<ChatMessage>> messages();
  Future<void> send(String text);
}

class FirebaseChatService extends ChatService {
  FirebaseChatService() {
    _subscription = FirebaseAuth.instance.authStateChanges().listen((_) {
      notifyListeners();
    });
  }

  late final StreamSubscription<User?> _subscription;
  @override
  bool get signedIn => FirebaseAuth.instance.currentUser != null;

  @override
  Future<void> authenticate(
    String email,
    String password, {
    required bool register,
  }) async {
    final auth = FirebaseAuth.instance;
    if (register) {
      await auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } else {
      await auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    }
    notifyListeners();
  }

  @override
  Future<void> signOut() => FirebaseAuth.instance.signOut();

  @override
  Stream<List<ChatMessage>> messages() {
    final email = FirebaseAuth.instance.currentUser?.email;
    return FirebaseFirestore.instance
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .limit(100)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.where((doc) => doc.data()['text'] is String).map(
            (doc) {
              final data = doc.data();
              return ChatMessage(
                text: data['text'] as String,
                isMe: data['sender'] == email,
              );
            },
          ).toList();
        });
  }

  @override
  Future<void> send(String text) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw StateError('Sign in before sending messages.');
    final value = validateMessage(text);
    await FirebaseFirestore.instance.collection('messages').add({
      'text': value,
      'sender': user.email,
      'senderId': user.uid,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

/// Explicit, local-only preview. Never initializes Firebase or stores credentials.
class DemoChatService extends ChatService {
  bool _signedIn = false;
  final _changes = StreamController<List<ChatMessage>>.broadcast();
  final _messages = <ChatMessage>[
    const ChatMessage(text: 'Perfect. See you there!', isMe: false),
    const ChatMessage(text: 'Yes! Let’s meet at 10 tomorrow.', isMe: true),
    const ChatMessage(
      text: 'Hi! Ready to catch up with the team?',
      isMe: false,
    ),
  ];

  @override
  bool get isDemo => true;
  @override
  bool get signedIn => _signedIn;
  @override
  Future<void> authenticate(
    String email,
    String password, {
    required bool register,
  }) async {
    _signedIn = true;
    notifyListeners();
  }

  @override
  Future<void> signOut() async {
    _signedIn = false;
    notifyListeners();
  }

  @override
  Stream<List<ChatMessage>> messages() async* {
    yield List.unmodifiable(_messages);
    yield* _changes.stream;
  }

  @override
  Future<void> send(String text) async {
    if (!_signedIn) throw StateError('Sign in before sending messages.');
    _messages.insert(0, ChatMessage(text: validateMessage(text), isMe: true));
    _changes.add(List.unmodifiable(_messages));
  }

  @override
  void dispose() {
    _changes.close();
    super.dispose();
  }
}

String validateMessage(String text) {
  final value = text.trim();
  if (value.isEmpty || value.length > 2000) {
    throw ArgumentError('Messages must contain 1–2000 characters.');
  }
  return value;
}

String? validateEmail(String? value) {
  if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value?.trim() ?? '')) {
    return 'Enter a valid email address.';
  }
  return null;
}

String? validatePassword(String? value, {required bool register}) {
  if (value == null || value.isEmpty) return 'Enter your password.';
  if (register && value.length < 6) return 'Use at least 6 characters.';
  return null;
}

String safeAuthError(Object error) {
  if (error is FirebaseAuthException) {
    return switch (error.code) {
      'network-request-failed' =>
        'Unable to connect. Check your internet and try again.',
      'too-many-requests' => 'Too many attempts. Please try again later.',
      'weak-password' => 'Use a stronger password with at least 6 characters.',
      'operation-not-allowed' =>
        'Email sign-in is not enabled. Contact the app administrator.',
      _ =>
        'Unable to sign in or create this account. Check your details and try again.',
    };
  }
  return 'Something went wrong. Please try again.';
}
