import 'package:flutter/material.dart';

class PostJobScreen extends StatefulWidget {
  const PostJobScreen({super.key});

  @override
  State<PostJobScreen> createState() => _PostJobScreenState();
}

class _PostJobScreenState extends State<PostJobScreen> {
  final _title = TextEditingController();
  final _desc = TextEditingController();
  String _category = 'Plumbing';
  bool _withMaterials = false;
  final _categories = ['Plumbing', 'Electrical', 'Masonry', 'Painting', 'Flooring', 'Waterproofing', 'Carpentry', 'Other'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('Post a Job', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF121212),
        foregroundColor: const Color(0xFFFF7A00),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('What needs to be done?', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          TextField(
            controller: _title,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'e.g. Ceiling water leak',
              hintStyle: const TextStyle(color: Colors.white38),
              filled: true,
              fillColor: const Color(0xFF1E1E1E),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            ),
          ),
          const SizedBox(height: 24),
          const Text('Category', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _categories.map((c) => ChoiceChip(
              label: Text(c),
              selected: _category == c,
              selectedColor: const Color(0xFFFF7A00),
              backgroundColor: const Color(0xFF1E1E1E),
              labelStyle: TextStyle(color: _category == c ? Colors.black : Colors.white),
              onSelected: (_) => setState(() => _category = c),
            )).toList(),
          ),
          const SizedBox(height: 24),
          const Text('Description', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          TextField(
            controller: _desc,
            maxLines: 4,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Describe the problem clearly...',
              hintStyle: const TextStyle(color: Colors.white38),
              filled: true,
              fillColor: const Color(0xFF1E1E1E),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 24),
          const Text('Before photos', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _MediaButton(icon: Icons.camera_alt, label: 'Camera', onTap: () {}),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MediaButton(icon: Icons.photo_library, label: 'Gallery', onTap: () {}),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SwitchListTile(
            tileColor: const Color(0xFF1E1E1E),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text('With materials', style: TextStyle(color: Colors.white)),
            subtitle: const Text('Pro brings materials', style: TextStyle(color: Colors.white54)),
            value: _withMaterials,
            activeColor: const Color(0xFFFF7A00),
            onChanged: (v) => setState(() => _withMaterials = v),
          ),
          const SizedBox(height: 24),
          const Text('Location', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          ListTile(
            tileColor: const Color(0xFF1E1E1E),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            leading: const Icon(Icons.location_on, color: Color(0xFFFF7A00)),
            title: const Text('Patancheru, Hyderabad', style: TextStyle(color: Colors.white)),
            trailing: const Icon(Icons.edit, color: Colors.white38),
            onTap: () {},
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF7A00),
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 4,
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Job posted successfully')));
              Navigator.pop(context);
            },
            child: const Text('Post Job', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class _MediaButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _MediaButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Color(0xFFFF7A00)),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      onPressed: onTap,
      icon: Icon(icon, color: const Color(0xFFFF7A00)),
      label: Text(label, style: const TextStyle(color: Color(0xFFFF7A00))),
    );
  }
}
