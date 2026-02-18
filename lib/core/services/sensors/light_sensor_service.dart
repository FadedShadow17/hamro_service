import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:screen_brightness/screen_brightness.dart';

class LightSensorService with WidgetsBindingObserver {
  double? _originalBrightness;
  bool _isScreenBlack = false;
  Timer? _monitoringTimer;
  bool _isAppInBackground = false;
  Function(bool)? onOverlayStateChanged;

  LightSensorService({this.onOverlayStateChanged});

  Future<void> startMonitoring() async {
    WidgetsBinding.instance.addObserver(this);
    
    try {
      _originalBrightness = await ScreenBrightness().current;
    } catch (e) {
      print('[LightSensor] Failed to get current brightness: $e');
    }

    _monitoringTimer = Timer.periodic(const Duration(milliseconds: 200), (_) {
      if (!_isAppInBackground) {
        _checkScreenBrightness();
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      _isAppInBackground = true;
      _turnScreenBlack();
    } else if (state == AppLifecycleState.resumed) {
      _isAppInBackground = false;
      Future.delayed(const Duration(milliseconds: 100), () {
        _restoreBrightness();
      });
    }
  }

  Future<void> _checkScreenBrightness() async {
    try {
      final currentBrightness = await ScreenBrightness().current;
      
      if (currentBrightness < 0.01 && !_isScreenBlack) {
        await _turnScreenBlack();
      } else if (currentBrightness >= 0.01 && _isScreenBlack && _originalBrightness != null) {
        await _restoreBrightness();
      }
    } catch (e) {
      print('[LightSensor] Error checking brightness: $e');
    }
  }

  Future<void> _turnScreenBlack() async {
    if (_isScreenBlack) return;
    
    try {
      if (_originalBrightness == null) {
        _originalBrightness = await ScreenBrightness().current;
      }
      await ScreenBrightness().setScreenBrightness(0.0);
      _isScreenBlack = true;
      onOverlayStateChanged?.call(true);
    } catch (e) {
      print('[LightSensor] Failed to set brightness to 0: $e');
    }
  }

  Future<void> _restoreBrightness() async {
    if (!_isScreenBlack) return;
    
    try {
      if (_originalBrightness != null && _originalBrightness! > 0) {
        await ScreenBrightness().setScreenBrightness(_originalBrightness!);
      } else {
        await ScreenBrightness().resetScreenBrightness();
      }
      _isScreenBlack = false;
      onOverlayStateChanged?.call(false);
    } catch (e) {
      print('[LightSensor] Failed to restore brightness: $e');
    }
  }

  Future<void> stopMonitoring() async {
    WidgetsBinding.instance.removeObserver(this);
    _monitoringTimer?.cancel();
    if (_isScreenBlack) {
      await _restoreBrightness();
    }
  }

  void dispose() {
    stopMonitoring();
  }
}
