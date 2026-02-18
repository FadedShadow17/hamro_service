import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/sensors/light_sensor_service.dart';
import '../services/sensors/shake_detector_service.dart';
import '../../features/auth/presentation/widgets/logout_confirmation_dialog.dart';
import '../../features/auth/presentation/view_model/auth_viewmodel.dart';
import '../../features/auth/presentation/pages/login_page.dart';

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

  @override
  void initState() {
    super.initState();
    _initializeSensors();
  }

  void _initializeSensors() {
    _lightSensorService = LightSensorService();
    _lightSensorService?.startMonitoring();

    _shakeDetectorService = ShakeDetectorService(
      onShakeDetected: _handleShakeDetected,
    );
    _shakeDetectorService?.startMonitoring();
  }

  void _handleShakeDetected() {
    final authState = ref.read(authViewModelProvider);
    
    if (authState.isAuthenticated) {
      final navigator = Navigator.of(context);
      LogoutConfirmationDialog.show(context).then((confirmed) {
        if (confirmed == true) {
          ref.read(authViewModelProvider.notifier).logout().then((_) {
            if (mounted) {
              navigator.pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginPage()),
                (route) => false,
              );
            }
          });
        }
      });
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
    return widget.child;
  }
}
