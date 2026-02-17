import 'dart:convert';

import 'package:confetti/confetti.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

const String kApiBaseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: 'http://10.0.2.2:8000/api');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'AIzaSyD0RMJkSGcGn5lWhwRzOv4PdNaQinHA0DU',
      appId: '1:673105079152:android:patchworks3178f',
      messagingSenderId: '673105079152',
      projectId: 'patchworks-3178f',
      storageBucket: 'patchworks-3178f.firebasestorage.app',
    ),
  );
  runApp(const PatchworksApp());
}

class PatchworksApp extends StatefulWidget {
  const PatchworksApp({super.key});

  @override
  State<PatchworksApp> createState() => _PatchworksAppState();
}

class _PatchworksAppState extends State<PatchworksApp> {
  bool telugu = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Patchworks',
      theme: ThemeData(colorSchemeSeed: Colors.orange, useMaterial3: true),
      home: AuthGate(
        telugu: telugu,
        onToggleLanguage: () => setState(() => telugu = !telugu),
      ),
    );
  }
}

class ApiClient {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<Map<String, dynamic>> syncUser() async {
    final token = await _auth.currentUser?.getIdToken(true);
    final response = await http.get(
      Uri.parse('$kApiBaseUrl/auth/sync/'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to sync user: ${response.body}');
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<List<dynamic>> listJobs() async {
    final token = await _auth.currentUser?.getIdToken(true);
    final response = await http.get(
      Uri.parse('$kApiBaseUrl/jobs/'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode != 200) throw Exception(response.body);
    final decoded = jsonDecode(response.body);
    if (decoded is List<dynamic>) return decoded;
    if (decoded is Map<String, dynamic> && decoded['results'] is List<dynamic>) {
      return decoded['results'] as List<dynamic>;
    }
    throw Exception('Unexpected jobs response format');
  }

  Future<void> createJob(String description, String location) async {
    final token = await _auth.currentUser?.getIdToken(true);
    final response = await http.post(
      Uri.parse('$kApiBaseUrl/jobs/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'description': description, 'location': location}),
    );
    if (response.statusCode != 201) throw Exception(response.body);
  }

  Future<void> acceptJob(int jobId) async {
    final token = await _auth.currentUser?.getIdToken(true);
    final response = await http.post(
      Uri.parse('$kApiBaseUrl/jobs/$jobId/accept/'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode != 200) throw Exception(response.body);
  }

  Future<void> updateJobStatus(int jobId, String status) async {
    final token = await _auth.currentUser?.getIdToken(true);
    final response = await http.patch(
      Uri.parse('$kApiBaseUrl/jobs/$jobId/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'status': status}),
    );
    if (response.statusCode != 200) throw Exception(response.body);
  }

  Future<void> uploadEvidence(int jobId, PlatformFile file, bool isBefore) async {
    final token = await _auth.currentUser?.getIdToken(true);
    final request = http.MultipartRequest('POST', Uri.parse('$kApiBaseUrl/evidence/upload/'));
    request.headers['Authorization'] = 'Bearer $token';
    request.fields['job_id'] = jobId.toString();
    request.fields['is_before'] = isBefore.toString();
    request.files.add(await http.MultipartFile.fromPath('file', file.path!));

    final streamed = await request.send();
    final responseBody = await streamed.stream.bytesToString();
    if (streamed.statusCode != 201) throw Exception(responseBody);
  }

  Future<void> rateJob(int jobId, String rating) async {
    final token = await _auth.currentUser?.getIdToken(true);
    final response = await http.post(
      Uri.parse('$kApiBaseUrl/jobs/$jobId/rate/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'rating': rating}),
    );
    if (response.statusCode != 201) throw Exception(response.body);
  }

  Future<List<dynamic>> listUsers() async {
    final token = await _auth.currentUser?.getIdToken(true);
    final response = await http.get(
      Uri.parse('$kApiBaseUrl/admin/users/'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode != 200) throw Exception(response.body);
    final decoded = jsonDecode(response.body);
    if (decoded is List<dynamic>) return decoded;
    if (decoded is Map<String, dynamic> && decoded['results'] is List<dynamic>) {
      return decoded['results'] as List<dynamic>;
    }
    throw Exception('Unexpected users response format');
  }

  Future<void> upgradeRole(int userId, String role) async {
    final token = await _auth.currentUser?.getIdToken(true);
    final response = await http.post(
      Uri.parse('$kApiBaseUrl/admin/users/$userId/upgrade/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'role': role}),
    );
    if (response.statusCode != 200) throw Exception(response.body);
  }
}

class AuthGate extends StatefulWidget {
  final bool telugu;
  final VoidCallback onToggleLanguage;
  const AuthGate({super.key, required this.telugu, required this.onToggleLanguage});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final api = ApiClient();
  bool loading = true;
  String? error;
  Map<String, dynamic>? me;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          loading = false;
          me = null;
        });
        return;
      }
      final synced = await api.syncUser();
      setState(() {
        me = synced;
        loading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        loading = false;
      });
    }
  }

  Future<void> _signIn() async {
    try {
      final signIn = GoogleSignIn(
        clientId: '673105079152-4agabm9r7msc17bj4it0ffcmhcb25ebi.apps.googleusercontent.com',
      );
      final googleUser = await signIn.signIn();
      if (googleUser == null) return;
      final auth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        idToken: auth.idToken,
        accessToken: auth.accessToken,
      );
      await FirebaseAuth.instance.signInWithCredential(credential);
      await _load();
    } catch (e) {
      setState(() => error = e.toString());
    }
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    await GoogleSignIn().signOut();
    setState(() => me = null);
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (me == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Patchworks')),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(widget.telugu ? 'ఇంటి రిపేర్, ఫాస్ట్ ✅' : 'Home repair, fast ✅', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 24),
              ElevatedButton(onPressed: _signIn, child: Text(widget.telugu ? 'Google తో లాగిన్' : 'Login with Google')),
              const SizedBox(height: 12),
              OutlinedButton(onPressed: widget.onToggleLanguage, child: Text(widget.telugu ? 'English' : 'తెలుగు')),
              if (error != null) Padding(padding: const EdgeInsets.only(top: 12), child: Text(error!, style: const TextStyle(color: Colors.red))),
            ],
          ),
        ),
      );
    }

