import 'package:flutter/material.dart';
import '../services/chat_service.dart';
import 'auth_screen.dart';

class RegistrationScreen extends StatelessWidget {
  const RegistrationScreen({super.key, required this.service});
  final ChatService service;
  @override
  Widget build(BuildContext context) =>
      AuthScreen(service: service, register: true);
}
