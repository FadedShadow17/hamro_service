import 'dart:async';
import 'dart:math';
import 'package:sensors_plus/sensors_plus.dart';

class ShakeDetectorService {
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  final Function() onShakeDetected;
  final double _shakeThreshold = 12.0;
  final int _shakeWindowMs = 200;
  final int _minShakeCount = 2;

  List<DateTime> _shakeEvents = [];
  DateTime? _lastShakeTime;
  bool _isProcessing = false;

  ShakeDetectorService({required this.onShakeDetected});

  void startMonitoring() {
    _accelerometerSubscription = accelerometerEventStream().listen(
      (AccelerometerEvent event) {
        _handleAccelerometerEvent(event);
      },
      onError: (error) {
        print('[ShakeDetector] Error: $error');
      },
    );
  }

  void _handleAccelerometerEvent(AccelerometerEvent event) {
    if (_isProcessing) return;

    final magnitude = _calculateMagnitude(event.x, event.y, event.z);

    if (magnitude > _shakeThreshold) {
      final now = DateTime.now();
      
      if (_lastShakeTime == null || 
          now.difference(_lastShakeTime!).inMilliseconds > _shakeWindowMs) {
        _shakeEvents.clear();
      }

      _shakeEvents.add(now);
      _lastShakeTime = now;

      if (_shakeEvents.length >= _minShakeCount) {
        final timeSpan = _shakeEvents.last.difference(_shakeEvents.first);
        if (timeSpan.inMilliseconds <= _shakeWindowMs) {
          _isProcessing = true;
          _shakeEvents.clear();
          _lastShakeTime = null;
          
          Future.delayed(const Duration(milliseconds: 2000), () {
            _isProcessing = false;
          });

          onShakeDetected();
        }
      }
    }
  }

  double _calculateMagnitude(double x, double y, double z) {
    return sqrt(x * x + y * y + z * z);
  }

  void stopMonitoring() {
    _accelerometerSubscription?.cancel();
    _shakeEvents.clear();
    _lastShakeTime = null;
    _isProcessing = false;
  }

  void dispose() {
    stopMonitoring();
  }
}
