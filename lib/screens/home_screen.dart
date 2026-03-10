import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../models/job.dart';
import '../widgets/job_card.dart';
import 'agent_chat_screen.dart';
import 'project_dashboard_screen.dart';
import 'store_screen.dart';
import 'job_detail_screen.dart';
import 'job_create_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);
    final role = auth.userRole;
    final user = auth.currentUser;

    final List<Widget> pages = _getPagesForRole(role);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFF0D1117),
      drawer: _buildDrawer(context, auth, user),
      body: IndexedStack(
        index: _selectedIndex,
        children: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF161B22),
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.white30,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        items: _getNavItemsForRole(role),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, AuthService auth, dynamic user) {
    return Drawer(
      backgroundColor: const Color(0xFF161B22),
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: Color(0xFF0D1117)),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.orange,
              child: Icon(Icons.person, size: 40, color: Colors.white),
            ),
            accountName: Text(user?.displayName ?? 'User Name', 
              style: const TextStyle(fontWeight: FontWeight.bold)),
            accountEmail: Text(user?.email ?? 'email@example.com', 
              style: const TextStyle(color: Colors.white54)),
          ),
          ListTile(
            leading: const Icon(Icons.phone, color: Colors.orange),
            title: const Text('Phone', style: TextStyle(color: Colors.white70)),
            subtitle: const Text('+91 9441828722', style: TextStyle(color: Colors.white38)),
            trailing: const Icon(Icons.edit, size: 16, color: Colors.white24),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.location_on, color: Colors.orange),
            title: const Text('Address', style: TextStyle(color: Colors.white70)),
            subtitle: const Text('Patancheru, Hyderabad', style: TextStyle(color: Colors.white38)),
            trailing: const Icon(Icons.edit, size: 16, color: Colors.white24),
            onTap: () {},
          ),
          const Divider(color: Colors.white10),
          ListTile(
            leading: const Icon(Icons.history, color: Colors.orange),
            title: const Text('Payment History', style: TextStyle(color: Colors.white70)),
            onTap: () {},
          ),
          const Spacer(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.redAccent),
            title: const Text('Logout', style: TextStyle(color: Colors.redAccent)),
            onTap: () async {
              await auth.signOut();
              if (context.mounted) Navigator.pushReplacementNamed(context, '/login');
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  List<Widget> _getPagesForRole(String? role) {
    switch (role) {
      case 'homeowner':
        return [
          UnifiedJobsView(role: 'homeowner', title: 'My Jobs', scaffoldKey: _scaffoldKey),
          const StoreScreen(),
          const AgentChatScreen(agentId: 'customer_care'),
        ];
      case 'pro':
        return [
          UnifiedJobsView(role: 'pro', title: 'My Jobs', scaffoldKey: _scaffoldKey),
          const StoreScreen(),
          const ProfileStub(),
        ];
      case 'supervisor':
      default:
        return [
          const ProjectDashboardScreen(), // Still called Supervisor Dashboard in its own file
          const StoreScreen(),
          const AgentChatScreen(agentId: 'assignment_agent'),
        ];
    }
  }

  List<BottomNavigationBarItem> _getNavItemsForRole(String? role) {
    switch (role) {
      case 'homeowner':
        return const [
          BottomNavigationBarItem(icon: Icon(Icons.home_work), label: 'My Jobs'),
          BottomNavigationBarItem(icon: Icon(Icons.storefront), label: 'Store'),
          BottomNavigationBarItem(icon: Icon(Icons.support_agent), label: 'Support'),
        ];
      case 'pro':
        return const [
          BottomNavigationBarItem(icon: Icon(Icons.task_alt), label: 'My Jobs'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_basket), label: 'Store'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ];
      default:
        return const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_customize), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.storefront), label: 'Store'),
          BottomNavigationBarItem(icon: Icon(Icons.person_search), label: 'Assignment'),
        ];
    }
  }
}

class UnifiedJobsView extends StatefulWidget {
  final String role;
  final String title;
  final GlobalKey<ScaffoldState> scaffoldKey;
  const UnifiedJobsView({super.key, required this.role, required this.title, required this.scaffoldKey});

