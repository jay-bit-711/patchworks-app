import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class JobCreateScreen extends StatefulWidget {
  const JobCreateScreen({super.key});

  @override
  State<JobCreateScreen> createState() => _JobCreateScreenState();
}

class _JobCreateScreenState extends State<JobCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _budgetController = TextEditingController();
  
  String _category = 'Construction';
  String _locationDisplay = 'Not captured';
  double? _lat;
  double? _lng;
  bool _isLocating = false;
  bool _isSubmitting = false;
  
  DateTime? _scheduledDate;

  final List<String> _categories = [
    'Construction', 'Plumbing', 'Electrical', 'Painting', 'Carpentry', 'Sentring', 'Flooring', 'Other'
  ];

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Colors.orange,
              onPrimary: Colors.white,
              surface: Color(0xFF161B22),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _scheduledDate = picked);
  }

  Future<void> _getLocation() async {
    setState(() => _isLocating = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) permission = await Geolocator.requestPermission();
      
      if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
        final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
        setState(() {
          _lat = position.latitude;
          _lng = position.longitude;
          _locationDisplay = 'Location captured ✅';
        });
      }
    } finally {
      setState(() => _isLocating = false);
    }
  }

  Future<void> _submitJob() async {
    if (!_formKey.currentState!.validate()) return;
    if (_lat == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please pin site location')));
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      final lastJobSnap = await FirebaseFirestore.instance.collection('jobs').orderBy('jobNumber', descending: true).limit(1).get();
      int nextJobNumber = lastJobSnap.docs.isNotEmpty ? (lastJobSnap.docs.first.data()['jobNumber'] ?? 100) + 1 : 101;

      await FirebaseFirestore.instance.collection('jobs').add({
        'title': _titleController.text.trim(),
        'description': _descController.text.trim(),
        'category': _category,
        'budget': double.tryParse(_budgetController.text) ?? 0.0,
        'latitude': _lat,
        'longitude': _lng,
        'homeownerId': user?.uid,
        'status': 'created',
        'jobNumber': nextJobNumber,
        'dateTime': FieldValue.serverTimestamp(),
        'scheduledStartDate': _scheduledDate != null ? Timestamp.fromDate(_scheduledDate!) : null,
      });

      if (mounted) Navigator.pop(context);
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        backgroundColor: const Color(0xFF161B22),
        elevation: 0,
        title: const Text('Post New Job', style: TextStyle(color: Colors.white, fontSize: 18)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Basic Details'),
              const SizedBox(height: 16),
              _buildTextField(controller: _titleController, label: 'Job Title', hint: 'e.g. Slab Sentring'),
              const SizedBox(height: 16),
              _buildDropdown(),
              const SizedBox(height: 16),
              _buildTextField(controller: _descController, label: 'Work Description', hint: 'Details...', maxLines: 3),
              const SizedBox(height: 32),
              
              _buildSectionTitle('Scheduling (Optional)'),
              const SizedBox(height: 16),
              _buildSchedulerTile(),
              const SizedBox(height: 32),

              _buildSectionTitle('Location & Budget'),
              const SizedBox(height: 16),
              _buildLocationPicker(),
              const SizedBox(height: 16),
              _buildTextField(controller: _budgetController, label: 'Expected Budget (INR)', hint: '5000', keyboardType: TextInputType.number),
              
              const SizedBox(height: 48),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: const TextStyle(color: Colors.orange, fontSize: 16, fontWeight: FontWeight.bold));
  }

  Widget _buildTextField({required TextEditingController controller, required String label, required String hint, int maxLines = 1, TextInputType keyboardType = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54, fontSize: 14),
        fillColor: const Color(0xFF161B22),
        filled: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.white10)),
      ),
    );
  }

  Widget _buildDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(color: const Color(0xFF161B22), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white10)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _category,
          isExpanded: true,
          dropdownColor: const Color(0xFF161B22),
          style: const TextStyle(color: Colors.white),
          items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
          onChanged: (v) => setState(() => _category = v!),
        ),
      ),
    );
  }

  Widget _buildSchedulerTile() {
    return InkWell(
      onTap: _pickDate,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: const Color(0xFF161B22), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white10)),
        child: Row(
          children: [
            const Icon(Icons.calendar_month, color: Colors.orange),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Proposed Start Date', style: TextStyle(color: Colors.white54, fontSize: 12)),
                Text(_scheduledDate == null ? 'Set timeline...' : DateFormat('dd MMM yyyy').format(_scheduledDate!), 
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationPicker() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF161B22), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white10)),
      child: Row(
        children: [
          Expanded(
            child: Text(_locationDisplay, style: TextStyle(color: _lat != null ? Colors.green : Colors.white24, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton.icon(
            onPressed: _isLocating ? null : _getLocation,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            icon: const Icon(Icons.my_location, size: 18, color: Colors.white),
            label: const Text('PIN SITE', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
        onPressed: _isSubmitting ? null : _submitJob,
        child: _isSubmitting ? const CircularProgressIndicator(color: Colors.white) : const Text('POST JOB', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
