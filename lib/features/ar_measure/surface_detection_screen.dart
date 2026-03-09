import 'package:flutter/material.dart';

class SurfaceDetectionScreen extends StatelessWidget {
  const SurfaceDetectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Surface Detection')),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          'AR module is pre-provisioned — plug in ARCore/ARKit models here without refactoring core app.\n\n'
          '// TODO: add arcore_flutter_plugin / arkit_plugin here',
        ),
      ),
    );
  }
}
