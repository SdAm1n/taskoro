import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../services/task_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

class AddEditTaskScreen extends StatefulWidget {
  final Task? task; // If null, we're adding a new task; otherwise, editing

  const AddEditTaskScreen({Key? key, this.task}) : super(key: key);

  @override
  State<AddEditTaskScreen> createState() => _AddEditTaskScreenState();
}

class _AddEditTaskScreenState extends State<AddEditTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late DateTime _selectedDate;
  late TaskPriority _selectedPriority;
  late TaskCategory _selectedCategory;

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
    _selectedDate =
        widget.task?.dueDate ?? DateTime.now().add(const Duration(days: 1));
    _selectedPriority = widget.task?.priority ?? TaskPriority.medium;
    _selectedCategory = widget.task?.category ?? TaskCategory.personal;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _saveTask() {
    if (_formKey.currentState!.validate()) {
      final taskProvider = Provider.of<TaskProvider>(context, listen: false);

      final task = Task(
        id:
            isEditing
                ? widget.task!.id
                : DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        dueDate: _selectedDate,
        priority: _selectedPriority,
        category: _selectedCategory,
        isCompleted: isEditing ? widget.task!.isCompleted : false,
        createdAt: isEditing ? widget.task!.createdAt : DateTime.now(),
      );

      if (isEditing) {
        taskProvider.updateTask(task);
      } else {
        taskProvider.addTask(task);
      }

      Navigator.pop(context);
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
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
            dialogBackgroundColor:
                isDarkMode
                    ? AppTheme.darkBackgroundColor
                    : AppTheme.lightBackgroundColor,
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
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
      appBar: CustomAppBar(title: isEditing ? 'Edit Task' : 'Add New Task'),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title field
                Text('Title', style: Theme.of(context).textTheme.bodyLarge),
                const SizedBox(height: 8),
                CustomTextField(
                  controller: _titleController,
                  hintText: 'Task title',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 24),

                // Description field
                Text(
                  'Description',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 8),
                CustomTextField(
                  controller: _descriptionController,
                  hintText: 'Task description',
                  maxLines: 4,
                ),

                const SizedBox(height: 24),

                // Due date picker
                Text('Due Date', style: Theme.of(context).textTheme.bodyLarge),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => _selectDate(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color:
                          isDarkMode
                              ? AppTheme.darkSurfaceColor
                              : AppTheme.lightSurfaceColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          DateFormat('MMMM dd, yyyy').format(_selectedDate),
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        Icon(
                          Icons.calendar_today,
                          color:
                              isDarkMode
                                  ? AppTheme.darkSecondaryTextColor
                                  : AppTheme.lightSecondaryTextColor,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Priority selector
                Text('Priority', style: Theme.of(context).textTheme.bodyLarge),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildPriorityOption(
                      TaskPriority.low,
                      'Low',
                      AppTheme.accentGreen,
                    ),
                    const SizedBox(width: 12),
                    _buildPriorityOption(
                      TaskPriority.medium,
                      'Medium',
                      AppTheme.accentYellow,
                    ),
                    const SizedBox(width: 12),
                    _buildPriorityOption(
                      TaskPriority.high,
                      'High',
                      AppTheme.accentRed,
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Category selector
                Text('Category', style: Theme.of(context).textTheme.bodyLarge),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color:
                        isDarkMode
                            ? AppTheme.darkSurfaceColor
                            : AppTheme.lightSurfaceColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: DropdownButton<TaskCategory>(
                    value: _selectedCategory,
                    isExpanded: true,
                    underline: Container(),
                    dropdownColor:
                        isDarkMode
                            ? AppTheme.darkSurfaceColor
                            : AppTheme.lightSurfaceColor,
                    icon: Icon(
                      Icons.arrow_drop_down,
                      color:
                          isDarkMode
                              ? AppTheme.darkSecondaryTextColor
                              : AppTheme.lightSecondaryTextColor,
                    ),
                    onChanged: (TaskCategory? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedCategory = newValue;
                        });
                      }
                    },
                    items:
                        TaskCategory.values.map<DropdownMenuItem<TaskCategory>>(
                          (category) {
                            return DropdownMenuItem<TaskCategory>(
                              value: category,
                              child: Text(
                                _getCategoryString(category),
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            );
                          },
                        ).toList(),
                  ),
                ),

                const SizedBox(height: 40),

                // Save button
                CustomButton(
                  text: isEditing ? 'Update Task' : 'Add Task',
                  onPressed: _saveTask,
                  icon: isEditing ? Icons.save : Icons.add_circle,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getCategoryString(TaskCategory category) {
    switch (category) {
      case TaskCategory.personal:
        return 'Personal';
      case TaskCategory.work:
        return 'Work';
      case TaskCategory.shopping:
        return 'Shopping';
      case TaskCategory.health:
        return 'Health';
      case TaskCategory.other:
        return 'Other';
    }
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
                    ? color.withOpacity(0.2)
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
}
