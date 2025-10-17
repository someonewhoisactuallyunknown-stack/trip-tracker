import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import '../services/location_service.dart';
import '../services/battery_service.dart';
import '../services/compass_service.dart';
import 'package:geolocator/geolocator.dart';

class AppState extends ChangeNotifier {
  final SupabaseService supabaseService;
  final LocationService locationService;
  final BatteryService batteryService;
  final CompassService compassService;

  Map<String, dynamic>? _currentUser;
  bool _isOfflineMode = false;
  Position? _currentPosition;
  int _batteryLevel = 100;
  double _compassHeading = 0;

  AppState({
    required this.supabaseService,
    required this.locationService,
    required this.batteryService,
    required this.compassService,
  }) {
    _initialize();
  }

  void _initialize() {
    batteryService.startMonitoring((level, state) {
      _batteryLevel = level;
      if (_currentUser != null) {
        supabaseService.updateBattery(_currentUser!['id'], level);
      }
      notifyListeners();
    });

    compassService.startListening((heading) {
      _compassHeading = heading;
      notifyListeners();
    });
  }

  Map<String, dynamic>? get currentUser => _currentUser;
  bool get isOfflineMode => _isOfflineMode;
  Position? get currentPosition => _currentPosition;
  int get batteryLevel => _batteryLevel;
  double get compassHeading => _compassHeading;

  bool get isDeveloper => _currentUser?['role'] == 'developer';
  bool get isTeacher => _currentUser?['role'] == 'teacher';
  bool get isStudent => _currentUser?['role'] == 'student';

  Future<bool> login(String code) async {
    final user = await supabaseService.loginWithCode(code);
    if (user != null) {
      _currentUser = user;
      await _startTracking();
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<void> _startTracking() async {
    final hasPermission = await locationService.checkPermissions();
    if (!hasPermission) {
      await locationService.requestPermissions();
    }

    locationService.startTracking((position) {
      _currentPosition = position;
      if (_currentUser != null) {
        supabaseService.updateLocation(
          _currentUser!['id'],
          position.latitude,
          position.longitude,
          position.accuracy,
          _compassHeading,
          _isOfflineMode,
        );
      }
      notifyListeners();
    });

    _currentPosition = await locationService.getCurrentLocation();
    _batteryLevel = await batteryService.getBatteryLevel();
    notifyListeners();
  }

  void toggleOfflineMode() {
    _isOfflineMode = !_isOfflineMode;
    notifyListeners();
  }

  Future<void> sendEmergencyAlert() async {
    if (_currentUser == null) return;

    String? teacherId;
    if (_currentUser!['group_id'] != null) {
      final teacher = await supabaseService.client
          .from('users')
          .select('id')
          .eq('group_id', _currentUser!['group_id'])
          .eq('role', 'teacher')
          .maybeSingle();

      teacherId = teacher?['id'];
    }

    await supabaseService.sendAlert(
      _currentUser!['id'],
      teacherId,
      'emergency',
      'EMERGENCY! ${_currentUser!['name']} needs help!',
      _currentPosition?.latitude,
      _currentPosition?.longitude,
      _batteryLevel,
    );
  }

  void logout() {
    locationService.stopTracking();
    _currentUser = null;
    _currentPosition = null;
    notifyListeners();
  }

  @override
  void dispose() {
    locationService.dispose();
    batteryService.dispose();
    compassService.dispose();
    super.dispose();
  }
}
