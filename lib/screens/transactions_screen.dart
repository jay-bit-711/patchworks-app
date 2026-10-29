import 'package:flutter/material.dart';

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(title: const Text('Transactions'), backgroundColor: const Color(0xFF121212), foregroundColor: const Color(0xFFFF7A00)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _Txn('Site Visit Fee', '₹150', 'Plumbing job', 'Paid'),
          _Txn('Site Visit Fee', '₹150', 'Electrical job', 'Pending'),
        ],
      ),
    );
  }
}

class _Txn extends StatelessWidget {
  final String title, amount, job, status;
  const _Txn(this.title, this.amount, this.job, this.status);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF1E1E1E),
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(title, style: const TextStyle(color: Colors.white)),
        subtitle: Text(job, style: const TextStyle(color: Colors.white54)),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(amount, style: const TextStyle(color: Color(0xFFFF7A00), fontWeight: FontWeight.bold)),
            Text(status, style: const TextStyle(color: Colors.white38, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
