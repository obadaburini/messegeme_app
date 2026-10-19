import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'screens/chat_screen.dart';
import 'screens/registeration_screen.dart';
import 'screens/signin_screen.dart';
import 'screens/welcome_screen.dart';
import 'services/chat_service.dart';
import 'widget/app_layout.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  const demo = bool.fromEnvironment('DEMO_MODE');
  if (demo) {
    runApp(MyApp(service: DemoChatService()));
    return;
  }
  try {
    if (kIsWeb) {
      const apiKey = String.fromEnvironment('FIREBASE_API_KEY');
      const appId = String.fromEnvironment('FIREBASE_APP_ID');
      const senderId = String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID');
      const projectId = String.fromEnvironment('FIREBASE_PROJECT_ID');
      if ([apiKey, appId, senderId, projectId].any((value) => value.isEmpty)) {
        throw StateError('Missing Firebase web configuration.');
      }
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: apiKey,
          appId: appId,
          messagingSenderId: senderId,
          projectId: projectId,
          authDomain: String.fromEnvironment('FIREBASE_AUTH_DOMAIN'),
        ),
      );
    } else {
      await Firebase.initializeApp();
    }
    runApp(MyApp(service: FirebaseChatService()));
  } catch (_) {
    // Configuration values and raw SDK exceptions must not appear in the UI/logs.
    runApp(const ConfigurationApp());
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.service});
  final ChatService service;

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'MessageMe',
    theme: appTheme,
    initialRoute: '/',
    routes: {
      '/': (_) => WelcomeScreen(service: service),
      '/signin': (_) => SignInScreen(service: service),
      '/register': (_) => RegistrationScreen(service: service),
      '/chat': (_) => ListenableBuilder(
        listenable: service,
        builder: (_, _) => service.signedIn
            ? ChatScreen(service: service)
            : SignInScreen(service: service),
      ),
    },
  );
}

final appTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: brandOrange,
    primary: brandOrange,
  ),
  scaffoldBackgroundColor: const Color(0xFFF8FAFC),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
  ),
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      minimumSize: const Size(double.infinity, 52),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    ),
  ),
);

class ConfigurationApp extends StatelessWidget {
  const ConfigurationApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: appTheme,
    home: const Scaffold(
      body: AppLayout(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.settings_outlined, size: 56, color: brandOrange),
              SizedBox(height: 24),
              Text(
                'Firebase setup required',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text(
                'Follow the Firebase setup instructions in README.md, then restart the app. '
                'For a local sample preview, run with --dart-define=DEMO_MODE=true.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
