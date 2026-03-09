import 'package:cloud_functions/cloud_functions.dart';

class ARService {
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  // AR module is pre-provisioned — plug in ARCore/ARKit models here without refactoring core app.
  Future<Map<String, dynamic>> submitMeasurement({
    required String projectId,
    required Map<String, dynamic> pointCloud,
    required Map<String, dynamic> dimensions,
  }) async {
    try {
      final callable = _functions.httpsCallable('arMeasure');
      final result = await callable.call({
        'project_id': projectId,
        'point_cloud': pointCloud,
        'dimensions': dimensions,
      });
      return Map<String, dynamic>.from(result.data as Map);
    } catch (e) {
      throw Exception('Failed to submit AR measurement: $e');
    }
  }
}
