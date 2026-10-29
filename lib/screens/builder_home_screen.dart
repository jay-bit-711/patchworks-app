import 'package:flutter/material.dart';
import 'portfolio_screen.dart';
import 'upi_fee_screen.dart';
import 'builder_job_screen.dart';

class BuilderHomeScreen extends StatefulWidget {
  const BuilderHomeScreen({super.key});

  @override
  State<BuilderHomeScreen> createState() => _BuilderHomeScreenState();
}

class _BuilderHomeScreenState extends State<BuilderHomeScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      _ProHomeTab(),
      const PortfolioScreen(),
      const Center(child: Text('My Active Jobs', style: TextStyle(color: Colors.white70))),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: pages[_index],
      bottomNavigationBar: NavigationBar(
        backgroundColor: const Color(0xFF1A1A1A),
        indicatorColor: const Color(0xFFFF7A00),
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Jobs'),
          NavigationDestination(icon: Icon(Icons.person_outline), label: 'Portfolio'),
          NavigationDestination(icon: Icon(Icons.work_outline), label: 'Active'),
        ],
      ),
    );
  }
}

class _ProHomeTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          floating: true,
          backgroundColor: const Color(0xFF121212),
          title: const Text('Pro / Mestri', style: TextStyle(color: Color(0xFFFF7A00), fontWeight: FontWeight.bold)),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              const Text('Available Jobs', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              _ProJobCard(
                title: 'water leaks from ceiling',
                location: 'Patancheru',
                material: 'Without',
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const UpiFeeScreen(jobId: 1, customerId: 1, proId: 2, party: 'pro'))),
              ),
              _ProJobCard(
                title: 'wall cleaning',
                location: 'Sangareddy',
                material: 'Without',
                onTap: () {},
              ),
              const SizedBox(height: 20),
              const Text('In Progress', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              _ProJobCard(
                title: 'Flooring repair',
                location: 'Returu',
                material: 'Without',
                status: 'Upload After',
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BuilderJobScreen(jobTitle: 'Flooring repair'))),
              ),
            ]),
          ),
        ),
      ],
    );
  }
}

class _ProJobCard extends StatelessWidget {
  final String title, location, material;
  final String status;
  final VoidCallback onTap;
  const _ProJobCard({required this.title, required this.location, required this.material, this.status = 'New', required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: const Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        subtitle: Text('$location • Material: $material • $status', style: const TextStyle(color: Colors.white54)),
        trailing: const Icon(Icons.chevron_right, color: Color(0xFFFF7A00)),
        onTap: onTap,
      ),
    );
  }
}
