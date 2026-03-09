import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class EvidenceCaptureScreen extends StatefulWidget {
  const EvidenceCaptureScreen({super.key});

  @override
  State<EvidenceCaptureScreen> createState() => _EvidenceCaptureScreenState();
}

class _EvidenceCaptureScreenState extends State<EvidenceCaptureScreen> {
  final picker = ImagePicker();

  Future<void> _uploadEvidence() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      final file = File(pickedFile.path);
      final ref = FirebaseStorage.instance.ref().child('evidence/${DateTime.now().toIso8601String()}.jpg');
      await ref.putFile(file);
      final url = await ref.getDownloadURL();
      // Save url to Firestore jobs/progress if needed
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Capture Evidence')),
      body: Center(
        child: ElevatedButton(
          onPressed: _uploadEvidence,
          child: const Text('Take Photo'),
        ),
      ),
    );
  }
}
