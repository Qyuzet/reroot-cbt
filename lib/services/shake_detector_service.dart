import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:sensors_plus/sensors_plus.dart';

class ShakeDetectorService {
  // Minimum acceleration needed to count as a shake
  static const double _shakeThreshold = 2.7;
  
  // Minimum time between shakes (to avoid multiple detections)
  static const int _minTimeBetweenShakes = 1000; // milliseconds
  
  // Subscription to accelerometer events
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  
  // Callback for when shake is detected
  final Function() onShake;
  
  // Last time a shake was detected
  DateTime _lastShakeTime = DateTime.now();
  
  // Last accelerometer values
  double _lastX = 0.0;
  double _lastY = 0.0;
  double _lastZ = 0.0;
  
  // Constructor
  ShakeDetectorService({required this.onShake});
  
  // Start listening for shake events
  void startListening() {
    _accelerometerSubscription = accelerometerEvents.listen((AccelerometerEvent event) {
      _detectShake(event);
    });
    debugPrint('Shake detector started');
  }
  
  // Stop listening for shake events
  void stopListening() {
    _accelerometerSubscription?.cancel();
    _accelerometerSubscription = null;
    debugPrint('Shake detector stopped');
  }
  
  // Detect if a shake occurred
  void _detectShake(AccelerometerEvent event) {
    final DateTime now = DateTime.now();
    
    // If we're within the cooldown period, ignore this shake
    if (now.difference(_lastShakeTime).inMilliseconds < _minTimeBetweenShakes) {
      return;
    }
    
    // Calculate the difference from the last reading
    double deltaX = event.x - _lastX;
    double deltaY = event.y - _lastY;
    double deltaZ = event.z - _lastZ;
    
    // Update last values
    _lastX = event.x;
    _lastY = event.y;
    _lastZ = event.z;
    
    // Calculate the magnitude of the acceleration
    double acceleration = (deltaX * deltaX + deltaY * deltaY + deltaZ * deltaZ) 
                          / (9.80665 * 9.80665); // Normalized to g-force
    
    // If acceleration is above threshold, it's a shake
    if (acceleration > _shakeThreshold) {
      _lastShakeTime = now;
      debugPrint('Shake detected! Acceleration: $acceleration');
      onShake();
    }
  }
  
  // Dispose resources
  void dispose() {
    stopListening();
  }
}
