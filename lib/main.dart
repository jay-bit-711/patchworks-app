import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'services/auth_service.dart';
import 'screens/splash_screen.dart';
import 'screens/role_login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/job_create_screen.dart';
import 'screens/evidence_capture_screen.dart';
import 'screens/project_dashboard_screen.dart';
import 'screens/agent_chat_screen.dart';
import 'screens/pre_login_onboarding.dart';
import 'package:firebase_app_check/firebase_app_check.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation to portrait for a professional look
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.debug,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthService>(
          create: (_) => AuthService(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Patchworks',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.orange,
        scaffoldBackgroundColor: const Color(0xFF0D1117),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
      routes: {
        '/onboarding': (_) => const PreLoginOnboarding(),
        '/login': (_) => const RoleLoginScreen(),
        '/home': (_) => const HomeScreen(),
        '/jobs/create': (_) => const JobCreateScreen(),
        '/evidence/capture': (_) => const EvidenceCaptureScreen(),
        '/dashboard': (_) => const ProjectDashboardScreen(),
        '/chat/vijay': (_) => const AgentChatScreen(agentId: 'vijay'),
        '/chat/material': (_) => const AgentChatScreen(agentId: 'material'),
        '/chat/document_tracker': (_) => const AgentChatScreen(agentId: 'document_tracker'),
      },
    );
  }
}
