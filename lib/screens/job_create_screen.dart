import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class JobCreateScreen extends StatefulWidget {
  const JobCreateScreen({super.key});

  @override
  State<JobCreateScreen> createState() => _JobCreateScreenState();
}

class _JobCreateScreenState extends State<JobCreateScreen> {
  final _budgetController = TextEditingController();
  String _location = 'Patancheru';

  Future<void> _getLocation() async {
    final position = await Geolocator.getCurrentPosition();
    // Optionally use placemarkFromCoordinates for locality
    setState(() {
      _location = 'Lat: [${position.latitude}, Lng: ${position.longitude}';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Job')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _getLocation,
              child: const Text('Capture Location'),
            ),
            Text('Current Location: $_location'),
            TextField(
              controller: _budgetController,
              decoration: const InputDecoration(labelText: 'Budget (lakhs)'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Plan Description'),
            ),
            ElevatedButton(
              onPressed: () async {
                await FirebaseFirestore.instance.collection('jobs').add({
                  'location': _location,
                  'budget': _budgetController.text,
                  'userId': FirebaseAuth.instance.currentUser?.uid,
                  'created_at': FieldValue.serverTimestamp(),
                });
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Submit Job'),
            ),
          ],
        ),
      ),
    );
  }
}
