import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/app_background.dart';
import '../../../core/utils/validators.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/services/event_service.dart';
import '../../../data/models/event.dart';
import '../../../data/models/music_post.dart';

/// Create Event Screen for organizers
class CreateEventScreen extends StatefulWidget {
  final String userId;
  final Event? event; // For editing existing events
  final VoidCallback? onEventCreated;

  const CreateEventScreen({
    super.key,
    required this.userId,
    this.onEventCreated,
    this.event,
  });

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _eventService = EventService();

  // Controllers
  late final TextEditingController _eventNameController;
  late final TextEditingController _venueNameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _locationController;
  late final TextEditingController _paymentController;
  late final TextEditingController _slotsController;

  // State
  DateTime? _selectedDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  String _paymentType = 'Paid';
  List<String> _selectedGenres = [];
  bool _isLoading = false;

  final List<String> _paymentTypes = ['Paid', 'Unpaid', 'Negotiable'];

  @override
  void initState() {
    super.initState();

    // Initialize controllers with existing data if editing
    final event = widget.event;
    _eventNameController = TextEditingController(text: event?.eventName);
    _venueNameController = TextEditingController(text: event?.venueName);
    _descriptionController = TextEditingController(text: event?.description);
    _locationController = TextEditingController(text: event?.location);
    _paymentController = TextEditingController(
      text: event?.payment.toString() ?? '',
    );
    _slotsController = TextEditingController(
      text: event?.slotsTotal.toString() ?? '',
    );

    if (event != null) {
      _selectedDate = event.eventDate;
      _startTime = _parseTime(event.startTime);
      _endTime = _parseTime(event.endTime);
      _paymentType = event.paymentType;
      _selectedGenres = List.from(event.genres);
    }
  }

  @override
  void dispose() {
    _eventNameController.dispose();
    _venueNameController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _paymentController.dispose();
    _slotsController.dispose();
    super.dispose();
  }

