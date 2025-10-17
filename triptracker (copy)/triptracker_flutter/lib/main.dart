import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/login_screen.dart';
import 'screens/splash_screen.dart';
import 'services/code_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final codeService = CodeService();
  runApp(MyApp(codeService: codeService));
}

class MyApp extends StatelessWidget {
  final CodeService codeService;
  const MyApp({super.key, required this.codeService});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<CodeService>.value(value: codeService),
      ],
      child: MaterialApp(
        title: 'Triptracker - IRSHAD HS',
        theme: ThemeData(
          primaryColor: const Color(0xFF0057B7),
          colorScheme: ColorScheme.fromSwatch().copyWith(primary: const Color(0xFF0057B7)),
        ),
        home: const SplashScreen(),
      ),
    );
  }
}
