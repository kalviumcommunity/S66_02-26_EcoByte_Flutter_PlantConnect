import 'package:flutter/material.dart';

class RotateLogoDemo extends StatefulWidget {
  const RotateLogoDemo({super.key});

  @override
  _RotateLogoDemoState createState() => _RotateLogoDemoState();
}

class _RotateLogoDemoState extends State<RotateLogoDemo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rotation Animation Demo')),
      body: Center(
        child: RotationTransition(
          turns: _controller,
          child: Image.asset('assets/images/logo.png', width: 100),
        ),
      ),
    );
  }
}
