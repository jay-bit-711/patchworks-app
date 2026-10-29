import 'package:flutter/material.dart';
import 'upi_fee_screen.dart';
import 'rating_screen.dart';

class MyJobsScreen extends StatelessWidget {
  const MyJobsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(title: const Text('All My Jobs'), backgroundColor: const Color(0xFF121212), foregroundColor: const Color(0xFFFF7A00)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _JobTile('Plumbing - Water in', 'Matched', 'Pay ₹150 to unlock', () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const UpiFeeScreen(jobId: 1, customerId: 1, proId: 2, party: 'customer')));
          }),
          _JobTile('Electrical points', 'Open', 'Waiting for pros', () {}),
          _JobTile('Flooring repair', 'Done', 'Rate the pro', () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const RatingScreen(jobTitle: 'Flooring repair')));
          }),
        ],
      ),
    );
  }
}

class _JobTile extends StatelessWidget {
  final String title, status, subtitle;
  final VoidCallback onTap;
  const _JobTile(this.title, this.status, this.subtitle, this.onTap);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF1E1E1E),
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(title, style: const TextStyle(color: Colors.white)),
        subtitle: Text('$status • $subtitle', style: const TextStyle(color: Colors.white54)),
        trailing: const Icon(Icons.chevron_right, color: Colors.white38),
        onTap: onTap,
      ),
    );
  }
}
