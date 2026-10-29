import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/role_select_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const MyApp());
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
        scaffoldBackgroundColor: const Color(0xFF121212),
        primaryColor: const Color(0xFFFF7A00),
        useMaterial3: true,
      ),
      home: const RoleSelectScreen(),
    );
  }
}
