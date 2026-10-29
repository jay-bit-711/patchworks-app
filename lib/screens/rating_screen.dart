import 'package:flutter/material.dart';

class RatingScreen extends StatefulWidget {
  final String jobTitle;
  const RatingScreen({super.key, required this.jobTitle});

  @override
  State<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  int _stars = 5;
  final _comment = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(title: const Text('Rate Job'), backgroundColor: const Color(0xFF121212), foregroundColor: const Color(0xFFFF7A00)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(widget.jobTitle, style: const TextStyle(color: Colors.white, fontSize: 20)),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (i) => IconButton(
                icon: Icon(i < _stars ? Icons.star : Icons.star_border, color: const Color(0xFFFF7A00), size: 36),
                onPressed: () => setState(() => _stars = i + 1),
              )),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _comment,
              maxLines: 3,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Optional comment',
                filled: true,
                fillColor: const Color(0xFF1E1E1E),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF7A00), foregroundColor: Colors.black, minimumSize: const Size(double.infinity, 50)),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Thanks for rating!')));
                Navigator.pop(context);
              },
              child: const Text('Submit Rating'),
            ),
          ],
        ),
      ),
    );
  }
}
