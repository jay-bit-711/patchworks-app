import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

class RoleLoginScreen extends StatelessWidget {
  const RoleLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context, listen: false);
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.construction, size: 80, color: Colors.orange),
              const SizedBox(height: 20),
              const Text(
                'PATCHWORKS',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Trust but Verify',
                style: TextStyle(color: Colors.white54, fontSize: 16),
              ),
              const SizedBox(height: 60),
              _buildModernButton(
                context,
                auth,
                label: 'I AM A HOMEOWNER',
                role: 'homeowner',
                icon: Icons.home,
              ),
              const SizedBox(height: 20),
              _buildModernButton(
                context,
                auth,
                label: 'I AM A BUILDER',
                role: 'supervisor',
                icon: Icons.engineering,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernButton(BuildContext context, AuthService auth, {
    required String label, 
    required String role, 
    required IconData icon
  }) {
    return Container(
      width: double.infinity,
      height: 70,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: LinearGradient(
          colors: [Colors.orange.shade700, Colors.orange.shade400],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        onPressed: () async {
          try {
            await auth.signInWithGoogle();
            if (auth.currentUser != null) {
              await auth.setUserRole(role);
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, '/home');
              }
            }
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Login failed: $e')),
              );
            }
          }
        },
        icon: Icon(icon, color: Colors.white, size: 28),
        label: Text(
          label, 
          style: const TextStyle(
            fontSize: 18, 
            color: Colors.white, 
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }
}
