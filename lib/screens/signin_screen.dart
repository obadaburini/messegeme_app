import 'package:flutter/material.dart';
import '../services/chat_service.dart';
import 'auth_screen.dart';

class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key, required this.service});
  final ChatService service;
  @override
  Widget build(BuildContext context) =>
      AuthScreen(service: service, register: false);
}
