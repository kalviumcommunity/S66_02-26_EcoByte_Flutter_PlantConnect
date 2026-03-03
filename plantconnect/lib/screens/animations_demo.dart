import 'package:flutter/material.dart';
import 'rotate_logo_demo.dart';

class AnimationsDemoScreen extends StatefulWidget {
  const AnimationsDemoScreen({super.key});

  @override
  State<AnimationsDemoScreen> createState() => _AnimationsDemoScreenState();
}

class _AnimationsDemoScreenState extends State<AnimationsDemoScreen> {
  bool _toggled = false;

  void _toggle() {
    setState(() {
      _toggled = !_toggled;
    });
  }

  void _openRotation() {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 700),
        pageBuilder: (context, animation, secondaryAnimation) =>
            const RotateLogoDemo(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position:
                Tween<Offset>(
                  begin: const Offset(1.0, 0.0),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(parent: animation, curve: Curves.easeInOut),
                ),
            child: child,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Animations Demo')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Text('Implicit animation (AnimatedContainer + Opacity)'),
              const SizedBox(height: 16),
              AnimatedContainer(
                width: _toggled ? 200 : 100,
                height: _toggled ? 100 : 200,
                color: _toggled ? Colors.teal : Colors.orange,
                duration: const Duration(seconds: 1),
                curve: Curves.easeInOut,
                child: Center(
                  child: Text(
                    'Tap Me!',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              AnimatedOpacity(
                opacity: _toggled ? 1.0 : 0.3,
                duration: const Duration(seconds: 1),
                child: Image.asset('assets/images/logo.png', width: 120),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _toggle,
                child: const Text('Toggle animation'),
              ),
              const Divider(height: 48),
              ElevatedButton(
                onPressed: _openRotation,
                child: const Text('Go to rotation demo (page transition)'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
