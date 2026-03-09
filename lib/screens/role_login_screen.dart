import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

class RoleLoginScreen extends StatelessWidget {
  const RoleLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context, listen: false);
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Choose your role', style: TextStyle(fontSize: 24)),
            const SizedBox(height: 40),
            ElevatedButton(
              style: ElevatedButton.styleFrom(minimumSize: const Size(280, 60)),
              onPressed: () async {
                print('DEBUG: Homeowner button pressed');
                try {
                  print('DEBUG: Calling signInWithGoogle');
                  final credential = await auth.signInWithGoogle();
                  print('DEBUG: signInWithGoogle returned: $credential');
                  final user = auth.currentUser;
                  if (user != null) {
                    print('DEBUG: Writing role to Firestore');
                    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
                      'role': 'homeowner',
                      'uid': user.uid,
                      'email': user.email ?? '',
                      'lastLogin': FieldValue.serverTimestamp(),
                    }, SetOptions(merge: true));
                    print('DEBUG: Firestore write success → navigating to home');
                    Navigator.pushReplacementNamed(context, '/home');
                  } else {
                    print('DEBUG: No user after sign-in');
                  }
                } catch (e) {
                  print('DEBUG: Login error: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Login failed: $e')),
                  );
                }
              },
              child: const Text('Login as Homeowner', style: TextStyle(fontSize: 18)),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(minimumSize: const Size(280, 60)),
              onPressed: () async {
                print('DEBUG: Builder button pressed');
                try {
                  print('DEBUG: Calling signInWithGoogle');
                  final credential = await auth.signInWithGoogle();
                  print('DEBUG: signInWithGoogle returned: $credential');
                  final user = auth.currentUser;
                  if (user != null) {
                    print('DEBUG: Writing role to Firestore');
                    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
                      'role': 'builder',
                      'uid': user.uid,
                      'email': user.email ?? '',
                      'lastLogin': FieldValue.serverTimestamp(),
                    }, SetOptions(merge: true));
                    print('DEBUG: Firestore write success → navigating to home');
                    Navigator.pushReplacementNamed(context, '/home');
                  } else {
                    print('DEBUG: No user after sign-in');
                  }
                } catch (e) {
                  print('DEBUG: Login error: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Login failed: $e')),
                  );
                }
              },
              child: const Text('Login as Builder/Mestri', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}