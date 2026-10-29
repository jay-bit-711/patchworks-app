import 'package:flutter/material.dart';

class BuilderJobScreen extends StatefulWidget {
  final String jobTitle;
  const BuilderJobScreen({super.key, required this.jobTitle});

  @override
  State<BuilderJobScreen> createState() => _BuilderJobScreenState();
}

class _BuilderJobScreenState extends State<BuilderJobScreen> {
  final _desc = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(title: Text(widget.jobTitle), backgroundColor: const Color(0xFF121212), foregroundColor: const Color(0xFFFF7A00)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('Upload after images & description to complete', style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 16),
          ListTile(
            tileColor: const Color(0xFF1E1E1E),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            leading: const Icon(Icons.photo_camera_outlined, color: Color(0xFFFF7A00)),
            title: const Text('After Image', style: TextStyle(color: Colors.white)),
            subtitle: const Text('Tap to add', style: TextStyle(color: Colors.white54)),
            onTap: () {},
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _desc,
            maxLines: 4,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Work done description',
              filled: true,
              fillColor: const Color(0xFF1E1E1E),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF7A00), foregroundColor: Colors.black, minimumSize: const Size(double.infinity, 50)),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Job marked complete')));
              Navigator.pop(context);
            },
            child: const Text('Mark Complete'),
          ),
        ],
      ),
    );
  }
}
