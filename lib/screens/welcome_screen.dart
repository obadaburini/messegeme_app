import 'package:flutter/material.dart';
import 'package:messegeme_app/widget/my_button.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );

    _animation =
        CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.orange.shade200,
                  Colors.orange.shade800,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  crossAxisAlignment:
                      CrossAxisAlignment.stretch,
                  children: [
                    Column(
                      children: [
                        Hero(
                          tag: 'logo',
                          child: SizedBox(
                            height: 140,
                            child: Image.asset(
                                'assets/images/logo.png'),
                          ),
                        ),
                        SizedBox(height: 20),
                        FadeTransition(
                          opacity: _animation,
                          child: Text(
                            'MessageMe',
                            style: TextStyle(
                              fontSize: 42,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 60),

                    MyButton(
                      color: Colors.white,
                      title: 'Sign In',
                      onPressed: () {
                        Navigator.pushNamed(
                            context, '/signin');
                      },
                    ),

                    SizedBox(height: 15),

                    MyButton(
                      color: Colors.black87,
                      title: 'Register',
                      onPressed: () {
                        Navigator.pushNamed(
                            context, '/register');
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
