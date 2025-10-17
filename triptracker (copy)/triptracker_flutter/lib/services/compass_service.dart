import 'dart:async';
import 'package:flutter_compass/flutter_compass.dart';

class CompassService {
  StreamSubscription<CompassEvent>? _compassSubscription;
  double _currentHeading = 0;

  void startListening(Function(double heading) onHeadingChange) {
    _compassSubscription = FlutterCompass.events?.listen((event) {
      if (event.heading != null) {
        _currentHeading = event.heading!;
        onHeadingChange(_currentHeading);
      }
    });
  }

  void stopListening() {
    _compassSubscription?.cancel();
    _compassSubscription = null;
  }

  double get currentHeading => _currentHeading;

  static double calculateDirectionArrow(
    double deviceHeading,
    double targetBearing,
  ) {
    double direction = targetBearing - deviceHeading;

    if (direction < 0) {
      direction += 360;
    }
    if (direction > 360) {
      direction -= 360;
    }

    return direction;
  }

  void dispose() {
    stopListening();
  }
}