  @override
  State<UnifiedJobsView> createState() => _UnifiedJobsViewState();
}

class _UnifiedJobsViewState extends State<UnifiedJobsView> {
  String selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context, listen: false);
    final user = auth.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        backgroundColor: const Color(0xFF161B22),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () => widget.scaffoldKey.currentState?.openDrawer(),
        ),
        title: Row(
          children: [
            Container(
              height: 32,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Center(
                child: Text(
                  'PATCHWORKS',
                  style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(widget.title, style: const TextStyle(color: Colors.white, fontSize: 18)),
          ],
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              if (widget.role == 'homeowner') _buildNewJobPrompt(context),
              
              // Filter Section
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: ['All', 'Active', 'Completed', 'Quotes']
                        .map((f) => _buildFilterChip(f))
                        .toList(),
                  ),
                ),
              ),
              
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('jobs')
                      .where(widget.role == 'homeowner' ? 'homeownerId' : 'assignedWorkerId', isEqualTo: user?.uid)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return _buildMockList();
                    }

                    final jobs = snapshot.data!.docs.map((d) => Job.fromFirestore(d)).toList();
                    return ListView.builder(
                      padding: const EdgeInsets.only(bottom: 100), 
                      itemCount: jobs.length,
                      itemBuilder: (context, index) => JobCard(
                        job: jobs[index],
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => JobDetailScreen(job: jobs[index]),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              backgroundColor: Colors.orange,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AgentChatScreen(agentId: 'vijay')),
                );
              },
              child: const Text('👷', style: TextStyle(fontSize: 30)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewJobPrompt(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.orange.shade700, Colors.orange.shade400]),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.orange.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Row(
        children: [
          const Icon(Icons.add_circle_outline, color: Colors.white, size: 40),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Start a Project?', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                Text('Post a requirement in seconds', style: TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.orange,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pushNamed(context, '/jobs/create'),
            child: const Text('NEW JOB'),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = selectedFilter == label;
    return GestureDetector(
      onTap: () => setState(() => selectedFilter = label),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.orange.withOpacity(0.2) : const Color(0xFF161B22),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? Colors.orange : Colors.white10),
        ),
        child: Text(
          label,
          style: TextStyle(color: isSelected ? Colors.orange : Colors.white60, fontSize: 12),
        ),
      ),
    );
  }

  Widget _buildMockList() {
    return ListView(
      padding: const EdgeInsets.only(bottom: 100),
      children: List.generate(8, (index) {
        final job = Job(
          id: 'mock$index',
          title: [
            'Living Room Painting',
            'Kitchen Tap Leakage',
            'Slab Sentring Slab',
            'Full House Wiring',
            'Footing Reinforcement',
            'Wall Plastering',
            'Wardrobe Carpentry',
            'Tank Connection'
          ][index],
          description: 'High quality construction work with professional finish.',
          dateTime: DateTime.now().subtract(Duration(days: index)),
          quoteStatus: index % 2 == 0 ? '₹${4500 + index * 1000} Quote Received' : 'Assigned',
          materialsIncluded: index % 3 == 0,
          status: index % 2 == 0 ? JobStatus.created : JobStatus.assigned,
          jobNumber: 100 + index,
          locationHash: 'hyd_${index + 1}',
          homeownerId: 'user123',
          evidence: [
            JobEvidence(url: 'https://images.unsplash.com/photo-1581094794329-c8112a89af12?auto=format&fit=crop&w=800&q=80', type: 'image'),
            JobEvidence(url: 'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4', type: 'video'),
          ],
        );
        return JobCard(
          job: job,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => JobDetailScreen(job: job)),
            );
          },
        );
      }),
    );
  }
}

class ProfileStub extends StatelessWidget {
  const ProfileStub({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(title: const Text('Profile'), backgroundColor: const Color(0xFF161B22)),
      body: const Center(child: Text('User Profile & Skills', style: TextStyle(color: Colors.white))),
    );
  }
}
