import 'package:flutter/material.dart';
import '../services/upi_service.dart';

class UpiFeeScreen extends StatefulWidget {
  final int jobId;
  final int customerId;
  final int proId;
  final String party; // 'customer' or 'pro'

  const UpiFeeScreen({
    super.key,
    required this.jobId,
    required this.customerId,
    required this.proId,
    required this.party,
  });

  @override
  State<UpiFeeScreen> createState() => _UpiFeeScreenState();
}

class _UpiFeeScreenState extends State<UpiFeeScreen> {
  final _upi = UpiService();
  String? _siteVisitId;
  String? _upiLink;
  Map<String, dynamic>? _status;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    setState(() => _loading = true);
    try {
      final data = await _upi.initiate(
        jobId: widget.jobId,
        customerId: widget.customerId,
        proId: widget.proId,
      );
      setState(() {
        _siteVisitId = data['site_visit_id'];
        _upiLink = data['upi_deep_link'];
      });
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _pay() async {
    if (_upiLink == null) return;
    try {
      await _upi.openUpi(_upiLink!);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open UPI: $e')),
      );
    }
  }

  Future<void> _confirm() async {
    if (_siteVisitId == null) return;
    setState(() => _loading = true);
    try {
      await _upi.confirm(siteVisitId: _siteVisitId!, party: widget.party);
      await _check();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Confirm failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _check() async {
    if (_siteVisitId == null) return;
    final s = await _upi.status(_siteVisitId!);
    setState(() => _status = s);
  }

  @override
  Widget build(BuildContext context) {
    final unlocked = _status?['unlocked'] == true;

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('Site Visit Fee ₹150'),
        backgroundColor: const Color(0xFF121212),
        foregroundColor: const Color(0xFFFF7A00),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Both Customer & Pro must pay ₹150 via UPI\nto unlock Call + GPS',
              style: TextStyle(color: Colors.white70, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            if (_loading) const Center(child: CircularProgressIndicator(color: Color(0xFFFF7A00))),
            if (_upiLink != null) ...[
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF7A00),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: _pay,
                child: const Text('Open UPI ₹150', style: TextStyle(fontSize: 18)),
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: _confirm,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFFF7A00)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text('I Paid (₹150 as ${widget.party})',
                    style: const TextStyle(color: Color(0xFFFF7A00))),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: _check,
                child: const Text('Refresh Status', style: TextStyle(color: Colors.white54)),
              ),
            ],
            const Spacer(),
            if (_status != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: unlocked ? Colors.green.shade900 : Colors.grey.shade900,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  unlocked
                      ? '✅ Unlocked — Call + GPS available'
                      : 'Waiting... Customer: ${_status!['customer_paid']} | Pro: ${_status!['pro_paid']}',
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
