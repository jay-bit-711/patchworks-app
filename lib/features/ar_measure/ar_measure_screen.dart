import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/ar_service.dart';

class ARMeasureScreen extends StatefulWidget {
  const ARMeasureScreen({super.key});

  @override
  State<ARMeasureScreen> createState() => _ARMeasureScreenState();
}

class _ARMeasureScreenState extends State<ARMeasureScreen> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final arService = context.read<ARService>();

    return Scaffold(
      appBar: AppBar(title: const Text('AR Measure')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('AR module is pre-provisioned — plug in ARCore/ARKit models here without refactoring core app.'),
            const SizedBox(height: 16),
            const Text('// TODO: add arcore_flutter_plugin / arkit_plugin here'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loading
                  ? null
                  : () async {
                      setState(() => _loading = true);
                      try {
                        await arService.submitMeasurement(
                          projectId: 'demo-project-id',
                          pointCloud: {'points': []},
                          dimensions: {'length_ft': 20, 'width_ft': 30},
                        );
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('AR payload sent to backend')),
                        );
                      } catch (e) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
                      } finally {
                        if (mounted) setState(() => _loading = false);
                      }
                    },
              child: _loading ? const CircularProgressIndicator() : const Text('Send Mock AR Data'),
            ),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/surface-detection'),
              child: const Text('Open Surface Detection'),
            )
          ],
        ),
      ),
    );
  }
}
