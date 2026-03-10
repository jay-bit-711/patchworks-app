import 'package:cloud_firestore/cloud_firestore.dart';

enum JobStatus { created, assigned, inProgress, completed, disputed }

class JobEvidence {
  final String url;
  final String type; // 'image' or 'video'

  JobEvidence({required this.url, required this.type});
}

class Job {
  final String id;
  final String title;
  final String description;
  final DateTime dateTime;
  final String quoteStatus;
  final bool materialsIncluded;
  final JobStatus status;
  final String? imageUrl;
  final int jobNumber;
  final String locationHash; 
  final String homeownerId;
  final String? assignedWorkerId;
  final double? latitude;
  final double? longitude;
  final List<JobEvidence> evidence;

  Job({
    required this.id,
    required this.title,
    required this.description,
    required this.dateTime,
    required this.quoteStatus,
    required this.materialsIncluded,
    required this.status,
    this.imageUrl,
    required this.jobNumber,
    required this.locationHash,
    required this.homeownerId,
    this.assignedWorkerId,
    this.latitude,
    this.longitude,
    this.evidence = const [],
  });

  factory Job.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    
    var evidenceList = (data['evidence'] as List? ?? []).map((e) {
      return JobEvidence(url: e['url'], type: e['type']);
    }).toList();

    return Job(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      dateTime: (data['dateTime'] as Timestamp).toDate(),
      quoteStatus: data['quoteStatus'] ?? 'Pending',
      materialsIncluded: data['materialsIncluded'] ?? false,
      status: JobStatus.values.firstWhere((e) => e.toString() == 'JobStatus.${data['status']}'),
      imageUrl: data['imageUrl'],
      jobNumber: data['jobNumber'] ?? 0,
      locationHash: data['locationHash'] ?? '',
      homeownerId: data['homeownerId'] ?? '',
      assignedWorkerId: data['assignedWorkerId'],
      latitude: data['latitude'],
      longitude: data['longitude'],
      evidence: evidenceList,
    );
  }
}
