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
          ? FloatingActionButton.extended(
              backgroundColor: const Color(0xFFFF7A00),
              foregroundColor: Colors.black,
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PostJobScreen())),
              icon: const Icon(Icons.add),
              label: const Text('Kotha Pani'),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        backgroundColor: const Color(0xFF1A1A1A),
        indicatorColor: const Color(0xFFFF7A00),
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.list_alt_outlined), selectedIcon: Icon(Icons.list_alt), label: 'Na Panulu'),
          NavigationDestination(icon: Icon(Icons.receipt_long_outlined), selectedIcon: Icon(Icons.receipt_long), label: 'Payments'),
          NavigationDestination(icon: Icon(Icons.support_agent_outlined), selectedIcon: Icon(Icons.support_agent), label: 'Support'),
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
          title: const Text('Home / Na Panulu', style: TextStyle(color: Color(0xFFFF7A00), fontWeight: FontWeight.bold)),
          actions: [
            CircleAvatar(backgroundColor: const Color(0xFFFF7A00), child: const Icon(Icons.construction, color: Colors.black)),
            const SizedBox(width: 12),
          ],
        ),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text('Welcome Jayanth', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              ),
              const SizedBox(height: 20),
              const Text('Active Jobs', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              _JobCard(
                title: 'water leaks from ceiling',
                material: 'Without',
                status: 'Matched',
                time: '19 Feb, 06:44 PM',
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const UpiFeeScreen(jobId: 1, customerId: 1, proId: 2, party: 'customer'))),
              ),
              _JobCard(
                title: 'wall cleaning',
                material: 'Without',
                status: 'Created',
                time: '19 Feb, 03:09 PM',
                onTap: () {},
              ),
              _JobCard(
                title: 'sink water leak',
                material: 'Without',
                status: 'Created',
                time: '18 Feb, 06:38 PM',
                onTap: () {},
              ),
            ]),
          ),
        ),
      ],
    );
  }
}

class _JobCard extends StatelessWidget {
  final String title, material, status, time;
  final VoidCallback onTap;
  const _JobCard({required this.title, required this.material, required this.status, required this.time, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: const Color(0xFFFFF8F0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.image_not_supported_outlined, color: Colors.black45),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text('Material: $material', style: TextStyle(color: Colors.grey.shade700)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFFF7A00)),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(status, style: const TextStyle(color: Color(0xFFFF7A00), fontSize: 12)),
                    ),
                    const SizedBox(height: 6),
                    Text(time, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
