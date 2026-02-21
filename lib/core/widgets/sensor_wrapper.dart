import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/sensors/light_sensor_service.dart';
import '../services/sensors/shake_detector_service.dart';
import '../widgets/black_overlay.dart';
import '../../features/contact/presentation/pages/contact_page.dart';

class SensorWrapper extends ConsumerStatefulWidget {
  final Widget child;

  const SensorWrapper({
    super.key,
    required this.child,
  });

  @override
  ConsumerState<SensorWrapper> createState() => _SensorWrapperState();
}

class _SensorWrapperState extends ConsumerState<SensorWrapper> {
  LightSensorService? _lightSensorService;
  ShakeDetectorService? _shakeDetectorService;
  bool _showBlackOverlay = false;

  @override
  void initState() {
    super.initState();
    _initializeSensors();
  }

  void _initializeSensors() {
    _lightSensorService = LightSensorService(
      onOverlayStateChanged: (showOverlay) {
        if (mounted) {
          setState(() {
            _showBlackOverlay = showOverlay;
          });
        }
      },
    );
    _lightSensorService?.startMonitoring();

    _shakeDetectorService = ShakeDetectorService(
      onShakeDetected: _handleShakeDetected,
    );
    _shakeDetectorService?.startMonitoring();
  }

  void _handleShakeDetected() {
    if (!mounted) return;
    
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Shake detected! Opening contact page...'),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.green,
        ),
      );
      
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const ContactPage(),
            ),
          );
        }
      });
    } catch (e) {
    }
  }

  @override
  void dispose() {
    _lightSensorService?.dispose();
    _shakeDetectorService?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Stack(
        children: [
          widget.child,
          BlackOverlay(visible: _showBlackOverlay),
        ],
      ),
    );
  }
}
