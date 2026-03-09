import 'package:flutter/material.dart';
import 'agent_chat_screen.dart'; // import the new screen

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patchworks Home'),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Welcome back!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),
              Card(
                elevation: 4,
                child: ListTile(
                  leading: const Icon(Icons.chat, color: Colors.orange, size: 40),
                  title: const Text('Chat with Agent Vijay', style: TextStyle(fontSize: 18)),
                  subtitle: const Text('Get tentative plans, quotes (₹1750–₹3500/sqft), Vastu advice, or discuss your dream house'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AgentChatScreen(agentId: 'vijay'),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 4,
                child: ListTile(
                  leading: const Icon(Icons.inventory, color: Colors.orange, size: 40),
                  title: const Text('Chat with Agent Material', style: TextStyle(fontSize: 18)),
                  subtitle: const Text('Ask about sand, bricks, steel, wires, concrete quantities & prices'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AgentChatScreen(agentId: 'material'),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 4,
                child: ListTile(
                  leading: const Icon(Icons.description, color: Colors.orange, size: 40),
                  title: const Text('Chat with Document Tracker', style: TextStyle(fontSize: 18)),
                  subtitle: const Text('Request invoices, plans, progress photos, WhatsApp updates'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AgentChatScreen(agentId: 'document_tracker'),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Create Job'),
                onTap: () => Navigator.pushNamed(context, '/jobs/create'),
              ),
              ListTile(
                title: const Text('Upload Evidence'),
                onTap: () => Navigator.pushNamed(context, '/evidence/capture'),
              ),
              ListTile(
                title: const Text('Project Dashboard'),
                onTap: () => Navigator.pushNamed(context, '/dashboard'),
              ),
              const SizedBox(height: 32),
              const Center(
                child: Text(
                  'More features coming soon...',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}