  TimeOfDay _parseTime(String time) {
    final parts = time.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _selectStartTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _startTime ?? const TimeOfDay(hour: 18, minute: 0),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _startTime = picked);
    }
  }

  Future<void> _selectEndTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _endTime ?? const TimeOfDay(hour: 22, minute: 0),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _endTime = picked);
    }
  }

  Future<void> _selectGenres() async {
    final List<String>? selected = await showDialog<List<String>>(
      context: context,
      builder: (context) => _GenreSelectionDialog(
        selectedGenres: _selectedGenres,
      ),
    );

    if (selected != null) {
      setState(() => _selectedGenres = selected);
    }
  }

  Future<void> _saveEvent() async {
    if (!_formKey.currentState!.validate()) return;

    // Validate additional required fields
    if (_selectedDate == null) {
      _showError('Please select an event date');
      return;
    }
    if (_startTime == null) {
      _showError('Please select a start time');
      return;
    }
    if (_endTime == null) {
      _showError('Please select an end time');
      return;
    }
    if (_selectedGenres.isEmpty) {
      _showError('Please select at least one genre');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final organizerName = authProvider.appUser?.username ?? 'Organizer';

      // Parse payment amount
      double paymentAmount = 0.0;
      if (_paymentType == 'Paid') {
        paymentAmount = double.tryParse(_paymentController.text.trim()) ?? 0.0;
        if (paymentAmount <= 0) {
          throw Exception('Please enter a valid payment amount');
        }
      }

      final event = Event(
        id: widget.event?.id ?? '',
        organizerId: widget.userId,
        organizerName: organizerName,
        eventName: _eventNameController.text.trim(),
        venueName: _venueNameController.text.trim(),
        description: _descriptionController.text.trim(),
        eventDate: _selectedDate!,
        startTime: _formatTimeOfDay(_startTime!),
        endTime: _formatTimeOfDay(_endTime!),
        location: _locationController.text.trim(),
        latitude: 0.0, // TODO: Get from Google Maps
        longitude: 0.0, // TODO: Get from Google Maps
        payment: paymentAmount,
        paymentType: _paymentType,
        genres: _selectedGenres,
        slotsAvailable: int.parse(_slotsController.text.trim()),
        slotsTotal: int.parse(_slotsController.text.trim()),
        createdAt: widget.event?.createdAt ?? DateTime.now(),
        status: 'open',
      );

      if (widget.event != null) {
        // Update existing event
        await _eventService.updateEvent(event);
        if (mounted && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Event updated successfully!'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } else {
        // Create new event
        await _eventService.createEvent(event);
        if (mounted && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Event created successfully!'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      }

      if (mounted && context.mounted) {
        // Call the callback if provided
        widget.onEventCreated?.call();

        // If no callback (opened directly), just pop
        if (widget.onEventCreated == null && Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      }
    } catch (e) {
      _showError(e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: Text(widget.event != null ? 'Edit Event' : 'Create Event'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: AppBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Event Name
                  TextFormField(
                    controller: _eventNameController,
                    decoration: const InputDecoration(
                      labelText: 'Event Name',
                      prefixIcon: Icon(Icons.event),
                      hintText: 'e.g., Jazz Night at The Blue Note',
                    ),
                    validator: Validators.required,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),

                  // Venue Name
                  TextFormField(
                    controller: _venueNameController,
                    decoration: const InputDecoration(
                      labelText: 'Venue Name',
                      prefixIcon: Icon(Icons.location_city),
                      hintText: 'e.g., The Blue Note',
                    ),
                    validator: Validators.required,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),

                  // Location/Address
                  TextFormField(
                    controller: _locationController,
                    decoration: const InputDecoration(
                      labelText: 'Full Address',
                      prefixIcon: Icon(Icons.location_on),
                      hintText: 'e.g., 123 Music St, Petaling Jaya',
                    ),
                    validator: Validators.required,
                    maxLines: 2,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),

                  // Event Date
                  InkWell(
                    onTap: _selectDate,
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Event Date',
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      child: Text(
                        _selectedDate != null
                            ? DateFormat('EEEE, MMMM d, yyyy').format(_selectedDate!)
                            : 'Select date',
                        style: TextStyle(
                          color: _selectedDate != null
                              ? AppColors.textPrimary
                              : AppColors.textHint,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Start and End Time
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: _selectStartTime,
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Start Time',
                              prefixIcon: Icon(Icons.access_time),
                            ),
                            child: Text(
                              _startTime != null
                                  ? _startTime!.format(context)
                                  : 'Select',
                              style: TextStyle(
                                color: _startTime != null
                                    ? AppColors.textPrimary
                                    : AppColors.textHint,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: InkWell(
                          onTap: _selectEndTime,
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'End Time',
                              prefixIcon: Icon(Icons.access_time),
                            ),
                            child: Text(
                              _endTime != null
                                  ? _endTime!.format(context)
                                  : 'Select',
                              style: TextStyle(
                                color: _endTime != null
                                    ? AppColors.textPrimary
                                    : AppColors.textHint,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Payment Type
                  DropdownButtonFormField<String>(
                    initialValue: _paymentType,
                    decoration: const InputDecoration(
                      labelText: 'Payment Type',
                      prefixIcon: Icon(Icons.payments),
                    ),
                    items: _paymentTypes.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(type),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => _paymentType = value!);
                    },
                  ),
                  const SizedBox(height: 16),

                  // Payment Amount (only show if Paid)
                  if (_paymentType == 'Paid') ...[
                    TextFormField(
                      controller: _paymentController,
                      decoration: const InputDecoration(
                        labelText: 'Payment Amount (RM)',
                        prefixIcon: Icon(Icons.attach_money),
                        hintText: 'e.g., 500',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (_paymentType == 'Paid') {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter payment amount';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Please enter a valid number';
                          }
                        }
                        return null;
                      },
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Number of Slots
                  TextFormField(
                    controller: _slotsController,
                    decoration: const InputDecoration(
                      labelText: 'Number of Musicians Needed',
                      prefixIcon: Icon(Icons.people),
                      hintText: 'e.g., 3',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter number of slots';
                      }
                      final slots = int.tryParse(value);
                      if (slots == null || slots < 1) {
                        return 'Please enter a valid number (minimum 1)';
                      }
                      return null;
                    },
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),

                  // Genres
                  InkWell(
                    onTap: _selectGenres,
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Required Genres',
                        prefixIcon: Icon(Icons.music_note),
                      ),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _selectedGenres.isEmpty
                            ? [
                          Text(
                            'Select genres',
                            style: TextStyle(
                              color: AppColors.textHint,
                            ),
                          )
                        ]
                            : _selectedGenres.map((genre) {
                          return Chip(
                            label: Text(genre),
                            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                            labelStyle: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 12,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Description
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Event Description',
                      prefixIcon: Icon(Icons.description),
                      hintText: 'Tell musicians about this event...',
                    ),
                    maxLines: 4,
                    maxLength: 500,
                    validator: Validators.required,
                    textInputAction: TextInputAction.done,
                  ),
                  const SizedBox(height: 32),

                  // Save Button
                  SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveEvent,
                      child: _isLoading
                          ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.white,
                        ),
                      )
                          : Text(widget.event != null
                          ? 'Update Event'
                          : 'Create Event'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Genre selection dialog
class _GenreSelectionDialog extends StatefulWidget {
  final List<String> selectedGenres;

  const _GenreSelectionDialog({
    required this.selectedGenres,
  });

  @override
  State<_GenreSelectionDialog> createState() => _GenreSelectionDialogState();
}

class _GenreSelectionDialogState extends State<_GenreSelectionDialog> {
  late List<String> _selected;

  @override
  void initState() {
    super.initState();
    _selected = List.from(widget.selectedGenres);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.white,
      title: const Text('Select Genres'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: MusicGenres.genres.where((g) => g != 'Not Tagged').map((genre) {
            final isSelected = _selected.contains(genre);
            return CheckboxListTile(
              title: Text(genre),
              value: isSelected,
              activeColor: AppColors.primary,
              onChanged: (bool? value) {
                setState(() {
                  if (value == true) {
                    _selected.add(genre);
                  } else {
                    _selected.remove(genre);
                  }
                });
              },
            );
          }).toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, _selected),
          child: Text('Done (${_selected.length})'),
        ),
      ],
    );
  }
}