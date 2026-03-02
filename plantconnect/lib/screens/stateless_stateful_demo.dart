import 'package:flutter/material.dart';

class StatelessStatefulDemo extends StatelessWidget {
  const StatelessStatefulDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Stateless vs Stateful Demo')),
      body: const Center(child: DemoBody()),
    );
  }
}

// static header
class DemoHeader extends StatelessWidget {
  const DemoHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: Text(
        'Interactive Demo App',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }
}

// dynamic body
class DemoBody extends StatefulWidget {
  const DemoBody({super.key});

  @override
  State<DemoBody> createState() => _DemoBodyState();
}

class _DemoBodyState extends State<DemoBody> {
  bool _showDetails = false;
  int _counter = 0;

  void _toggleDetails() {
    setState(() {
      _showDetails = !_showDetails;
    });
  }

  void _increment() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const DemoHeader(),
        const SizedBox(height: 20),
        Text(
          'Counter: \\$_counter',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 10),
        ElevatedButton(onPressed: _increment, child: const Text('Increment')),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _toggleDetails,
          child: const Text('Toggle Details'),
        ),
        if (_showDetails) ...[
          const SizedBox(height: 10),
          const Text('Here are some hidden details!'),
        ],
      ],
    );
  }
}
