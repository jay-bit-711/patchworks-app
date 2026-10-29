import 'package:flutter/material.dart';
import 'otp_screen.dart';

class LoginPhoneScreen extends StatefulWidget {
  const LoginPhoneScreen({super.key});

  @override
  State<LoginPhoneScreen> createState() => _LoginPhoneScreenState();
}

class _LoginPhoneScreenState extends State<LoginPhoneScreen> {
  final _phone = TextEditingController();

  void _sendOtp() {
    if (_phone.text.length < 10) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => OtpScreen(phone: _phone.text)),
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
              const Text('Trust but Verify', style: TextStyle(color: Colors.white70)),
              const SizedBox(height: 48),
              TextField(
                controller: _phone,
                keyboardType: TextInputType.phone,
                style: const TextStyle(color: Colors.white, fontSize: 20),
                decoration: InputDecoration(
                  hintText: '+91 98765 43210',
                  hintStyle: const TextStyle(color: Colors.white38),
                  prefixIcon: const Icon(Icons.phone, color: Color(0xFFFF7A00)),
                  filled: true,
                  fillColor: const Color(0xFF1E1E1E),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF7A00),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _sendOtp,
                  child: const Text('Send OTP', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
