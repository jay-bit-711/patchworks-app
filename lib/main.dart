import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
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
import 'package:firebase_app_check/firebase_app_check.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
    return MaterialApp(
      title: 'Patchworks',
      theme: ThemeData(primarySwatch: Colors.orange),
      home: const SplashScreen(),
      routes: {
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