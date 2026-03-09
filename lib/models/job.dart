enum JobStatus { created, assigned, completed }

class Job {
  final String id;
  final String title;
  final DateTime dateTime;
  final String quoteStatus;
  final bool materialsIncluded;
  final JobStatus status;
  final String? imageUrl;
  final int jobNumber;

  Job({
    required this.id,
    required this.title,
    required this.dateTime,
    required this.quoteStatus,
    required this.materialsIncluded,
    required this.status,
    this.imageUrl,
    required this.jobNumber,
  });
}
