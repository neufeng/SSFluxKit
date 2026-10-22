import 'package:flutter/material.dart';
import 'package:ss_media/ss_media.dart';

/// Media demo route — players pause/dispose when this route is popped.
class SSMediaRoutePage extends StatelessWidget {
  const SSMediaRoutePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Media 演示')),
      body: const SSMediaDemoPage(),
    );
  }
}
