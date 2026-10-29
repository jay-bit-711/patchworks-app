import 'package:flutter/material.dart';
import 'customer_home_screen.dart';
import 'builder_home_screen.dart';

class RoleSelectScreen extends StatelessWidget {
  const RoleSelectScreen({super.key});

  void _go(BuildContext context, String role) {
    Widget screen;
    if (role == 'customer') {
      screen = const CustomerHomeScreen();
    } else if (role == 'pro') {
      screen = const BuilderHomeScreen();
    } else {
      screen = const Scaffold(
        backgroundColor: Color(0xFF121212),
        body: Center(child: Text('Admin dashboard next', style: TextStyle(color: Colors.white70))),
      );
    }
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => screen),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Patchworks', style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Color(0xFFFF7A00))),
              const SizedBox(height: 8),
              const Text('Trust but Verify', style: TextStyle(color: Colors.white70, fontSize: 18)),
              const SizedBox(height: 48),
              const Text('Continue as', style: TextStyle(color: Colors.white, fontSize: 20)),
              const SizedBox(height: 24),
              _RoleButton(label: 'Homeowner / Customer', icon: Icons.home_outlined, onTap: () => _go(context, 'customer')),
              const SizedBox(height: 16),
              _RoleButton(label: 'Skilled Pro / Mestri', icon: Icons.construction, onTap: () => _go(context, 'pro')),
              const SizedBox(height: 16),
              _RoleButton(label: 'Admin', icon: Icons.admin_panel_settings_outlined, onTap: () => _go(context, 'admin')),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const _RoleButton({required this.label, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFF7A00),
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: onTap,
        icon: Icon(icon),
        label: Text(label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
      ),
    );
  }
}
