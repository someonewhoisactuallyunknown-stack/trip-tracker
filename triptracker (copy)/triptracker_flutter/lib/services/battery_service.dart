import 'dart:async';
import 'package:battery_plus/battery_plus.dart';

class BatteryService {
  final Battery _battery = Battery();
  StreamSubscription<BatteryState>? _batteryStateSubscription;
  int _currentLevel = 100;
  BatteryState _currentState = BatteryState.full;

  Future<int> getBatteryLevel() async {
    try {
      _currentLevel = await _battery.batteryLevel;
      return _currentLevel;
    } catch (e) {
      return 100;
    }
  }

  Future<BatteryState> getBatteryState() async {
    try {
      _currentState = await _battery.batteryState;
      return _currentState;
    } catch (e) {
      return BatteryState.full;
    }
  }

  void startMonitoring(Function(int level, BatteryState state) onBatteryChange) {
    _batteryStateSubscription = _battery.onBatteryStateChanged.listen((state) async {
      _currentState = state;
      final level = await getBatteryLevel();
      _currentLevel = level;
      onBatteryChange(level, state);
    });

    Timer.periodic(const Duration(minutes: 1), (timer) async {
      final level = await getBatteryLevel();
      if (level != _currentLevel) {
        _currentLevel = level;
        onBatteryChange(level, _currentState);
      }
    });
  }

  void stopMonitoring() {
    _batteryStateSubscription?.cancel();
    _batteryStateSubscription = null;
  }

  int get currentLevel => _currentLevel;
  BatteryState get currentState => _currentState;

  bool isLowBattery() {
    return _currentLevel < 15;
  }

  bool isCriticalBattery() {
    return _currentLevel < 10;
  }

  void dispose() {
    stopMonitoring();
  }
}
