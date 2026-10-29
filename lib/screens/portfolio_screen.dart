import 'package:flutter/material.dart';

class PortfolioScreen extends StatefulWidget {
  const PortfolioScreen({super.key});

  @override
  State<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen> {
  final _bio = TextEditingController(text: 'Experienced mestri in Patancheru. Plumbing, masonry, electrical.');
  final _skills = TextEditingController(text: 'Plumber, Mason, Electrician');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(title: const Text('My Portfolio'), backgroundColor: const Color(0xFF121212), foregroundColor: const Color(0xFFFF7A00)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(
            controller: _bio,
            maxLines: 4,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'About me',
              filled: true,
              fillColor: const Color(0xFF1E1E1E),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _skills,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Skills',
              filled: true,
              fillColor: const Color(0xFF1E1E1E),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 16),
          ListTile(
            tileColor: const Color(0xFF1E1E1E),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            leading: const Icon(Icons.photo_library_outlined, color: Color(0xFFFF7A00)),
            title: const Text('Add work photos', style: TextStyle(color: Colors.white)),
            onTap: () {},
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF7A00), foregroundColor: Colors.black, minimumSize: const Size(double.infinity, 50)),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Portfolio saved')));
              Navigator.pop(context);
            },
            child: const Text('Save Portfolio'),
          ),
        ],
      ),
    );
  }
}
