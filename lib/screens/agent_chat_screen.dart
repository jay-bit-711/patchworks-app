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
  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;

  String get _agentName {
    switch (widget.agentId) {
      case 'vijay': return 'Vijay 👷';
      case 'material': return 'Store Agent 📦';
      case 'assignment_agent': return 'Assigner 📋';
      case 'customer_care': return 'Support 🎧';
      default: return 'Agent';
    }
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final auth = Provider.of<AuthService>(context, listen: false);
    final userName = auth.currentUser?.displayName?.split(' ')[0] ?? 'You';

    setState(() {
      _messages.add({'sender': userName, 'text': text, 'isUser': 'true'});
      _isLoading = true;
    });
    _controller.clear();

    try {
      final token = await auth.getIdToken();
      if (token == null) throw Exception('Not authenticated');

      final functions = FirebaseFunctions.instance.httpsCallable('routeAgentMessage');
      final result = await functions.call({
        'agentId': widget.agentId,
        'message': text,
        'token': token,
        // We can pass current context if needed for memory reinforcement
      });

      setState(() {
        final reply = result.data['reply'] ?? 'I will have an expert get back to you shortly.';
        _messages.add({
          'sender': _agentName,
          'text': '$reply\n\n*AI generated; prone to errors. Trust but Verify. Human computations are final.*',
          'isUser': 'false'
        });
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _messages.add({
          'sender': 'System',
          'text': 'Connection issues. Reaching out to an admin for you...',
          'isUser': 'false'
        });
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        backgroundColor: const Color(0xFF161B22),
        elevation: 0,
        title: Row(
          children: [
            const Icon(Icons.auto_awesome, color: Colors.orange, size: 20),
            const SizedBox(width: 8),
            Text('Chat with $_agentName', style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg['isUser'] == 'true';
                
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.orange.withOpacity(0.2) : const Color(0xFF161B22),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: isUser ? Colors.orange.withOpacity(0.5) : Colors.white10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          msg['sender']!,
                          style: TextStyle(
                            color: isUser ? Colors.orange : Colors.white54,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          msg['text']!,
                          style: const TextStyle(color: Colors.white, fontSize: 15),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          if (_isLoading) const Padding(padding: EdgeInsets.all(8), child: CircularProgressIndicator(color: Colors.orange)),
          Container(
            padding: const EdgeInsets.all(12),
            color: const Color(0xFF161B22),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Ask $_agentName...',
                      hintStyle: const TextStyle(color: Colors.white24),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      fillColor: Colors.white.withOpacity(0.05),
                      filled: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: Colors.orange,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
