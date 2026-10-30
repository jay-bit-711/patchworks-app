import 'package:flutter/material.dart';

class PostJobScreen extends StatefulWidget {
  const PostJobScreen({super.key});

  @override
  State<PostJobScreen> createState() => _PostJobScreenState();
}

class _PostJobScreenState extends State<PostJobScreen> {
  String? _category;
  String _location = 'Hyderabad';
  bool _withMaterials = false;

  final _categories = [
    ('Plumbing', Icons.water_drop_outlined),
    ('Electrical', Icons.electrical_services_outlined),
    ('Masonry', Icons.domain),
    ('Painting', Icons.format_paint),
    ('Flooring', Icons.grid_on),
    ('Waterproofing', Icons.umbrella),
    ('Carpentry', Icons.carpenter),
    ('Other', Icons.more_horiz),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        foregroundColor: const Color(0xFFFF7A00),
        title: const Text('New Job'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // Where?
          _Question(
            icon: Icons.location_on,
            question: 'Where?',
            child: ListTile(
              tileColor: const Color(0xFF1E1E1E),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              leading: const Icon(Icons.location_pin, color: Color(0xFFFF7A00)),
              title: Text(_location, style: const TextStyle(color: Colors.white, fontSize: 18)),
              trailing: const Icon(Icons.edit, color: Colors.white38),
              onTap: () {},
            ),
          ),
          const SizedBox(height: 32),

          // What?
          _Question(
            icon: Icons.construction,
            question: 'What?',
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _categories.map((c) {
                final selected = _category == c.$1;
                return GestureDetector(
                  onTap: () => setState(() => _category = c.$1),
                  child: Container(
                    width: 90,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: selected ? const Color(0xFFFF7A00) : const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Icon(c.$2, color: selected ? Colors.black : const Color(0xFFFF7A00), size: 32),
                        const SizedBox(height: 8),
                        Text(c.$1, style: TextStyle(color: selected ? Colors.black : Colors.white, fontSize: 12), textAlign: TextAlign.center),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 32),

          // Photos
          _Question(
            icon: Icons.photo_camera,
            question: 'Show me',
            child: Row(
              children: [
                Expanded(child: _BigIconButton(icon: Icons.camera_alt, label: 'Camera')),
                const SizedBox(width: 16),
                Expanded(child: _BigIconButton(icon: Icons.photo_library, label: 'Gallery')),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Materials
          _Question(
            icon: Icons.inventory_2_outlined,
            question: 'Materials?',
            child: Row(
              children: [
                Expanded(
                  child: _ChoiceButton(
                    label: 'With',
                    selected: _withMaterials,
                    onTap: () => setState(() => _withMaterials = true),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _ChoiceButton(
                    label: 'Without',
                    selected: !_withMaterials,
                    onTap: () => setState(() => _withMaterials = false),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 48),

          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF7A00),
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: _category == null ? null : () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Job posted')));
              Navigator.pop(context);
            },
            child: const Text('Post', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class _Question extends StatelessWidget {
  final IconData icon;
  final String question;
  final Widget child;
  const _Question({required this.icon, required this.question, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: const Color(0xFFFF7A00), size: 28),
            const SizedBox(width: 12),
            Text(question, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 16),
        child,
      ],
    );
  }
}

class _BigIconButton extends StatelessWidget {
  final IconData icon;
  final String label;
  const _BigIconButton({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFFFF7A00), size: 40),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}

class _ChoiceButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _ChoiceButton({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFFF7A00) : const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(label, style: TextStyle(color: selected ? Colors.black : Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }
}
