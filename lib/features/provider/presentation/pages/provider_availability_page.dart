import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../data/repositories/availability_repository_impl.dart';
import '../../domain/entities/availability_entity.dart';
import '../../presentation/providers/availability_provider.dart';

final providerAvailabilityDataProvider = FutureProvider<AvailabilityEntity>((ref) async {
  final repository = ref.watch(availabilityRepositoryProvider);
  final result = await repository.getAvailability();
  return result.fold(
    (failure) => throw Exception(failure.message),
    (availability) => availability,
  );
});

class ProviderAvailabilityPage extends ConsumerStatefulWidget {
  const ProviderAvailabilityPage({super.key});

  @override
  ConsumerState<ProviderAvailabilityPage> createState() => _ProviderAvailabilityPageState();
}

class _ProviderAvailabilityPageState extends ConsumerState<ProviderAvailabilityPage> {
  final Map<int, List<TimeSlotEntity>> _schedule = {};
  bool _isSaving = false;

  final List<String> _dayNames = [
    'Sunday',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
  ];

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < 7; i++) {
      _schedule[i] = [];
    }
  }

  void _addTimeSlot(int dayOfWeek) {
    setState(() {
      _schedule[dayOfWeek] = [
        ...(_schedule[dayOfWeek] ?? []),
        const TimeSlotEntity(start: '09:00', end: '17:00'),
      ];
    });
  }

  void _removeTimeSlot(int dayOfWeek, int index) {
    setState(() {
      final slots = _schedule[dayOfWeek] ?? [];
      if (index < slots.length) {
        slots.removeAt(index);
        _schedule[dayOfWeek] = slots;
      }
    });
  }

  void _updateTimeSlot(int dayOfWeek, int index, String start, String end) {
    setState(() {
      final slots = _schedule[dayOfWeek] ?? [];
      if (index < slots.length) {
        slots[index] = TimeSlotEntity(start: start, end: end);
        _schedule[dayOfWeek] = slots;
      }
    });
  }

  Future<void> _saveAvailability() async {
    setState(() {
      _isSaving = true;
    });

    try {
      final repository = ref.read(availabilityRepositoryProvider);
      
      final weeklySchedule = _schedule.entries.map((entry) {
        return DayAvailabilityEntity(
          dayOfWeek: entry.key,
          timeSlots: entry.value,
        );
      }).toList();

      final result = await repository.updateAvailability(weeklySchedule);

      result.fold(
        (failure) {
          setState(() {
            _isSaving = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to save availability: ${failure.message}'),
              backgroundColor: Colors.red,
            ),
          );
        },
        (availability) {
          setState(() {
            _isSaving = false;
          });
          ref.invalidate(providerAvailabilityDataProvider);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Availability saved successfully'),
              backgroundColor: Colors.green,
            ),
          );
        },
      );
    } catch (e) {
      setState(() {
        _isSaving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final availabilityAsync = ref.watch(providerAvailabilityDataProvider);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? Colors.white : Colors.black87,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Manage Availability',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            TextButton(
              onPressed: _saveAvailability,
              child: const Text(
                'Save',
                style: TextStyle(
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      body: availabilityAsync.when(
        data: (availability) {
          if (_schedule.isEmpty || _schedule.values.every((slots) => slots.isEmpty)) {
            for (final day in availability.weeklySchedule) {
              _schedule[day.dayOfWeek] = day.timeSlots;
            }
          }
          return _buildAvailabilityContent(context, isDark);
        },
        loading: () => const AppLoadingWidget(),
        error: (error, stack) => AppErrorWidget(
          message: error.toString(),
          onRetry: () => ref.invalidate(providerAvailabilityDataProvider),
        ),
      ),
    );
  }

  Widget _buildAvailabilityContent(BuildContext context, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Set your weekly availability',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add time slots for each day you are available',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          ...List.generate(7, (index) {
            return _buildDayCard(context, isDark, index);
          }),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildDayCard(BuildContext context, bool isDark, int dayOfWeek) {
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final slots = _schedule[dayOfWeek] ?? [];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _dayNames[dayOfWeek],
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle),
                color: AppColors.primaryBlue,
                onPressed: () => _addTimeSlot(dayOfWeek),
              ),
            ],
          ),
          if (slots.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'No time slots added',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.grey[600] : Colors.grey[400],
                ),
              ),
            )
          else
            ...slots.asMap().entries.map((entry) {
              final index = entry.key;
              final slot = entry.value;
              return _buildTimeSlotRow(context, isDark, dayOfWeek, index, slot);
            }),
        ],
      ),
    );
  }

  Widget _buildTimeSlotRow(
    BuildContext context,
    bool isDark,
    int dayOfWeek,
    int index,
    TimeSlotEntity slot,
  ) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              initialValue: slot.start,
              decoration: InputDecoration(
                labelText: 'Start',
                hintText: 'HH:mm',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              onChanged: (value) {
                _updateTimeSlot(dayOfWeek, index, value, slot.end);
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextFormField(
              initialValue: slot.end,
              decoration: InputDecoration(
                labelText: 'End',
                hintText: 'HH:mm',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              onChanged: (value) {
                _updateTimeSlot(dayOfWeek, index, slot.start, value);
              },
            ),
          ),
          const SizedBox(width: 12),
          IconButton(
            icon: const Icon(Icons.delete),
            color: Colors.red,
            onPressed: () => _removeTimeSlot(dayOfWeek, index),
          ),
        ],
      ),
    );
  }
}
