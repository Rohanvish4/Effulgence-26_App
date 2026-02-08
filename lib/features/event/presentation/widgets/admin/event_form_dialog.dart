import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../components/components.dart';
import '../../../domain/entities/event_entity.dart';
import '../../../domain/entities/event_params.dart';

class EventFormDialog extends StatefulWidget {
  final EventEntity? event; // If null, create mode; otherwise, edit mode
  final Function(CreateEventParams) onCreate;
  final Function(UpdateEventParams) onUpdate;
  final bool isLoading;

  const EventFormDialog({
    super.key,
    this.event,
    required this.onCreate,
    required this.onUpdate,
    required this.isLoading,
  });

  @override
  State<EventFormDialog> createState() => _EventFormDialogState();
}

class _EventFormDialogState extends State<EventFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _rulesController;
  late TextEditingController _venueController;

  String _domain = 'programming';
  String _eventType = 'INDIVIDUAL';
  DateTime _eventTime = DateTime.now().add(const Duration(days: 1));
  DateTime _endTime = DateTime.now().add(const Duration(days: 1, hours: 2));
  DateTime _registrationDeadline = DateTime.now().add(const Duration(days: 1));

  int _minTeamSize = 1;
  int _maxTeamSize = 4;

  final List<String> _domains = [
    'programming',
    'robotics',
    'entrepreneurial',
    'miscellaneous',
  ];

  final List<String> _eventTypes = ['INDIVIDUAL', 'TEAM'];

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  void _initializeApp() {
    final event = widget.event;
    _titleController = TextEditingController(text: event?.title ?? '');
    _descriptionController = TextEditingController(
      text: event?.description ?? '',
    );
    _rulesController = TextEditingController(text: event?.rules ?? '');
    _venueController = TextEditingController(
      text: event?.eventVenue ?? '',
    ); // Use eventVenue getter

    if (event != null) {
      // Normalize domain to match list, or fallback to programming
      var normalizedDomain = event.domain.toLowerCase();
      if (!_domains.contains(normalizedDomain)) {
        normalizedDomain = 'programming';
      }

      _domain = normalizedDomain;
      _eventType = event.eventType;
      _eventTime = event.eventTime;
      _endTime = event.endTime ?? event.eventTime.add(const Duration(hours: 2));
      _registrationDeadline = event.registrationDeadline;
      if (event.teamConfig != null) {
        _minTeamSize = event.teamConfig!.minSize;
        _maxTeamSize = event.teamConfig!.maxSize;
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _rulesController.dispose();
    _venueController.dispose();
    super.dispose();
  }

  Future<void> _selectDateTime(BuildContext context, int dateType) async {
    // dateType: 0 = eventTime, 1 = endTime, 2 = registrationDeadline
    DateTime initialDate;
    if (dateType == 0) {
      initialDate = _eventTime;
    } else if (dateType == 1) {
      initialDate = _endTime;
    } else {
      initialDate = _registrationDeadline;
    }

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );

    if (pickedDate != null && mounted) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(initialDate),
      );

      if (pickedTime != null) {
        setState(() {
          final newDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
          if (dateType == 0) {
            _eventTime = newDateTime;
            if (_endTime.isBefore(_eventTime)) {
              _endTime = _eventTime.add(const Duration(hours: 2));
            }
          } else if (dateType == 1) {
            _endTime = newDateTime;
          } else {
            _registrationDeadline = newDateTime;
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.event != null;

    return AlertDialog(
      backgroundColor: AppColors.bgSecondary,
      title: Text(
        isEditing ? 'Edit Event' : 'Create Event',
        style: AppTextStyles.headlineSmall,
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTextField('Title', _titleController, required: true),
                const SizedBox(height: AppSpacing.md),
                _buildDropdown(
                  'Domain',
                  _domain,
                  _domains,
                  (val) => setState(() => _domain = val!),
                ),
                const SizedBox(height: AppSpacing.md),
                _buildDropdown(
                  'Event Type',
                  _eventType,
                  _eventTypes,
                  (val) => setState(() => _eventType = val!),
                ),
                const SizedBox(height: AppSpacing.md),
                if (_eventType == 'TEAM') ...[
                  Row(
                    children: [
                      Expanded(
                        child: _buildNumberField(
                          'Min Team Size',
                          _minTeamSize,
                          (val) => _minTeamSize = val,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: _buildNumberField(
                          'Max Team Size',
                          _maxTeamSize,
                          (val) => _maxTeamSize = val,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
                _buildTextField('Venue', _venueController, required: true),
                const SizedBox(height: AppSpacing.md),
                _buildTextField(
                  'Description',
                  _descriptionController,
                  maxLines: 3,
                ),
                const SizedBox(height: AppSpacing.md),
                _buildTextField('Rules', _rulesController, maxLines: 3),
                const SizedBox(height: AppSpacing.md),

                // Date Pickers
                _buildDateTile(
                  'Event Time',
                  _eventTime,
                  () => _selectDateTime(context, 0),
                ),
                const SizedBox(height: AppSpacing.sm),
                _buildDateTile(
                  'Event End Time',
                  _endTime,
                  () => _selectDateTime(context, 1),
                ),
                const SizedBox(height: AppSpacing.sm),
                _buildDateTile(
                  'Registration Deadline',
                  _registrationDeadline,
                  () => _selectDateTime(context, 2),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Cancel',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
        AppButton(
          text: isEditing ? 'Update' : 'Create',
          isFullWidth: false,
          isLoading: widget.isLoading,
          onPressed: _handleSubmit,
        ),
      ],
    );
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      final teamConfig = _eventType == 'TEAM'
          ? TeamConfig(minSize: _minTeamSize, maxSize: _maxTeamSize)
          : null;

      if (widget.event == null) {
        // Create
        final params = CreateEventParams(
          title: _titleController.text,
          description: _descriptionController.text,
          rules: _rulesController.text,
          domain: _domain,
          eventType: _eventType,
          eventVenue: _venueController.text,
          eventTime: _eventTime,
          endTime: _endTime,
          registrationDeadline: _registrationDeadline,
          teamConfig: teamConfig,
        );
        widget.onCreate(params);
      } else {
        // Update
        final params = UpdateEventParams(
          title: _titleController.text,
          description: _descriptionController.text,
          rules: _rulesController.text,
          domain: _domain,
          eventType: _eventType,
          eventVenue: _venueController.text,
          eventTime: _eventTime,
          endTime: _endTime,
          registrationDeadline: _registrationDeadline,
          teamConfig: teamConfig,
        );
        widget.onUpdate(params);
      }
      Navigator.pop(context);
    }
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
    bool required = false,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      style: TextStyle(color: AppColors.textPrimary),
      validator: required
          ? (value) => value?.isEmpty ?? true ? 'Required' : null
          : null,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: AppColors.textSecondary),
        border: const OutlineInputBorder(),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.primary),
        ),
      ),
    );
  }

  Widget _buildDropdown(
    String label,
    String value,
    List<String> items,
    ValueChanged<String?> onChanged,
  ) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      items: items
          .map((e) => DropdownMenuItem(value: e, child: Text(e.toUpperCase())))
          .toList(),
      onChanged: onChanged,
      dropdownColor: AppColors.bgSecondary,
      style: TextStyle(color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: AppColors.textSecondary),
        border: const OutlineInputBorder(),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.border),
        ),
      ),
    );
  }

  Widget _buildNumberField(
    String label,
    int value,
    ValueChanged<int> onChanged,
  ) {
    return TextFormField(
      initialValue: value.toString(),
      keyboardType: TextInputType.number,
      style: TextStyle(color: AppColors.textPrimary),
      onChanged: (val) => onChanged(int.tryParse(val) ?? 1),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.textSecondary),
        border: const OutlineInputBorder(),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.border),
        ),
      ),
    );
  }

  Widget _buildDateTile(String label, DateTime date, VoidCallback onTap) {
    return ListTile(
      title: Text(
        label,
        style: const TextStyle(color: AppColors.textSecondary),
      ),
      subtitle: Text(
        '${date.toLocal()}'.split('.')[0],
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.bold,
        ),
      ),
      trailing: const Icon(Icons.calendar_today, color: AppColors.primary),
      onTap: onTap,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: AppColors.border),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
