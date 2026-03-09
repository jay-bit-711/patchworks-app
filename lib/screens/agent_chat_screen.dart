import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

class AgentChatScreen extends StatefulWidget {
  final String agentId;
  const AgentChatScreen({super.key, required this.agentId});

  @override
  State<AgentChatScreen> createState() => _AgentChatScreenState();
}

class _AgentChatScreenState extends State<AgentChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<String> _messages = [];
  bool _isLoading = false;

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add('You: $text');
      _isLoading = true;
    });
    _controller.clear();

    try {
      final auth = Provider.of<AuthService>(context, listen: false);
      final token = await auth.getIdToken();
      if (token == null) throw Exception('Not authenticated');

      final functions = FirebaseFunctions.instance.httpsCallable('routeAgentMessage');
      final result = await functions.call({
        'agentId': widget.agentId,
        'message': text,
        'token': token,
      });

      setState(() {
        _messages.add('${widget.agentId.capitalize()}: ${result.data['reply'] ?? 'No reply'}');
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _messages.add('Error: $e');
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chat with ${widget.agentId.capitalize()}')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: _messages.length,
              itemBuilder: (context, index) => Align(
                alignment: _messages[index].startsWith('You:') ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _messages[index].startsWith('You:') ? Colors.blue[100] : Colors.green[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(_messages[index]),
                ),
              ),
            ),
          ),
          if (_isLoading) const Padding(padding: EdgeInsets.all(8), child: CircularProgressIndicator()),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Type your message...',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                IconButton(icon: const Icon(Icons.send), onPressed: _sendMessage),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() => "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
}