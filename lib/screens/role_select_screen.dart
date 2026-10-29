import 'package:flutter/material.dart';
import 'upi_fee_screen.dart';
import 'customer_home_screen.dart';

class RoleSelectScreen extends StatelessWidget {
  const RoleSelectScreen({super.key});

  void _go(BuildContext context, String role) {
    Widget screen;
    if (role == 'customer') {
      screen = const CustomerHomeScreen();
    } else {
      screen = HomeByRole(role: role);
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
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
              const Text(
                'Patchworks',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFF7A00),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Trust but Verify',
                style: TextStyle(color: Colors.white70, fontSize: 18),
              ),
              const SizedBox(height: 48),
              const Text(
                'Continue as',
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
              const SizedBox(height: 24),
              _RoleButton(
                label: 'Homeowner / Customer',
                icon: Icons.home_outlined,
                onTap: () => _go(context, 'customer'),
              ),
              const SizedBox(height: 16),
              _RoleButton(
                label: 'Skilled Pro / Mestri',
                icon: Icons.construction,
                onTap: () => _go(context, 'pro'),
              ),
              const SizedBox(height: 16),
              _RoleButton(
                label: 'Admin',
                icon: Icons.admin_panel_settings_outlined,
                onTap: () => _go(context, 'admin'),
              ),
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

  const _RoleButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

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

class HomeByRole extends StatelessWidget {
  final String role;
  const HomeByRole({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    final isPro = role == 'pro';

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: Text(role.toUpperCase()),
        backgroundColor: const Color(0xFF121212),
        foregroundColor: const Color(0xFFFF7A00),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              isPro
                  ? 'Accept jobs → pay ₹150 site visit → unlock contact'
                  : 'Monitor all site visits & revenue',
              style: const TextStyle(color: Colors.white70, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            if (isPro)
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF7A00),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const UpiFeeScreen(
                        jobId: 1,
                        customerId: 1,
                        proId: 2,
                        party: 'pro',
                      ),
                    ),
                  );
                },
                child: const Text(
                  'Confirm Site Visit Fee (₹150)',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            if (role == 'admin')
              const Text(
                'Admin dashboard coming next.\nRevenue from dual ₹150 fees will appear here.',
                style: TextStyle(color: Colors.white54),
                textAlign: TextAlign.center,
              ),
          ],
        ),
      ),
    );
  }
}
