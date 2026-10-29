import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class UpiService {
  // Point to your FastAPI backend
  static const String baseUrl = 'http://localhost:8000'; // change for prod

  Future<Map<String, dynamic>> initiate({
    required int jobId,
    required int customerId,
    required int proId,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/site-visit/initiate'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'job_id': jobId,
        'customer_id': customerId,
        'pro_id': proId,
      }),
    );
    if (res.statusCode != 200) throw Exception('Initiate failed');
    return jsonDecode(res.body);
  }

  Future<void> openUpi(String upiLink) async {
    final uri = Uri.parse(upiLink);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw Exception('No UPI app found');
    }
  }

  Future<Map<String, dynamic>> confirm({
    required String siteVisitId,
    required String party, // 'customer' or 'pro'
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/site-visit/confirm'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'site_visit_id': siteVisitId,
        'party': party,
      }),
    );
    if (res.statusCode != 200) throw Exception('Confirm failed');
    return jsonDecode(res.body);
  }

  Future<Map<String, dynamic>> status(String siteVisitId) async {
    final res = await http.get(
      Uri.parse('$baseUrl/site-visit/$siteVisitId/status'),
    );
    if (res.statusCode != 200) throw Exception('Status failed');
    return jsonDecode(res.body);
  }
}