    return Dashboard(
      me: me!,
      telugu: widget.telugu,
      onToggleLanguage: widget.onToggleLanguage,
      onLogout: _logout,
    );
  }
}

class Dashboard extends StatefulWidget {
  final Map<String, dynamic> me;
  final bool telugu;
  final VoidCallback onToggleLanguage;
  final VoidCallback onLogout;

  const Dashboard({
    super.key,
    required this.me,
    required this.telugu,
    required this.onToggleLanguage,
    required this.onLogout,
  });

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int tab = 0;

  @override
  Widget build(BuildContext context) {
    final role = widget.me['role'] as String? ?? 'homeowner';
    final pages = <Widget>[
      JobsPage(role: role, telugu: widget.telugu),
      if (role == 'homeowner') CreateJobPage(telugu: widget.telugu),
      if (role == 'admin' || role == 'superadmin') AdminUsersPage(role: role),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Patchworks • ${widget.me['role']}'),
        actions: [
          IconButton(onPressed: widget.onToggleLanguage, icon: const Icon(Icons.translate)),
          IconButton(onPressed: widget.onLogout, icon: const Icon(Icons.logout)),
        ],
      ),
      body: pages[tab],
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab,
        onDestinationSelected: (v) => setState(() => tab = v),
        destinations: [
          NavigationDestination(icon: const Icon(Icons.home_repair_service), label: widget.telugu ? 'జాబ్స్' : 'Jobs'),
          if (role == 'homeowner') NavigationDestination(icon: const Icon(Icons.add_circle), label: widget.telugu ? 'పోస్ట్' : 'Post'),
          if (role == 'admin' || role == 'superadmin') const NavigationDestination(icon: Icon(Icons.admin_panel_settings), label: 'Admin'),
        ],
      ),
    );
  }
}

class JobsPage extends StatefulWidget {
  final String role;
  final bool telugu;
  const JobsPage({super.key, required this.role, required this.telugu});

  @override
  State<JobsPage> createState() => _JobsPageState();
}

class _JobsPageState extends State<JobsPage> {
  final api = ApiClient();
  final confetti = ConfettiController(duration: const Duration(seconds: 1));
  bool loading = true;
  String? error;
  List<dynamic> jobs = [];

  @override
  void initState() {
    super.initState();
    refresh();
  }

  @override
  void dispose() {
    confetti.dispose();
    super.dispose();
  }

