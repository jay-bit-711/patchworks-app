import 'package:flutter/material.dart';
import 'post_job_screen.dart';
import 'upi_fee_screen.dart';
import 'my_jobs_screen.dart';
import 'transactions_screen.dart';
import 'support_screen.dart';

class CustomerHomeScreen extends StatelessWidget {
  const CustomerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('Home'),
        backgroundColor: const Color(0xFF121212),
        foregroundColor: const Color(0xFFFF7A00),
        actions: [
          IconButton(icon: const Icon(Icons.support_agent), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SupportScreen()))),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFFFF7A00),
        foregroundColor: Colors.black,
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PostJobScreen())),
        icon: const Icon(Icons.add),
        label: const Text('Post Job'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Quick Actions', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(
            children: [
              _Action(icon: Icons.list_alt, label: 'My Jobs', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MyJobsScreen()))),
              const SizedBox(width: 12),
              _Action(icon: Icons.receipt_long, label: 'Transactions', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TransactionsScreen()))),
            ],
          ),
          const SizedBox(height: 24),
          const Text('Active Jobs', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _JobCard(
            title: 'Plumbing - Water in',
            location: 'Patancheru',
            status: 'Matched — Pay ₹150',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const UpiFeeScreen(jobId: 1, customerId: 1, proId: 2, party: 'customer'))),
          ),
          const SizedBox(height: 12),
          _JobCard(title: 'Electrical points', location: 'Sangareddy', status: 'Open', onTap: () {}),
        ],
      ),
    );
  }
}

class _Action extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _Action({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: const Color(0xFF1E1E1E), borderRadius: BorderRadius.circular(12)),
          child: Column(
            children: [
              Icon(icon, color: const Color(0xFFFF7A00), size: 32),
              const SizedBox(height: 8),
              Text(label, style: const TextStyle(color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }
}

class _JobCard extends StatelessWidget {
  final String title, location, status;
  final VoidCallback onTap;
  const _JobCard({required this.title, required this.location, required this.status, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF1E1E1E),
      child: ListTile(
        title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        subtitle: Text('$location • $status', style: const TextStyle(color: Colors.white70)),
        trailing: const Icon(Icons.chevron_right, color: Colors.white38),
        onTap: onTap,
      ),
    );
  }
}
