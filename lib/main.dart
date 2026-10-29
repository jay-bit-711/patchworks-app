import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/upi_fee_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Firebase commented for local UI test (keys expired)
  // await Firebase.initializeApp(...);

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
      home: const UpiFeeScreen(
        jobId: 1,
        customerId: 1,
        proId: 2,
        party: 'customer',
      ),
    );
  }
}
