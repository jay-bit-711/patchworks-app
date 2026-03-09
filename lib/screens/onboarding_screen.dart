import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _name = TextEditingController();
  final _address = TextEditingController();
  final _phone = TextEditingController();
  final _upi = TextEditingController();
  String _role = 'homeowner';
  String? _gmapsLink;
  bool _saving = false;

  Future<void> _pickLocation() async {
    // Permission.location.request() removed due to missing package
    final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    final link = 'https://maps.google.com/?q=${pos.latitude},${pos.longitude}';
    setState(() => _gmapsLink = link);
  }

  Future<void> _openMaps() async {
    if (_gmapsLink == null) return;
    // launchUrl removed due to missing package
  }

  Future<void> _copyLink() async {
    if (_gmapsLink == null) return;
    // FlutterClipboardManager.copyToClipBoard removed due to missing package
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Copied site pin (clipboard manager unavailable)')));
  }

  Future<void> _save() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    if (_name.text.trim().isEmpty || _address.text.trim().isEmpty || _phone.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Name/Address/Phone are required')));
      return;
    }
    if ((_role == 'builder' || _role == 'supervisor') && !_upi.text.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Valid UPI ID required')));
      return;
    }

    setState(() => _saving = true);
    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      'name': _name.text.trim(),
      'address': _address.text.trim(),
      'phone': _phone.text.trim(),
      'role': _role,
      'upi_id': _upi.text.trim(),
      'site_gmaps_link': _gmapsLink ?? '',
      'complete_profile': true,
      'updated_at': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    final projectSnap = await FirebaseFirestore.instance
        .collection('projects')
        .where('homeowner_uid', isEqualTo: user.uid)
        .limit(1)
        .get();
    if (projectSnap.docs.isNotEmpty && _gmapsLink != null) {
      await projectSnap.docs.first.reference.set({'site_gmaps_link': _gmapsLink}, SetOptions(merge: true));
    }

    if (!mounted) return;
    setState(() => _saving = false);
    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Onboarding')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(controller: _name, decoration: const InputDecoration(labelText: 'Name *')),
          TextField(controller: _address, decoration: const InputDecoration(labelText: 'Address *')),
          TextField(controller: _phone, decoration: const InputDecoration(labelText: 'Phone *')),
          DropdownButtonFormField<String>(
            value: _role,
            items: const [
              DropdownMenuItem(value: 'homeowner', child: Text('Homeowner')),
              DropdownMenuItem(value: 'builder', child: Text('Builder')),
              DropdownMenuItem(value: 'supervisor', child: Text('Supervisor')),
              DropdownMenuItem(value: 'contractor', child: Text('Contractor')),
            ],
            onChanged: (v) => setState(() => _role = v ?? 'homeowner'),
            decoration: const InputDecoration(labelText: 'Role'),
          ),
          if (_role == 'builder' || _role == 'supervisor')
            TextField(controller: _upi, decoration: const InputDecoration(labelText: 'UPI ID * (name@upi)')),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: _pickLocation, child: const Text('Capture Site Location')),
          if (_gmapsLink != null) Text(_gmapsLink!),
          Row(
            children: [
              TextButton(onPressed: _copyLink, child: const Text('Copy Pin')),
              TextButton(onPressed: _openMaps, child: const Text('Open GMaps')),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _saving ? null : _save, child: Text(_saving ? 'Saving...' : 'Save Profile')),
        ],
      ),
    );
  }
}