  Future<void> refresh() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final data = await api.listJobs();
      setState(() {
        jobs = data;
        loading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        loading = false;
      });
    }
  }

  Future<void> onAccept(int jobId) async {
    await api.acceptJob(jobId);
    await HapticFeedback.mediumImpact();
    confetti.play();
    await refresh();
  }

  Future<void> onStatus(int jobId, String status) async {
    await api.updateJobStatus(jobId, status);
    await HapticFeedback.lightImpact();
    await refresh();
  }

  Future<void> onUpload(int jobId) async {
    final result = await FilePicker.platform.pickFiles(withData: false);
    if (result == null || result.files.isEmpty) return;
    final file = result.files.first;
    await api.uploadEvidence(jobId, file, true);
    await HapticFeedback.mediumImpact();
    await refresh();
  }

  Future<void> onRate(int jobId, String rating) async {
    await api.rateJob(jobId, rating);
    await HapticFeedback.heavyImpact();
    confetti.play();
    await refresh();
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator());
    if (error != null) return Center(child: Text(error!));

    return Stack(
      alignment: Alignment.topCenter,
      children: [
        RefreshIndicator(
          onRefresh: refresh,
          child: ListView.builder(
            itemCount: jobs.length,
            itemBuilder: (context, index) {
              final job = jobs[index] as Map<String, dynamic>;
              final evidences = (job['evidences'] as List<dynamic>? ?? []);
              final createdAt = DateTime.tryParse(job['created_at'] ?? '') ?? DateTime.now();
              return Card(
                margin: const EdgeInsets.all(10),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(job['description'] ?? '-', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 4),
                      Text('${job['location']} • ${job['status']}'),
                      Text(DateFormat('dd MMM, hh:mm a').format(createdAt)),
                      Text('Evidence: ${evidences.length}/2'),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          OutlinedButton.icon(onPressed: () => onUpload(job['id'] as int), icon: const Icon(Icons.camera_alt), label: const Text('Upload')),
                          if (widget.role == 'mestri' && job['assigned_mestri'] == null)
                            ElevatedButton(onPressed: () => onAccept(job['id'] as int), child: const Text('Accept')),
                          if (widget.role == 'mestri')
                            OutlinedButton(onPressed: () => onStatus(job['id'] as int, 'done'), child: Text(widget.telugu ? 'పూర్తి' : 'Done')),
                          if (widget.role == 'homeowner' && job['status'] == 'done')
                            IconButton(onPressed: () => onRate(job['id'] as int, 'like'), icon: const Text('👍', style: TextStyle(fontSize: 20))),
                          if (widget.role == 'homeowner' && job['status'] == 'done')
                            IconButton(onPressed: () => onRate(job['id'] as int, 'dislike'), icon: const Text('👎', style: TextStyle(fontSize: 20))),
                          if (widget.role == 'mestri' && job['status'] == 'done')
                            IconButton(onPressed: () => onRate(job['id'] as int, 'like'), icon: const Text('👍', style: TextStyle(fontSize: 20))),
                          if (widget.role == 'mestri' && job['status'] == 'done')
                            IconButton(onPressed: () => onRate(job['id'] as int, 'dislike'), icon: const Text('👎', style: TextStyle(fontSize: 20))),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        ConfettiWidget(confettiController: confetti, blastDirectionality: BlastDirectionality.explosive),
      ],
    );
  }
}

class CreateJobPage extends StatefulWidget {
  final bool telugu;
  const CreateJobPage({super.key, required this.telugu});

  @override
  State<CreateJobPage> createState() => _CreateJobPageState();
}

class _CreateJobPageState extends State<CreateJobPage> {
  final api = ApiClient();
  final descCtrl = TextEditingController();
  final locCtrl = TextEditingController(text: 'Hyderabad');
  final confetti = ConfettiController(duration: const Duration(seconds: 1));
  bool loading = false;
  String? message;

  @override
  void dispose() {
    descCtrl.dispose();
    locCtrl.dispose();
    confetti.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    if (descCtrl.text.trim().isEmpty) return;
    setState(() => loading = true);
    try {
      await api.createJob(descCtrl.text.trim(), locCtrl.text.trim());
      await HapticFeedback.mediumImpact();
      confetti.play();
      setState(() {
        message = widget.telugu ? 'జాబ్ సక్సెస్ ✅' : 'Job posted ✅';
        loading = false;
        descCtrl.clear();
      });
    } catch (e) {
      setState(() {
        message = e.toString();
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(widget.telugu ? 'కొత్త జాబ్' : 'Post New Job', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            TextField(controller: descCtrl, decoration: InputDecoration(labelText: widget.telugu ? 'సమస్య' : 'Problem description')),
            const SizedBox(height: 12),
            TextField(controller: locCtrl, decoration: InputDecoration(labelText: widget.telugu ? 'లొకేషన్' : 'Location')),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: loading ? null : submit,
              icon: const Icon(Icons.send),
              label: Text(widget.telugu ? 'పోస్ట్ చేయి' : 'Post Job'),
            ),
            if (message != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(message!, style: const TextStyle(fontWeight: FontWeight.w600)),
              ),
          ],
        ),
        ConfettiWidget(confettiController: confetti, blastDirectionality: BlastDirectionality.explosive),
      ],
    );
  }
}

class AdminUsersPage extends StatefulWidget {
  final String role;
  const AdminUsersPage({super.key, required this.role});

  @override
  State<AdminUsersPage> createState() => _AdminUsersPageState();
}

class _AdminUsersPageState extends State<AdminUsersPage> {
  final api = ApiClient();
  List<dynamic> users = [];
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    refresh();
  }

  Future<void> refresh() async {
    try {
      final data = await api.listUsers();
      setState(() {
        users = data;
        loading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        loading = false;
      });
    }
  }

  Future<void> onUpgrade(int userId, String role) async {
    try {
      await api.upgradeRole(userId, role);
      await HapticFeedback.lightImpact();
      await refresh();
    } catch (e) {
      setState(() => error = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator());
    if (error != null) return Center(child: Text(error!));

    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index] as Map<String, dynamic>;
        return ListTile(
          title: Text(user['email']?.toString().isNotEmpty == true ? user['email'] : user['username']),
          subtitle: Text('Role: ${user['role']}'),
          trailing: PopupMenuButton<String>(
            onSelected: (role) => onUpgrade(user['id'] as int, role),
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'homeowner', child: Text('homeowner')),
              PopupMenuItem(value: 'mestri', child: Text('mestri')),
              PopupMenuItem(value: 'admin', child: Text('admin')),
              PopupMenuItem(value: 'superadmin', child: Text('superadmin')),
            ],
          ),
        );
      },
    );
  }
}
