import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../models/team.dart';
import '../services/task_provider.dart';
import '../services/team_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/location_picker.dart';
import '../localization/translation_helper.dart';

class AddEditTaskScreen extends StatefulWidget {
  final Task? task; // If null, we're adding a new task; otherwise, editing
  final String? preSelectedTeamId; // Pre-select a team when creating new task

  // const AddEditTaskScreen({Key? key, this.task}) : super(key: key);
  const AddEditTaskScreen({super.key, this.task, this.preSelectedTeamId});

  @override
  State<AddEditTaskScreen> createState() => _AddEditTaskScreenState();
}

class _AddEditTaskScreenState extends State<AddEditTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late DateTime _selectedStartDate;
  late DateTime _selectedEndDate;
  late TaskPriority _selectedPriority;
  late TaskCategory _selectedCategory;
  String? _selectedTeamId;
  List<String> _selectedMemberIds = [];
  bool _isSaving = false;

  // Location-related variables
  double? _selectedLatitude;
  double? _selectedLongitude;
  String? _selectedLocationName;
  String? _selectedLocationAddress;

  bool get isEditing => widget.task != null;

  @override
  void initState() {
    super.initState();

    // Initialize controllers
    _titleController = TextEditingController(text: widget.task?.title ?? '');
    _descriptionController = TextEditingController(
      text: widget.task?.description ?? '',
    );

    // Initialize selectors
    if (isEditing) {
      _selectedStartDate = widget.task!.startDate;
      _selectedEndDate = widget.task!.endDate;
    } else {
      // For new tasks, set default dates
      _selectedStartDate = DateTime.now();
      _selectedEndDate = DateTime.now().add(const Duration(days: 1));
    }

    _selectedPriority = widget.task?.priority ?? TaskPriority.medium;
    _selectedCategory = widget.task?.category ?? TaskCategory.personal;
    _selectedTeamId = widget.task?.assignedTeamId ?? widget.preSelectedTeamId;
    _selectedMemberIds = widget.task?.assignedMemberIds ?? [];

    // Initialize location variables
    _selectedLatitude = widget.task?.latitude;
    _selectedLongitude = widget.task?.longitude;
    _selectedLocationName = widget.task?.locationName;
    _selectedLocationAddress = widget.task?.locationAddress;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveTask() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSaving = true;
      });

      final taskProvider = Provider.of<TaskProvider>(context, listen: false);

      final task = Task(
        id: isEditing ? widget.task!.id : '', // Let Firebase generate the ID
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        startDate: _selectedStartDate,
        endDate: _selectedEndDate,
        priority: _selectedPriority,
        category: _selectedCategory,
        isCompleted: isEditing ? widget.task!.isCompleted : false,
        createdAt: isEditing ? widget.task!.createdAt : DateTime.now(),
        assignedTeamId: _selectedTeamId,
        assignedMemberIds:
            _selectedMemberIds.isNotEmpty ? _selectedMemberIds : null,
        latitude: _selectedLatitude,
        longitude: _selectedLongitude,
        locationName: _selectedLocationName,
        locationAddress: _selectedLocationAddress,
      );

      try {
        if (isEditing) {
          await taskProvider.updateTask(task);
        } else {
          // Add task and wait for the result
          final taskId = await taskProvider.addTask(task);
          debugPrint('Task created with ID: $taskId'); // Debug log
        }

        if (mounted) {
          // Reset the saving state before navigation
          setState(() {
            _isSaving = false;
          });

          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isEditing
                    ? 'Task updated successfully'
                    : 'Task created successfully',
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        debugPrint('AddEditTaskScreen: Error in _saveTask: $e'); // Debug log
        if (mounted) {
          setState(() {
            _isSaving = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isEditing
                    ? 'Failed to update task: $e'
                    : 'Failed to create task: $e',
              ),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    }
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedStartDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppTheme.primaryColor,
              onPrimary: Colors.white,
              onSurface:
                  isDarkMode
                      ? AppTheme.darkPrimaryTextColor
                      : AppTheme.lightPrimaryTextColor,
              surface:
                  isDarkMode
                      ? AppTheme.darkSurfaceColor
                      : AppTheme.lightSurfaceColor,
            ),
            dialogTheme: DialogThemeData(
              backgroundColor:
                  isDarkMode
                      ? AppTheme.darkBackgroundColor
                      : AppTheme.lightBackgroundColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedStartDate) {
      setState(() {
        _selectedStartDate = picked;
        // If end date is before start date, update end date
        if (_selectedEndDate.isBefore(_selectedStartDate)) {
          _selectedEndDate = _selectedStartDate.add(const Duration(days: 1));
        }
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          _selectedEndDate.isAfter(_selectedStartDate)
              ? _selectedEndDate
              : _selectedStartDate.add(const Duration(days: 1)),
      firstDate: _selectedStartDate,
      lastDate: _selectedStartDate.add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppTheme.primaryColor,
              onPrimary: Colors.white,
              onSurface:
                  isDarkMode
                      ? AppTheme.darkPrimaryTextColor
                      : AppTheme.lightPrimaryTextColor,
              surface:
                  isDarkMode
                      ? AppTheme.darkSurfaceColor
                      : AppTheme.lightSurfaceColor,
            ),
            dialogTheme: DialogThemeData(
              backgroundColor:
                  isDarkMode
                      ? AppTheme.darkBackgroundColor
                      : AppTheme.lightBackgroundColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedEndDate) {
      setState(() {
        _selectedEndDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDarkMode
              ? AppTheme.darkBackgroundColor
              : AppTheme.lightBackgroundColor,
      appBar: CustomAppBar(
        title: isEditing ? context.tr('edit_task') : context.tr('add_new_task'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title field
                Text(
                  context.tr('title'),
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 8),
                CustomTextField(
                  controller: _titleController,
                  hintText: context.tr('task_title'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return context.tr('please_enter_title');
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 24),

                // Description field
                Text(
                  context.tr('description'),
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 8),
                CustomTextField(
                  controller: _descriptionController,
                  hintText: context.tr('task_description'),
                  maxLines: 4,
                ),

                const SizedBox(height: 24),

                // Date pickers
                Text(
                  context.tr('task_date_range'),
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 8),

                // Start date picker
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.tr('start_date'),
                            style: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.copyWith(
                              color:
                                  isDarkMode
                                      ? AppTheme.darkSecondaryTextColor
                                      : AppTheme.lightSecondaryTextColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          GestureDetector(
                            onTap: () => _selectStartDate(context),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    isDarkMode
                                        ? AppTheme.darkSurfaceColor
                                        : AppTheme.lightSurfaceColor,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    DateFormat(
                                      'MMM dd, yyyy',
                                    ).format(_selectedStartDate),
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                  Icon(
                                    Icons.calendar_today,
                                    size: 16,
                                    color:
                                        isDarkMode
                                            ? AppTheme.darkSecondaryTextColor
                                            : AppTheme.lightSecondaryTextColor,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    // End date picker
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.tr('end_date'),
                            style: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.copyWith(
                              color:
                                  isDarkMode
                                      ? AppTheme.darkSecondaryTextColor
                                      : AppTheme.lightSecondaryTextColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          GestureDetector(
                            onTap: () => _selectEndDate(context),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    isDarkMode
                                        ? AppTheme.darkSurfaceColor
                                        : AppTheme.lightSurfaceColor,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    DateFormat(
                                      'MMM dd, yyyy',
                                    ).format(_selectedEndDate),
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                  Icon(
                                    Icons.calendar_today,
                                    size: 16,
                                    color:
                                        isDarkMode
                                            ? AppTheme.darkSecondaryTextColor
                                            : AppTheme.lightSecondaryTextColor,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Priority selector
                Text(
                  context.tr('priority'),
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildPriorityOption(
                      TaskPriority.low,
                      context.tr('low'),
                      AppTheme.accentGreen,
                    ),
                    const SizedBox(width: 12),
                    _buildPriorityOption(
                      TaskPriority.medium,
                      context.tr('medium'),
                      AppTheme.accentYellow,
                    ),
                    const SizedBox(width: 12),
                    _buildPriorityOption(
                      TaskPriority.high,
                      context.tr('high'),
                      AppTheme.accentRed,
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Category selector
                Text(
                  context.tr('category'),
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 8),
                // First row of categories
                Row(
                  children: [
                    _buildCategoryOption(
                      TaskCategory.personal,
                      context.tr('personal'),
                      const Color(0xFF1E88E5), // Blue for personal
                      Icons.person_outline,
                    ),
                    const SizedBox(width: 8),
                    _buildCategoryOption(
                      TaskCategory.work,
                      context.tr('work'),
                      const Color(0xFF5E35B1), // Deep purple for work
                      Icons.work_outline,
                    ),
                    const SizedBox(width: 8),
                    _buildCategoryOption(
                      TaskCategory.shopping,
                      context.tr('shopping'),
                      const Color(0xFF00ACC1), // Teal for shopping
                      Icons.shopping_cart_outlined,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Second row of categories
                Row(
                  children: [
                    _buildCategoryOption(
                      TaskCategory.health,
                      context.tr('health'),
                      const Color(0xFF43A047), // Green for health
                      Icons.favorite_border,
                    ),
                    const SizedBox(width: 8),
                    _buildCategoryOption(
                      TaskCategory.study,
                      context.tr('study'),
                      const Color(0xFF8E24AA), // Purple for study
                      Icons.school_outlined,
                    ),
                    const SizedBox(width: 8),
                    _buildCategoryOption(
                      TaskCategory.other,
                      context.tr('other'),
                      const Color(0xFFE53935), // Red for other
                      Icons.lightbulb_outline,
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Team Assignment Section
                Text(
                  context.tr('team_assignment'),
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 8),
                _buildTeamAssignmentSection(),

                const SizedBox(height: 24),

                // Location Section
                _buildLocationSection(),

                const SizedBox(height: 40),

                // Save button
                CustomButton(
                  text:
                      isEditing
                          ? context.tr('update_task')
                          : context.tr('add_task'),
                  onPressed: _isSaving ? () {} : _saveTask,
                  icon: isEditing ? Icons.save : Icons.add_circle,
                  isLoading: _isSaving,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityOption(
    TaskPriority priority,
    String label,
    Color color,
  ) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final isSelected = _selectedPriority == priority;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedPriority = priority;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color:
                isSelected
                    ? color.withValues(alpha: 0.2)
                    : isDarkMode
                    ? AppTheme.darkSurfaceColor
                    : AppTheme.lightSurfaceColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? color : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color:
                    isSelected
                        ? color
                        : isDarkMode
                        ? AppTheme.darkSecondaryTextColor
                        : AppTheme.lightSecondaryTextColor,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryOption(
    TaskCategory category,
    String label,
    Color color,
    IconData icon,
  ) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final isSelected = _selectedCategory == category;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedCategory = category;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color:
                isSelected
                    ? color.withValues(alpha: 0.2)
                    : isDarkMode
                    ? AppTheme.darkSurfaceColor
                    : AppTheme.lightSurfaceColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? color : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color:
                    isSelected
                        ? color
                        : isDarkMode
                        ? AppTheme.darkSecondaryTextColor
                        : AppTheme.lightSecondaryTextColor,
                size: 20,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color:
                      isSelected
                          ? color
                          : isDarkMode
                          ? AppTheme.darkSecondaryTextColor
                          : AppTheme.lightSecondaryTextColor,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTeamAssignmentSection() {
    final teamProvider = Provider.of<TeamProvider>(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Team selection
        Text(
          context.tr('assign_to_team'),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color:
                isDarkMode
                    ? AppTheme.darkSecondaryTextColor
                    : AppTheme.lightSecondaryTextColor,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _showTeamSelectionDialog(),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color:
                  isDarkMode
                      ? AppTheme.darkSurfaceColor
                      : AppTheme.lightSurfaceColor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color:
                    _selectedTeamId != null
                        ? AppTheme.primaryColor
                        : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _selectedTeamId != null
                      ? teamProvider.teams
                          .firstWhere((team) => team.id == _selectedTeamId)
                          .name
                      : context.tr('select_team_optional'),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color:
                        _selectedTeamId != null
                            ? (isDarkMode
                                ? AppTheme.darkPrimaryTextColor
                                : AppTheme.lightPrimaryTextColor)
                            : (isDarkMode
                                ? AppTheme.darkSecondaryTextColor
                                : AppTheme.lightSecondaryTextColor),
                  ),
                ),
                Row(
                  children: [
                    if (_selectedTeamId != null) ...[
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedTeamId = null;
                            _selectedMemberIds.clear();
                          });
                        },
                        child: Icon(
                          Icons.clear,
                          size: 16,
                          color: AppTheme.accentRed,
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Icon(
                      Icons.arrow_drop_down,
                      size: 16,
                      color:
                          isDarkMode
                              ? AppTheme.darkSecondaryTextColor
                              : AppTheme.lightSecondaryTextColor,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // Member selection (only show if team is selected)
        if (_selectedTeamId != null) ...[
          const SizedBox(height: 16),
          Text(
            context.tr('assign_to_member'),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color:
                  isDarkMode
                      ? AppTheme.darkSecondaryTextColor
                      : AppTheme.lightSecondaryTextColor,
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => _showMemberSelectionDialog(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color:
                    isDarkMode
                        ? AppTheme.darkSurfaceColor
                        : AppTheme.lightSurfaceColor,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color:
                      _selectedMemberIds.isNotEmpty
                          ? AppTheme.primaryColor
                          : Colors.transparent,
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _selectedMemberIds.isNotEmpty
                        ? _getSelectedMembersText()
                        : context.tr('select_members_optional'),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color:
                          _selectedMemberIds.isNotEmpty
                              ? (isDarkMode
                                  ? AppTheme.darkPrimaryTextColor
                                  : AppTheme.lightPrimaryTextColor)
                              : (isDarkMode
                                  ? AppTheme.darkSecondaryTextColor
                                  : AppTheme.lightSecondaryTextColor),
                    ),
                  ),
                  Row(
                    children: [
                      if (_selectedMemberIds.isNotEmpty) ...[
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedMemberIds.clear();
                            });
                          },
                          child: Icon(
                            Icons.clear,
                            size: 16,
                            color: AppTheme.accentRed,
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Icon(
                        Icons.arrow_drop_down,
                        size: 16,
                        color:
                            isDarkMode
                                ? AppTheme.darkSecondaryTextColor
                                : AppTheme.lightSecondaryTextColor,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  String _getSelectedMembersText() {
    if (_selectedTeamId == null || _selectedMemberIds.isEmpty) return '';

    final teamProvider = Provider.of<TeamProvider>(context, listen: false);
    final team = teamProvider.teams.firstWhere(
      (team) => team.id == _selectedTeamId,
      orElse:
          () => Team(
            id: '',
            name: '',
            description: '',
            ownerId: '',
            members: [],
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
    );

    if (_selectedMemberIds.length == 1) {
      final member = team.members.firstWhere(
        (member) => member.userId == _selectedMemberIds.first,
        orElse:
            () => TeamMember(
              userId: '',
              displayName: '',
              email: '',
              role: TeamRole.member,
              joinedAt: DateTime.now(),
            ),
      );
      return member.displayName;
    } else {
      return '${_selectedMemberIds.length} members selected';
    }
  }

  void _showTeamSelectionDialog() {
    final teamProvider = Provider.of<TeamProvider>(context, listen: false);

    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: Text(context.tr('select_team')),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: Icon(Icons.person),
                    title: Text(context.tr('personal_task')),
                    subtitle: Text(context.tr('not_assigned_to_team')),
                    onTap: () {
                      setState(() {
                        _selectedTeamId = null;
                        _selectedMemberIds.clear();
                      });
                      Navigator.pop(dialogContext);
                    },
                    selected: _selectedTeamId == null,
                  ),
                  const Divider(),
                  ...teamProvider.teams.map(
                    (team) => ListTile(
                      leading: Icon(Icons.groups),
                      title: Text(team.name),
                      subtitle: Text(
                        '${team.memberCount} ${context.tr('team_members')}',
                      ),
                      onTap: () {
                        setState(() {
                          _selectedTeamId = team.id;
                          _selectedMemberIds.clear(); // Reset member selection
                        });
                        Navigator.pop(dialogContext);
                      },
                      selected: _selectedTeamId == team.id,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text(context.tr('cancel')),
              ),
            ],
          ),
    );
  }

  void _showMemberSelectionDialog() {
    if (_selectedTeamId == null) return;

    final teamProvider = Provider.of<TeamProvider>(context, listen: false);
    final team = teamProvider.teams.firstWhere(
      (team) => team.id == _selectedTeamId,
    );

    List<String> tempSelectedMemberIds = List.from(_selectedMemberIds);

    showDialog(
      context: context,
      builder:
          (dialogContext) => StatefulBuilder(
            builder:
                (context, setDialogState) => AlertDialog(
                  title: Text(context.tr('select_members')),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CheckboxListTile(
                          title: Text(context.tr('select_all_members')),
                          subtitle: Text(
                            context.tr('assign_to_all_team_members'),
                          ),
                          value:
                              tempSelectedMemberIds.length ==
                                  team.members.length &&
                              tempSelectedMemberIds.isNotEmpty,
                          tristate: true,
                          onChanged: (value) {
                            setDialogState(() {
                              if (value == true) {
                                tempSelectedMemberIds =
                                    team.members.map((m) => m.userId).toList();
                              } else {
                                tempSelectedMemberIds.clear();
                              }
                            });
                          },
                        ),
                        const Divider(),
                        ...team.members.map(
                          (member) => CheckboxListTile(
                            secondary: CircleAvatar(
                              backgroundColor: AppTheme.primaryColor.withValues(
                                alpha: 0.8,
                              ),
                              child: Text(
                                member.displayName.isNotEmpty
                                    ? member.displayName[0].toUpperCase()
                                    : 'M',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(member.displayName),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(member.email),
                                if (member.role == TeamRole.owner)
                                  Container(
                                    margin: const EdgeInsets.only(top: 4),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppTheme.accentYellow.withValues(
                                        alpha: 0.2,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      context.tr('team_owner'),
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.accentYellow,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            value: tempSelectedMemberIds.contains(
                              member.userId,
                            ),
                            onChanged: (checked) {
                              setDialogState(() {
                                if (checked == true) {
                                  tempSelectedMemberIds.add(member.userId);
                                } else {
                                  tempSelectedMemberIds.remove(member.userId);
                                }
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      child: Text(context.tr('cancel')),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _selectedMemberIds = tempSelectedMemberIds;
                        });
                        Navigator.pop(dialogContext);
                      },
                      child: Text(context.tr('ok')),
                    ),
                  ],
                ),
          ),
    );
  }

  Widget _buildLocationSection() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final hasLocation = _selectedLatitude != null && _selectedLongitude != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Location', style: Theme.of(context).textTheme.bodyLarge),
        const SizedBox(height: 8),

        if (hasLocation) ...[
          // Show current location info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color:
                  isDarkMode
                      ? AppTheme.darkSurfaceColor
                      : AppTheme.lightSurfaceColor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppTheme.primaryColor, width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      color: AppTheme.primaryColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _selectedLocationName ?? 'Selected Location',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                if (_selectedLocationAddress != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    _selectedLocationAddress!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color:
                          isDarkMode
                              ? AppTheme.darkSecondaryTextColor
                              : AppTheme.lightSecondaryTextColor,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _showLocationPicker,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.primaryColor,
                          side: BorderSide(color: AppTheme.primaryColor),
                        ),
                        child: const Text('Change Location'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _clearLocation,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.accentRed,
                          side: BorderSide(color: AppTheme.accentRed),
                        ),
                        child: const Text('Remove'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ] else ...[
          // Show add location button
          GestureDetector(
            onTap: _showLocationPicker,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color:
                    isDarkMode
                        ? AppTheme.darkSurfaceColor
                        : AppTheme.lightSurfaceColor,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.transparent, width: 1.5),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Add Location (Optional)',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color:
                          isDarkMode
                              ? AppTheme.darkSecondaryTextColor
                              : AppTheme.lightSecondaryTextColor,
                    ),
                  ),
                  Icon(
                    Icons.add_location,
                    size: 20,
                    color:
                        isDarkMode
                            ? AppTheme.darkSecondaryTextColor
                            : AppTheme.lightSecondaryTextColor,
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  void _showLocationPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            height: MediaQuery.of(context).size.height * 0.85,
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).primaryColor.withValues(alpha: 0.1),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Select Location',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ),
                // Location Picker in modal mode
                Expanded(
                  child: LocationPicker(
                    isModal: true,
                    initialLocation:
                        _selectedLatitude != null && _selectedLongitude != null
                            ? LocationData(
                              latitude: _selectedLatitude!,
                              longitude: _selectedLongitude!,
                              name: _selectedLocationName,
                              address: _selectedLocationAddress,
                            )
                            : null,
                    onLocationSelected: (locationData) {
                      setState(() {
                        _selectedLatitude = locationData.latitude;
                        _selectedLongitude = locationData.longitude;
                        _selectedLocationName = locationData.name;
                        _selectedLocationAddress = locationData.address;
                      });
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
          ),
    );
  }

  void _clearLocation() {
    setState(() {
      _selectedLatitude = null;
      _selectedLongitude = null;
      _selectedLocationName = null;
      _selectedLocationAddress = null;
    });
  }
}
