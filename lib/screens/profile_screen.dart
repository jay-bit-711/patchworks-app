import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _address = TextEditingController();
  final _phone = TextEditingController();
  final _upi = TextEditingController();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final d = doc.data() ?? {};
    _name.text = (d['name'] ?? '').toString();
    _email.text = (d['email'] ?? '').toString();
    _address.text = (d['address'] ?? '').toString();
    _phone.text = (d['phone'] ?? '').toString();
    _upi.text = (d['upi_id'] ?? '').toString();
    setState(() => _loading = false);
  }

  Future<void> _save() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final role = (doc.data()?['role'] ?? 'homeowner').toString();

    if (_name.text.trim().isEmpty ||
        _email.text.trim().isEmpty ||
        _address.text.trim().isEmpty ||
        _phone.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('All profile fields are mandatory')));
      return;
    }

    if ((role == 'builder' || role == 'supervisor') && !_upi.text.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Builder/Supervisor UPI must be valid')));
      return;
    }

    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'name': _name.text.trim(),
      'email': _email.text.trim(),
      'address': _address.text.trim(),
      'phone': _phone.text.trim(),
      'upi_id': _upi.text.trim(),
      'complete_profile': true,
      'updated_at': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile saved')));
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(controller: _name, decoration: const InputDecoration(labelText: 'Name *')),
          TextField(controller: _email, decoration: const InputDecoration(labelText: 'Email *')),
          TextField(controller: _address, decoration: const InputDecoration(labelText: 'Address *')),
          TextField(controller: _phone, decoration: const InputDecoration(labelText: 'Phone *')),
          TextField(controller: _upi, decoration: const InputDecoration(labelText: 'UPI (builder/supervisor required)')),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _save, child: const Text('Save')),
        ],
      ),
    );
  }
}
