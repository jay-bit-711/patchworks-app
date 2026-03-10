import 'package:flutter_test/flutter_test.dart';
import 'package:patchworks/models/job.dart';

void main() {
  group('Job Model Tests', () {
    test('Job model should initialize correctly', () {
      final now = DateTime.now();
      final job = Job(
        id: 'test_1',
        title: '11 Floor Construction',
        description: 'High-rise residential project in KPHB.',
        dateTime: now,
        quoteStatus: '₹2,500/sqft',
        materialsIncluded: true,
        status: JobStatus.created,
        jobNumber: 101,
        locationHash: 'hyd_kphb_01',
        homeownerId: 'owner_123',
      );

      expect(job.title, '11 Floor Construction');
      expect(job.status, JobStatus.created);
      expect(job.jobNumber, 101);
    });

    test('JobStatus enum should have correct values', () {
      expect(JobStatus.values.length, 5);
      expect(JobStatus.created.name, 'created');
      expect(JobStatus.completed.name, 'completed');
    });
  });
}
