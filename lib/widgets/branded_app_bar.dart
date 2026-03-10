import 'package:flutter/material.dart';

class BrandedAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;

  const BrandedAppBar({
    super.key, 
    required this.title, 
    this.actions,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFF161B22),
      elevation: 0,
      leading: leading,
      title: Row(
        children: [
          // Logo Icon Placeholder - ideally replace with Image.asset('assets/logo.png')
          Container(
            height: 32,
            width: 32,
            decoration: BoxDecoration(
              color: Colors.orange,
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(Icons.construction, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white, 
              fontSize: 18, 
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
