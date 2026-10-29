import 'package:flutter/material.dart';
import 'portfolio_screen.dart';
import 'upi_fee_screen.dart';
import 'builder_job_screen.dart';

class BuilderHomeScreen extends StatelessWidget {
  const BuilderHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('Pro Home'),
        backgroundColor: const Color(0xFF121212),
        foregroundColor: const Color(0xFFFF7A00),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            tileColor: const Color(0xFF1E1E1E),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            leading: const Icon(Icons.person_outline, color: Color(0xFFFF7A00)),
            title: const Text('Update Portfolio', style: TextStyle(color: Colors.white)),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PortfolioScreen())),
          ),
          const SizedBox(height: 16),
          const Text('Available Jobs', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Card(
            color: const Color(0xFF1E1E1E),
            child: ListTile(
              title: const Text('Plumbing - Water in', style: TextStyle(color: Colors.white)),
              subtitle: const Text('Patancheru • Pay ₹150 to unlock', style: TextStyle(color: Colors.white54)),
              trailing: const Icon(Icons.chevron_right, color: Colors.white38),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const UpiFeeScreen(jobId: 1, customerId: 1, proId: 2, party: 'pro'))),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            color: const Color(0xFF1E1E1E),
            child: ListTile(
              title: const Text('Flooring - In progress', style: TextStyle(color: Colors.white)),
              subtitle: const Text('Upload after images', style: TextStyle(color: Colors.white54)),
              trailing: const Icon(Icons.chevron_right, color: Colors.white38),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BuilderJobScreen(jobTitle: 'Flooring'))),
            ),
          ),
        ],
      ),
    );
  }
}
