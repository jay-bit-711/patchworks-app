import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';

Future<void> showRatingsDialog(BuildContext context, {required String projectId, required String step}) async {
  final controller = TextEditingController();
  int rating = 5;

  await showDialog(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        title: const Text('Rate Step'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<int>(
              value: 5,
              items: [1, 2, 3, 4, 5].map((e) => DropdownMenuItem(value: e, child: Text('$e'))).toList(),
              onChanged: (v) => rating = v ?? 5,
            ),
            TextField(controller: controller, decoration: const InputDecoration(labelText: 'Comment')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              await FirebaseFunctions.instance.httpsCallable('submitRating').call({
                'project_id': projectId,
                'step': step,
                'rating': rating,
                'comment': controller.text.trim(),
              });
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Rating submitted')));
              }
              Navigator.pop(ctx);
            },
            child: const Text('Submit'),
          )
        ],
      );
    },
  );

  controller.dispose();
}
