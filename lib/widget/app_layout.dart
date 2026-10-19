import 'package:flutter/material.dart';

const brandOrange = Color(0xFFB94709);

class AppLayout extends StatelessWidget {
  const AppLayout({super.key, required this.child, this.maxWidth = 480});
  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) => Container(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFFFF5EB), Color(0xFFF8FAFC)],
      ),
    ),
    child: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: child,
        ),
      ),
    ),
  );
}

class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = 88});
  final double size;
  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      boxShadow: const [
        BoxShadow(
          color: Color(0x12B94709),
          blurRadius: 32,
          offset: Offset(0, 12),
        ),
      ],
    ),
    padding: const EdgeInsets.all(14),
    child: Image.asset(
      'assets/images/logo.png',
      semanticLabel: 'MessageMe logo',
    ),
  );
}

class DemoNotice extends StatelessWidget {
  const DemoNotice({super.key});
  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.all(12),
    child: Text(
      'DEMO • Sample data only. Nothing is sent to Firebase.',
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 12, color: Color(0xFF6B4C30)),
    ),
  );
}
