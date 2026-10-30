import 'package:flutter/material.dart';
import 'post_job_screen.dart';
import 'my_jobs_screen.dart';
import 'transactions_screen.dart';
import 'support_screen.dart';
import 'upi_fee_screen.dart';

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  int _index = 0;

  final _pages = const [
    _HomeTab(),
    MyJobsScreen(),
    TransactionsScreen(),
    SupportScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: _pages[_index],
      floatingActionButton: _index == 0
          ? FloatingActionButton(
              backgroundColor: const Color(0xFFFF7A00),
              foregroundColor: Colors.black,
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PostJobScreen())),
              child: const Icon(Icons.add, size: 32),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        backgroundColor: const Color(0xFF1A1A1A),
        indicatorColor: const Color(0xFFFF7A00),
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: ''),
          NavigationDestination(icon: Icon(Icons.assignment_outlined), selectedIcon: Icon(Icons.assignment), label: ''),
          NavigationDestination(icon: Icon(Icons.payments_outlined), selectedIcon: Icon(Icons.payments), label: ''),
          NavigationDestination(icon: Icon(Icons.support_agent_outlined), selectedIcon: Icon(Icons.support_agent), label: ''),
        ],
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          floating: true,
          backgroundColor: const Color(0xFF121212),
          title: const Text('Patchworks', style: TextStyle(color: Color(0xFFFF7A00), fontWeight: FontWeight.bold, fontSize: 24)),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              const Text('Your jobs', style: TextStyle(color: Colors.white70, fontSize: 16)),
              const SizedBox(height: 16),
              _VisualJobCard(
                icon: Icons.water_drop,
                title: 'Ceiling leak',
                category: 'Plumbing',
                status: 'Matched',
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const UpiFeeScreen(jobId: 1, customerId: 1, proId: 2, party: 'customer'))),
              ),
              _VisualJobCard(
                icon: Icons.format_paint,
                title: 'Wall painting',
                category: 'Painting',
                status: 'Open',
                onTap: () {},
              ),
              _VisualJobCard(
                icon: Icons.water_drop,
                title: 'Sink leak',
                category: 'Plumbing',
                status: 'Open',
                onTap: () {},
              ),
            ]),
          ),
        ),
      ],
    );
  }
}

class _VisualJobCard extends StatelessWidget {
  final IconData icon;
  final String title, category, status;
  final VoidCallback onTap;
  const _VisualJobCard({required this.icon, required this.title, required this.category, required this.status, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: const Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF7A00).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: const Color(0xFFFF7A00), size: 36),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text(category, style: const TextStyle(color: Color(0xFFFF7A00))),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: status == 'Matched' ? const Color(0xFFFF7A00) : Colors.white12,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(status, style: TextStyle(color: status == 'Matched' ? Colors.black : Colors.white70, fontSize: 12)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
