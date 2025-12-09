import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// Bottom sheet for filtering events by date and distance
class EventFiltersBottomSheet extends StatefulWidget {
  final DateTime? initialStartDate;
  final DateTime? initialEndDate;
  final double? initialMaxDistance;
  final Function(DateTime?, DateTime?, double?) onApplyFilters;

  const EventFiltersBottomSheet({
    super.key,
    this.initialStartDate,
    this.initialEndDate,
    this.initialMaxDistance,
    required this.onApplyFilters,
  });

  @override
  State<EventFiltersBottomSheet> createState() =>
      _EventFiltersBottomSheetState();
}

class _EventFiltersBottomSheetState extends State<EventFiltersBottomSheet> {
  DateTime? _startDate;
  DateTime? _endDate;
  double? _maxDistance;

  @override
  void initState() {
    super.initState();
    _startDate = widget.initialStartDate;
    _endDate = widget.initialEndDate;
    _maxDistance = widget.initialMaxDistance;
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.white,
              surface: AppColors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  void _clearFilters() {
    setState(() {
      _startDate = null;
      _endDate = null;
      _maxDistance = null;
    });
  }

  void _applyFilters() {
    widget.onApplyFilters(_startDate, _endDate, _maxDistance);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.greyLight,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Title
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Filter Events',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    TextButton.icon(
                      onPressed: _clearFilters,
                      icon: const Icon(Icons.clear_all, size: 18),
                      label: const Text('Clear'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.error,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Date Range Section
                Text(
                  'Date Range',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),

                // Date range button
                OutlinedButton.icon(
                  onPressed: _selectDateRange,
                  icon: const Icon(Icons.calendar_today),
                  label: Text(
                    _startDate != null && _endDate != null
                        ? '${_formatDate(_startDate!)} - ${_formatDate(_endDate!)}'
                        : 'Select date range',
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _startDate != null
                        ? AppColors.primary
                        : AppColors.textSecondary,
                    side: BorderSide(
                      color: _startDate != null
                          ? AppColors.primary
                          : AppColors.border,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                ),

                if (_startDate != null && _endDate != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton.icon(
                        onPressed: () {
                          setState(() {
                            _startDate = null;
                            _endDate = null;
                          });
                        },
                        icon: const Icon(Icons.close, size: 16),
                        label: const Text('Clear dates'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.error,
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 24),

                // Distance Section
                Text(
                  'Maximum Distance',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),

                if (_maxDistance != null)
                  Text(
                    'Within ${_maxDistance!.toInt()} km',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                const SizedBox(height: 8),

                // Distance slider
                Row(
                  children: [
                    const Icon(Icons.location_on, color: AppColors.textSecondary),
                    Expanded(
                      child: Slider(
                        value: _maxDistance ?? 50,
                        min: 5,
                        max: 100,
                        divisions: 19,
                        label: _maxDistance != null
                            ? '${_maxDistance!.toInt()} km'
                            : '50 km',
                        activeColor: AppColors.primary,
                        onChanged: (value) {
                          setState(() => _maxDistance = value);
                        },
                      ),
                    ),
                    const Icon(Icons.location_off, color: AppColors.textSecondary),
                  ],
                ),

                const SizedBox(height: 8),

                // Distance labels
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '5 km',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      '100 km',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),

                if (_maxDistance != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton.icon(
                        onPressed: () {
                          setState(() => _maxDistance = null);
                        },
                        icon: const Icon(Icons.close, size: 16),
                        label: const Text('Clear distance'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.error,
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 24),

                // Info text
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.info.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        size: 20,
                        color: AppColors.info,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Distance is calculated from your current location',
                          style:
                          Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.info,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Apply button
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _applyFilters,
                    child: const Text(
                      'Apply Filters',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}