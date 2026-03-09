import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ProjectDashboardScreen extends StatefulWidget {
  const ProjectDashboardScreen({super.key});

  @override
  State<ProjectDashboardScreen> createState() => _ProjectDashboardScreenState();
}

class _ProjectDashboardScreenState extends State<ProjectDashboardScreen> {
  String selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117), 
      appBar: AppBar(
        backgroundColor: const Color(0xFF161B22),
        elevation: 0,
        leading: const Icon(Icons.menu, color: Colors.white),
        title: const Text(
          'Supervisor Dashboard',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        actions: const [
          Icon(Icons.language, color: Colors.white),
          SizedBox(width: 16),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User Greeting Header
                Container(
                  padding: const EdgeInsets.all(20),
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF161B22),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        backgroundColor: Colors.orange,
                        child: Icon(Icons.person, color: Colors.white),
                        radius: 25,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Good morning, Jayanth 👋',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Jobs Dashboard',
                              style: TextStyle(color: Colors.white.withOpacity(0.6)),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.notifications_none, color: Colors.white),
                      const SizedBox(width: 16),
                      const Icon(Icons.account_circle_outlined, color: Colors.white),
                    ],
                  ),
                ),

                // Filter Chips
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip('All', isSelected: selectedFilter == 'All'),
                        _buildFilterChip('Created', isSelected: selectedFilter == 'Created'),
                        _buildFilterChip('Assigned', isSelected: selectedFilter == 'Assigned'),
                        _buildFilterChip('Completed', isSelected: selectedFilter == 'Completed'),
                      ],
                    ),
                  ),
                ),

                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Job Management Dashboard',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                _buildJobCard(
                  context,
                  jobNumber: 1,
                  status: 'Created',
                  title: 'wallpaper in my room',
                  dateTime: DateTime(2026, 2, 27, 7, 4),
                  quoteStatus: 'Quote pending',
                  materialsIncluded: true,
                ),
                _buildJobCard(
                  context,
                  jobNumber: 2,
                  status: 'Created',
                  title: 'wall paper',
                  dateTime: DateTime(2026, 2, 27, 6, 46),
                  quoteStatus: 'Quote pending',
                  materialsIncluded: true,
                ),
                
                const SizedBox(height: 120), // Padding for Floating Buttons
              ],
            ),
          ),
          
          // Floating Action Buttons
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    onPressed: () {},
                    icon: const Icon(Icons.currency_rupee, color: Colors.white),
                    label: const Text('Quote', style: TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.orange),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    onPressed: () {},
                    icon: const Icon(Icons.person_add, color: Colors.white),
                    label: const Text('Assign', style: TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, {bool isSelected = false}) {
    return GestureDetector(
      onTap: () => setState(() => selectedFilter = label),
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2E6BBA).withOpacity(0.3) : const Color(0xFF161B22),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? const Color(0xFF58A6FF) : Colors.white10,
          ),
        ),
        child: Row(
          children: [
            if (isSelected) const Icon(Icons.check, size: 16, color: Colors.white),
            if (isSelected) const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white60,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJobCard(
    BuildContext context, {
    required int jobNumber,
    required String status,
    required String title,
    required DateTime dateTime,
    required String quoteStatus,
    required bool materialsIncluded,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF2E6BBA).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: const TextStyle(color: Color(0xFF58A6FF), fontSize: 12),
                ),
              ),
              Text(
                '#$jobNumber',
                style: const TextStyle(color: Colors.white30),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${DateFormat('dd MMM yyyy • hh:mm a').format(dateTime)}',
                      style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      quoteStatus,
                      style: const TextStyle(color: Color(0xFF3FB950), fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.business_center, color: Colors.white30, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          'Materials: ${materialsIncluded ? 'Included' : 'Not Included'}',
                          style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 13),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              const Icon(Icons.image_not_supported, color: Colors.white10, size: 80),
            ],
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.white10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            onPressed: () {},
            icon: const Icon(Icons.chevron_right, color: Colors.white),
            label: const Text('View Details', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
