import 'package:flutter/material.dart';
import '../services/chat_service.dart';
import '../widget/app_layout.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key, required this.service});
  final ChatService service;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: AppLayout(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Center(child: BrandMark(size: 108)),
            const SizedBox(height: 32),
            const Text(
              'Good conversations.\nCloser connections.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 34,
                height: 1.15,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Welcome to MessageMe',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: brandOrange,
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'A simple place to share a thought and stay in touch with your community.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                height: 1.6,
                color: Color(0xFF475569),
              ),
            ),
            const SizedBox(height: 40),
            FilledButton(
              onPressed: () => Navigator.pushNamed(
                context,
                service.signedIn ? '/chat' : '/signin',
              ),
              child: Text(service.signedIn ? 'Open conversation' : 'Sign In'),
            ),
            const SizedBox(height: 14),
            OutlinedButton(
              onPressed: () => Navigator.pushNamed(context, '/register'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text('Create an account'),
            ),
            const SizedBox(height: 28),
            const Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Icon(Icons.forum_outlined, size: 18, color: brandOrange),
                SizedBox(width: 8),
                Text(
                  'One shared space. Real-time conversations.',
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
            if (service.isDemo) const DemoNotice(),
          ],
        ),
      ),
    ),
  );
}
