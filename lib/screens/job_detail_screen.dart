import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/job.dart';
import '../widgets/evidence_viewer.dart';

class JobDetailScreen extends StatelessWidget {
  final Job job;

  const JobDetailScreen({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        backgroundColor: const Color(0xFF161B22),
        elevation: 0,
        title: Row(
          children: [
            const Icon(Icons.construction, color: Colors.orange, size: 24),
            const SizedBox(width: 10),
            Text('Job #${job.jobNumber}', style: const TextStyle(color: Colors.white, fontSize: 18)),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Job Progress'),
                  const SizedBox(height: 16),
                  _buildStatusTimeline(),
                  const SizedBox(height: 32),

                  _buildSectionTitle('Project Details'),
                  const SizedBox(height: 12),
                  _buildDetailCards(),
                  const SizedBox(height: 32),

                  _buildSectionTitle('Description'),
                  const SizedBox(height: 8),
                  Text(
                    job.description,
                    style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 16, height: 1.5),
                  ),
                  const SizedBox(height: 32),
                  
                  _buildSectionTitle('Site Evidence'),
                  const SizedBox(height: 12),
                  EvidenceViewer(evidence: job.evidence),
                  const SizedBox(height: 32),

                  _buildSectionTitle('Billing & Contract'),
                  const SizedBox(height: 12),
                  _buildBillingInfo(),
                  
                  const SizedBox(height: 40),
                  _buildActionButton(context),
                  const SizedBox(height: 20),
                  const Center(
                    child: Text(
                      'AI can make mistakes. Trust but Verify.',
                      style: TextStyle(color: Colors.white24, fontStyle: FontStyle.italic),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Color(0xFF161B22),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatusBadge(job.status),
          const SizedBox(height: 16),
          Text(
            job.title,
            style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.calendar_today, color: Colors.white38, size: 14),
              const SizedBox(width: 8),
              Text(
                'Posted ${DateFormat('dd MMM yyyy').format(job.dateTime)}',
                style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusTimeline() {
    final statusIndex = JobStatus.values.indexOf(job.status);
    
    return Column(
      children: [
        _buildTimelineStep('Job Created', 'Requirements posted and saved', statusIndex >= 0),
        _buildTimelineStep('Mestri Assigned', job.assignedWorkerId != null ? 'Expert matched to site' : 'Finding the best pro...', statusIndex >= 1),
        _buildTimelineStep('In Progress', 'Work underway on site', statusIndex >= 2),
        _buildTimelineStep('Completed', 'Final check and verification done', statusIndex >= 3),
      ],
    );
  }

  Widget _buildTimelineStep(String title, String subtitle, bool isDone) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: isDone ? Colors.green : Colors.white10,
                shape: BoxShape.circle,
                border: Border.all(color: isDone ? Colors.greenAccent : Colors.white24, width: 2),
              ),
              child: isDone ? const Icon(Icons.check, size: 12, color: Colors.white) : null,
            ),
            Container(
              width: 2,
              height: 40,
              color: isDone ? Colors.green : Colors.white10,
            ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: isDone ? Colors.white : Colors.white38,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(color: Colors.white24, fontSize: 13),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailCards() {
    return Row(
      children: [
        _buildSmallDetailCard(
          'Assignment',
          job.assignedWorkerId != null ? 'Assigned' : 'Awaiting Pro',
          job.assignedWorkerId != null ? Icons.person : Icons.person_search,
          job.assignedWorkerId != null ? Colors.green : Colors.orange,
        ),
        const SizedBox(width: 12),
        _buildSmallDetailCard(
          'Materials',
          job.materialsIncluded ? 'Included' : 'Labor Only',
          Icons.inventory_2,
          Colors.blueAccent,
        ),
      ],
    );
  }

  Widget _buildSmallDetailCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF161B22),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 12),
            Text(label, style: const TextStyle(color: Colors.white38, fontSize: 12)),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(color: Colors.orange, fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildStatusBadge(JobStatus status) {
    Color color;
    switch (status) {
      case JobStatus.created: color = Colors.blue; break;
      case JobStatus.assigned: color = Colors.orange; break;
      case JobStatus.inProgress: color = Colors.green; break;
      case JobStatus.completed: color = Colors.grey; break;
      case JobStatus.disputed: color = Colors.red; break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.name.toUpperCase(),
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildBillingInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          const Icon(Icons.description, color: Colors.orange),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Contract & Quote', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                Text(job.quoteStatus, style: const TextStyle(color: Colors.white54, fontSize: 12)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.white24),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        onPressed: () {},
        child: const Text('CONTACT SUPPORT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
