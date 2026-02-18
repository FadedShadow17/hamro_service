import 'package:flutter/material.dart';

class ServiceIconHelper {
  static IconData getIconForService(String serviceName, String categoryTag) {
    final name = serviceName.toLowerCase();
    final category = categoryTag.toLowerCase();

    if (category.contains('plumbing') || category.contains('plumber') || name.contains('plumb')) {
      return Icons.plumbing;
    } else if (category.contains('electrical') || category.contains('electric') || name.contains('electric')) {
      return Icons.electrical_services;
    } else if (category.contains('cleaning') || category.contains('clean') || name.contains('clean')) {
      return Icons.cleaning_services;
    } else if (category.contains('carpentry') || category.contains('carpenter') || name.contains('carpent')) {
      return Icons.carpenter;
    } else if (category.contains('painting') || category.contains('paint') || name.contains('paint')) {
      return Icons.format_paint;
    } else if (category.contains('hvac') || category.contains('air') || name.contains('hvac') || name.contains('air')) {
      return Icons.ac_unit;
    } else if (category.contains('appliance') || category.contains('repair') || name.contains('appliance') || name.contains('repair')) {
      return Icons.build_circle;
    } else if (category.contains('gardening') || category.contains('garden') || name.contains('garden')) {
      return Icons.local_florist;
    } else if (category.contains('pest') || name.contains('pest')) {
      return Icons.pest_control;
    } else if (category.contains('water') && (category.contains('tank') || category.contains('tank')) || name.contains('water tank')) {
      return Icons.water_drop;
    } else if (category.contains('mason') || category.contains('construction') || name.contains('mason') || name.contains('construction')) {
      return Icons.construction;
    } else if (category.contains('roof') || name.contains('roof')) {
      return Icons.roofing;
    } else if (category.contains('weld') || name.contains('weld')) {
      return Icons.build;
    }
    
    return Icons.home_repair_service;
  }

  static Color getIconColorForService(String serviceName, String categoryTag) {
    final name = serviceName.toLowerCase();
    final category = categoryTag.toLowerCase();

    if (category.contains('plumbing') || category.contains('plumber') || name.contains('plumb')) {
      return Colors.cyan;
    } else if (category.contains('electrical') || category.contains('electric') || name.contains('electric')) {
      return Colors.amber.shade700;
    } else if (category.contains('cleaning') || category.contains('clean') || name.contains('clean')) {
      return Colors.blue;
    } else if (category.contains('carpentry') || category.contains('carpenter') || name.contains('carpent')) {
      return Colors.brown;
    } else if (category.contains('painting') || category.contains('paint') || name.contains('paint')) {
      return Colors.purple;
    } else if (category.contains('hvac') || category.contains('air') || name.contains('hvac') || name.contains('air')) {
      return Colors.lightBlue;
    } else if (category.contains('appliance') || category.contains('repair') || name.contains('appliance') || name.contains('repair')) {
      return Colors.red;
    } else if (category.contains('gardening') || category.contains('garden') || name.contains('garden')) {
      return Colors.green;
    } else if (category.contains('pest') || name.contains('pest')) {
      return Colors.orange;
    } else if (category.contains('water') && (category.contains('tank') || category.contains('tank')) || name.contains('water tank')) {
      return Colors.blue.shade300;
    } else if (category.contains('mason') || category.contains('construction') || name.contains('mason') || name.contains('construction')) {
      return Colors.orange;
    } else if (category.contains('roof') || name.contains('roof')) {
      return Colors.grey.shade700;
    } else if (category.contains('weld') || name.contains('weld')) {
      return Colors.deepOrange;
    }
    
    return Colors.blue;
  }

  static List<Color> getGradientColorsForService(String serviceName, String categoryTag) {
    final name = serviceName.toLowerCase();
    final category = categoryTag.toLowerCase();

    if (category.contains('plumbing') || category.contains('plumber') || name.contains('plumb')) {
      return [
        Colors.cyan.withValues(alpha: 0.15),
        Colors.blue.withValues(alpha: 0.08),
      ];
    } else if (category.contains('electrical') || category.contains('electric') || name.contains('electric')) {
      return [
        Colors.amber.withValues(alpha: 0.15),
        Colors.orange.withValues(alpha: 0.08),
      ];
    } else if (category.contains('cleaning') || category.contains('clean') || name.contains('clean')) {
      return [
        Colors.blue.withValues(alpha: 0.15),
        Colors.lightBlue.withValues(alpha: 0.08),
      ];
    } else if (category.contains('carpentry') || category.contains('carpenter') || name.contains('carpent')) {
      return [
        Colors.brown.withValues(alpha: 0.15),
        Colors.orange.withValues(alpha: 0.08),
      ];
    } else if (category.contains('painting') || category.contains('paint') || name.contains('paint')) {
      return [
        Colors.purple.withValues(alpha: 0.15),
        Colors.pink.withValues(alpha: 0.08),
      ];
    } else if (category.contains('hvac') || category.contains('air') || name.contains('hvac') || name.contains('air')) {
      return [
        Colors.lightBlue.withValues(alpha: 0.15),
        Colors.cyan.withValues(alpha: 0.08),
      ];
    } else if (category.contains('appliance') || category.contains('repair') || name.contains('appliance') || name.contains('repair')) {
      return [
        Colors.red.withValues(alpha: 0.15),
        Colors.orange.withValues(alpha: 0.08),
      ];
    } else if (category.contains('gardening') || category.contains('garden') || name.contains('garden')) {
      return [
        Colors.green.withValues(alpha: 0.15),
        Colors.lightGreen.withValues(alpha: 0.08),
      ];
    } else if (category.contains('pest') || name.contains('pest')) {
      return [
        Colors.orange.withValues(alpha: 0.15),
        Colors.deepOrange.withValues(alpha: 0.08),
      ];
    } else if (category.contains('water') && (category.contains('tank') || category.contains('tank')) || name.contains('water tank')) {
      return [
        Colors.blue.withValues(alpha: 0.15),
        Colors.lightBlue.withValues(alpha: 0.08),
      ];
    } else if (category.contains('mason') || category.contains('construction') || name.contains('mason') || name.contains('construction')) {
      return [
        Colors.orange.withValues(alpha: 0.15),
        Colors.deepOrange.withValues(alpha: 0.08),
      ];
    } else if (category.contains('roof') || name.contains('roof')) {
      return [
        Colors.grey.withValues(alpha: 0.15),
        Colors.grey.shade600.withValues(alpha: 0.08),
      ];
    } else if (category.contains('weld') || name.contains('weld')) {
      return [
        Colors.deepOrange.withValues(alpha: 0.15),
        Colors.orange.withValues(alpha: 0.08),
      ];
    }
    
    return [
      Colors.blue.withValues(alpha: 0.1),
      Colors.lightBlue.withValues(alpha: 0.05),
    ];
  }
}
