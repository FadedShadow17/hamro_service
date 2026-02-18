import 'package:flutter/material.dart';

class BlackOverlay extends StatelessWidget {
  final bool visible;

  const BlackOverlay({
    super.key,
    required this.visible,
  });

  @override
  Widget build(BuildContext context) {
    if (!visible) {
      return const SizedBox.shrink();
    }

    return IgnorePointer(
      ignoring: true,
      child: Container(
        color: Colors.black,
        width: double.infinity,
        height: double.infinity,
      ),
    );
  }
}
