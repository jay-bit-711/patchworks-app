import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    // Artificial delay for branding
    await Future.delayed(const Duration(seconds: 2));
    
    if (!mounted) return;
    
    final auth = Provider.of<AuthService>(context, listen: false);
    final user = auth.currentUser;

    if (user != null) {
      // User is logged in, check their role in Firestore
      try {
        final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (doc.exists && doc.data()?['role'] != null) {
          // Role exists, go to home
          Navigator.pushReplacementNamed(context, '/home');
        } else {
          // No role set, go to role selection
          Navigator.pushReplacementNamed(context, '/login');
        }
      } catch (e) {
        print('Error fetching user role: $e');
        Navigator.pushReplacementNamed(context, '/login');
      }
    } else {
      // Not logged in, go to login
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.construction, size: 100, color: Colors.white),
            SizedBox(height: 20),
            Text(
              'Patchworks',
              style: TextStyle(
                fontSize: 40, 
                color: Colors.white, 
                fontWeight: FontWeight.bold
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Trust but Verify',
              style: TextStyle(
                fontSize: 16, 
                color: Colors.white70, 
                fontStyle: FontStyle.italic
              ),
            ),
            SizedBox(height: 40),
            CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}
