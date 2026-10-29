import 'package:flutter/material.dart';
import 'otp_screen.dart';

class LoginPhoneScreen extends StatefulWidget {
  const LoginPhoneScreen({super.key});

  @override
  State<LoginPhoneScreen> createState() => _LoginPhoneScreenState();
}

class _LoginPhoneScreenState extends State<LoginPhoneScreen> {
  final _phone = TextEditingController();
  bool _isEnglish = true;

  void _sendOtp() {
    if (_phone.text.length < 10) return;
    Navigator.push(context, MaterialPageRoute(builder: (_) => OtpScreen(phone: _phone.text)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () => setState(() => _isEnglish = !_isEnglish),
                  icon: Icon(_isEnglish ? Icons.language : Icons.translate, color: const Color(0xFFFF7A00)),
                  label: Text(_isEnglish ? 'EN' : 'TE', style: const TextStyle(color: Color(0xFFFF7A00), fontWeight: FontWeight.bold)),
                ),
              ),
              const Spacer(),
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF7A00),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [BoxShadow(color: const Color(0xFFFF7A00).withOpacity(0.35), blurRadius: 20)],
                ),
                child: const Icon(Icons.construction, size: 56, color: Colors.black),
              ),
              const SizedBox(height: 24),
              const Text('Patchworks', style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Color(0xFFFF7A00))),
              const SizedBox(height: 8),
              Text(_isEnglish ? 'Trust but Verify' : 'Nammakam kani verify cheyandi', style: const TextStyle(color: Colors.white70, fontSize: 16)),
              const SizedBox(height: 48),
              TextField(
                controller: _phone,
                keyboardType: TextInputType.phone,
                style: const TextStyle(color: Colors.white, fontSize: 18),
                decoration: InputDecoration(
                  hintText: '+91 98765 43210',
                  hintStyle: const TextStyle(color: Colors.white38),
                  prefixIcon: const Icon(Icons.phone_android, color: Color(0xFFFF7A00)),
                  filled: true,
                  fillColor: const Color(0xFF1E1E1E),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF7A00),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 4,
                  ),
                  onPressed: _sendOtp,
                  child: Text(_isEnglish ? 'Continue with OTP' : 'OTP tho continue cheyandi', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                ),
              ),
              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }
}
