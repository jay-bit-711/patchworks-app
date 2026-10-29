import 'package:flutter/material.dart';

class PostJobScreen extends StatefulWidget {
  const PostJobScreen({super.key});

  @override
  State<PostJobScreen> createState() => _PostJobScreenState();
}

class _PostJobScreenState extends State<PostJobScreen> {
  final _title = TextEditingController();
  final _desc = TextEditingController();
  final _measures = TextEditingController();
  bool _withMaterials = false;
  String _location = 'Patancheru';

  void _post() {
    if (_title.text.isEmpty) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Job posted! Pay ₹150 site visit next.')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(title: const Text('Post New Job'), backgroundColor: const Color(0xFF121212), foregroundColor: const Color(0xFFFF7A00)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _field(_title, 'Title', 'e.g. Plumbing - Water in'),
          const SizedBox(height: 16),
          _field(_desc, 'Description', 'What needs to be done?', maxLines: 4),
          const SizedBox(height: 16),
          ListTile(
            tileColor: const Color(0xFF1E1E1E),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            leading: const Icon(Icons.photo_camera_outlined, color: Color(0xFFFF7A00)),
            title: const Text('Before Image', style: TextStyle(color: Colors.white)),
            subtitle: const Text('Tap to add', style: TextStyle(color: Colors.white54)),
            onTap: () {},
          ),
          const SizedBox(height: 16),
          ListTile(
            tileColor: const Color(0xFF1E1E1E),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            leading: const Icon(Icons.location_on_outlined, color: Color(0xFFFF7A00)),
            title: Text(_location, style: const TextStyle(color: Colors.white)),
            subtitle: const Text('GPS pin', style: TextStyle(color: Colors.white54)),
            onTap: () {},
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            tileColor: const Color(0xFF1E1E1E),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            title: const Text('With Materials', style: TextStyle(color: Colors.white)),
            value: _withMaterials,
            activeColor: const Color(0xFFFF7A00),
            onChanged: (v) => setState(() => _withMaterials = v),
          ),
          const SizedBox(height: 16),
          _field(_measures, 'Measures (optional)', 'e.g. 10x12 ft, 2 bathrooms'),
          const SizedBox(height: 32),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF7A00),
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 18),
            ),
            onPressed: _post,
            child: const Text('Post Job', style: TextStyle(fontSize: 18)),
          ),
        ],
      ),
    );
  }

  Widget _field(TextEditingController c, String label, String hint, {int maxLines = 1}) {
    return TextField(
      controller: c,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white38),
        filled: true,
        fillColor: const Color(0xFF1E1E1E),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }
}
