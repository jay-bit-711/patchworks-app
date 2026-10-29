import 'package:flutter/material.dart';
import 'upi_fee_screen.dart';

class CustomerHomeScreen extends StatelessWidget {
  const CustomerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('My Jobs'),
        backgroundColor: const Color(0xFF121212),
        foregroundColor: const Color(0xFFFF7A00),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFFFF7A00),
        foregroundColor: Colors.black,
        onPressed: () {
          // TODO: real job post screen
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Post Job screen next')),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Post Job'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Active Jobs',
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _JobCard(
            title: 'Plumbing - Water in',
            location: 'Patancheru',
            status: 'Matched',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const UpiFeeScreen(
                    jobId: 1,
                    customerId: 1,
                    proId: 2,
                    party: 'customer',
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          _JobCard(
            title: 'Electrical - New points',
            location: 'Sangareddy',
            status: 'Open',
            onTap: () {},
          ),
          const SizedBox(height: 24),
          const Text(
            'Site visit fee ₹150 unlocks Call + GPS with the matched pro.',
            style: TextStyle(color: Colors.white54),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _JobCard extends StatelessWidget {
  final String title;
  final String location;
  final String status;
  final VoidCallback onTap;

  const _JobCard({
    required this.title,
    required this.location,
    required this.status,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        subtitle: Text('$location • $status', style: const TextStyle(color: Colors.white70)),
        trailing: status == 'Matched'
            ? const Icon(Icons.payments_outlined, color: Color(0xFFFF7A00))
            : const Icon(Icons.chevron_right, color: Colors.white38),
        onTap: onTap,
      ),
    );
  }
}
