import 'package:flutter/material.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(title: const Text('Customer Support'), backgroundColor: const Color(0xFF121212), foregroundColor: const Color(0xFFFF7A00)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text('Need help?', style: TextStyle(color: Colors.white, fontSize: 22)),
            const SizedBox(height: 16),
            const Text('WhatsApp, call, or chat with Patchworks team.', style: TextStyle(color: Colors.white70), textAlign: TextAlign.center),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF7A00), foregroundColor: Colors.black, minimumSize: const Size(double.infinity, 50)),
              onPressed: () {},
              icon: const Icon(Icons.chat),
              label: const Text('WhatsApp Support'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFFFF7A00)), minimumSize: const Size(double.infinity, 50)),
              onPressed: () {},
              icon: const Icon(Icons.phone, color: Color(0xFFFF7A00)),
              label: const Text('Call Us', style: TextStyle(color: Color(0xFFFF7A00))),
            ),
          ],
        ),
      ),
    );
  }
}
