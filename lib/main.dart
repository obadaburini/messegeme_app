import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:messegeme_app/screens/chat_screen.dart';
import 'package:messegeme_app/screens/registeration_screen.dart';
import 'package:messegeme_app/screens/signin_screen.dart';
import 'package:messegeme_app/screens/welcome_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(); // بدون options

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MessageMe',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.orange,
        scaffoldBackgroundColor: Colors.grey[100],
        fontFamily: 'Roboto',
      ),

      /// أول شاشة تفتح
      initialRoute: '/',

      /// جميع مسارات التطبيق
      routes: {
        '/': (context) => const WelcomeScreen(),
        '/signin': (context) => const SignInScreen(),
        '/register': (context) => const RegistrationScreen(),
        '/chat': (context) => const ChatScreen(),
      },
    );
  }
}
