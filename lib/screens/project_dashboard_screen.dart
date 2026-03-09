// Removed broken import: razorpay_flutter


import 'package:flutter/material.dart';

class ProjectDashboardScreen extends StatelessWidget {
  const ProjectDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Project Dashboard')),
      body: ListView(
        children: [
          const Text('Progress: 50%'),
          ElevatedButton(
            onPressed: () {
              // Razorpay stub for payment
            },
            child: const Text('Make Payment'),
          ),
          // Invoice list, contract details, evidence gallery can be added here
        ],
      ),
    );
  }
}
