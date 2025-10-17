import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/login_screen.dart';
import 'screens/splash_screen.dart';
import 'services/code_service.dart';
import 'services/supabase_service.dart';
import 'services/location_service.dart';
import 'services/battery_service.dart';
import 'services/compass_service.dart';
import 'providers/app_state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final supabaseService = await SupabaseService.getInstance();
  final locationService = LocationService();
  final batteryService = BatteryService();
  final compassService = CompassService();
  final codeService = CodeService(supabaseService);

  runApp(MyApp(
    supabaseService: supabaseService,
    locationService: locationService,
    batteryService: batteryService,
    compassService: compassService,
    codeService: codeService,
  ));
}

class MyApp extends StatelessWidget {
  final SupabaseService supabaseService;
  final LocationService locationService;
  final BatteryService batteryService;
  final CompassService compassService;
  final CodeService codeService;

  const MyApp({
    super.key,
    required this.supabaseService,
    required this.locationService,
    required this.batteryService,
    required this.compassService,
    required this.codeService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<CodeService>.value(value: codeService),
        Provider<SupabaseService>.value(value: supabaseService),
        ChangeNotifierProvider(
          create: (_) => AppState(
            supabaseService: supabaseService,
            locationService: locationService,
            batteryService: batteryService,
            compassService: compassService,
          ),
        ),
      ],
      child: MaterialApp(
        title: 'IRSHAD HIGH SCHOOL Trip Tracker',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: const Color(0xFF0057B7),
          colorScheme: ColorScheme.fromSwatch().copyWith(
            primary: const Color(0xFF0057B7),
            secondary: const Color(0xFF29ABE2),
          ),
          scaffoldBackgroundColor: Colors.white,
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF0057B7),
            foregroundColor: Colors.white,
            elevation: 0,
          ),
        ),
        home: const SplashScreen(),
      ),
    );
  }
}
