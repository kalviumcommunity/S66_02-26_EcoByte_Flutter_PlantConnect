import 'package:flutter/material.dart';

class ResponsiveDemo extends StatelessWidget {
  const ResponsiveDemo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(title: const Text('Responsive Demo')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Use LayoutBuilder to decide layout based on available width
          if (constraints.maxWidth < 600) {
            // Mobile layout
            return SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 24),
                  Container(
                    width: screenWidth * 0.9,
                    height: screenHeight * 0.18,
                    color: Colors.tealAccent,
                    child: const Center(child: Text('Mobile View', style: TextStyle(fontSize: 18))),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Screen: ${screenWidth.toStringAsFixed(0)} x ${screenHeight.toStringAsFixed(0)} (Mobile)',
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          }

          // Tablet / Desktop layout
          return Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 300,
                  height: 220,
                  color: Colors.orangeAccent,
                  child: const Center(child: Text('Left Panel', style: TextStyle(fontSize: 18))),
                ),
                const SizedBox(width: 24),
                Container(
                  width: 300,
                  height: 220,
                  color: Colors.tealAccent,
                  child: Center(
                    child: Text(
                      'Tablet/Desktop\n${constraints.maxWidth.toStringAsFixed(0)} px wide',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
