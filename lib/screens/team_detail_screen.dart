import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/team.dart';
import '../models/task.dart';
import '../services/team_provider.dart';
import '../services/task_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_button.dart';
import '../widgets/task_card.dart';
import '../localization/translation_helper.dart';
import 'add_edit_task_screen.dart';

class TeamDetailScreen extends StatefulWidget {
  final Team team;

  const TeamDetailScreen({super.key, required this.team});

  @override
  State<TeamDetailScreen> createState() => _TeamDetailScreenState();
}

class _TeamDetailScreenState extends State<TeamDetailScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _selectedTab = _tabController.index;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final taskProvider = Provider.of<TaskProvider>(context);
    final currentUser = taskProvider.currentUser;
    final isOwner = widget.team.isOwner(currentUser.id);
    final teamTasks = taskProvider.getTasksForTeam(widget.team.id);

    return Scaffold(
      backgroundColor:
          isDarkMode
              ? AppTheme.darkBackgroundColor
              : AppTheme.lightBackgroundColor,
      appBar: CustomAppBar(
        title: widget.team.name,
        actions: [
          if (isOwner)
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () => _showTeamSettingsDialog(context),
            ),
        ],
      ),
      body: Column(
        children: [
          // Team info header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.groups,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  widget.team.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.team.description,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatCard(
                      context.tr('members'),
                      widget.team.members.length.toString(),
                      Icons.people,
                    ),
                    _buildStatCard(
                      context.tr('tasks'),
                      teamTasks.length.toString(),
                      Icons.task_alt,
                    ),
                    _buildStatCard(
                      context.tr('completed'),
                      teamTasks.where((t) => t.isCompleted).length.toString(),
                      Icons.check_circle,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Tab bar
          Container(
            color:
                isDarkMode
                    ? AppTheme.darkSurfaceColor
                    : AppTheme.lightSurfaceColor,
            child: TabBar(
              controller: _tabController,
              indicatorColor: AppTheme.primaryColor,
              indicatorWeight: 3,
              labelColor: AppTheme.primaryColor,
              unselectedLabelColor:
                  isDarkMode
                      ? AppTheme.darkSecondaryTextColor
                      : AppTheme.lightSecondaryTextColor,
              tabs: [
                Tab(text: context.tr('Tasks')),
                Tab(text: context.tr('Members')),
                Tab(text: context.tr('Progress')),
              ],
            ),
          ),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTasksTab(context, teamTasks),
                _buildMembersTab(context),
                _buildProgressTab(context, teamTasks),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton:
          _selectedTab == 0
              ? FloatingActionButton.extended(
                onPressed: () => _createNewTask(context),
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                icon: const Icon(Icons.add),
                label: Text(context.tr('add_task')),
              )
              : null,
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTasksTab(BuildContext context, List<Task> teamTasks) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    if (teamTasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.task_outlined,
              size: 80,
              color:
                  isDarkMode
                      ? AppTheme.darkDisabledTextColor
                      : AppTheme.lightDisabledTextColor,
            ),
            const SizedBox(height: 16),
            Text(
              context.tr('No Team Tasks'),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color:
                    isDarkMode
                        ? AppTheme.darkSecondaryTextColor
                        : AppTheme.lightSecondaryTextColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              context.tr('Create First Team Task'),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color:
                    isDarkMode
                        ? AppTheme.darkDisabledTextColor
                        : AppTheme.lightDisabledTextColor,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: teamTasks.length,
      itemBuilder: (context, index) {
        final task = teamTasks[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: TaskCard(
            task: task,
            onTap: () {
              // Navigate to task detail screen
              Navigator.pushNamed(context, '/task-detail', arguments: task);
            },
            onDelete: () {
              // Delete task
              final taskProvider = Provider.of<TaskProvider>(
                context,
                listen: false,
              );
              taskProvider.deleteTask(task.id);
            },
            onToggleCompleted: () {
              // Toggle task completion
              final taskProvider = Provider.of<TaskProvider>(
                context,
                listen: false,
              );
              final updatedTask = task.copyWith(isCompleted: !task.isCompleted);
              taskProvider.updateTask(updatedTask);
            },
          ),
        );
      },
    );
  }

  Widget _buildMembersTab(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final currentUser = taskProvider.currentUser;
    final isOwner = widget.team.isOwner(currentUser.id);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (isOwner || widget.team.isAdminOrOwner(currentUser.id))
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            child: CustomButton(
              text: context.tr('invite_member'),
              onPressed: () => _showInviteMemberDialog(context),
              icon: Icons.person_add,
            ),
          ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: widget.team.members.length,
          itemBuilder: (context, index) {
            final member = widget.team.members[index];
            return _buildMemberCard(context, member, isOwner);
          },
        ),
      ],
    );
  }

  Widget _buildMemberCard(
    BuildContext context,
    TeamMember member,
    bool canManage,
  ) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final taskProvider = Provider.of<TaskProvider>(context);
    final memberTasks = taskProvider.getTasksForTeamMember(
      widget.team.id,
      member.userId,
    );
    final completedTasks = memberTasks.where((t) => t.isCompleted).length;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? AppTheme.darkCardColor : AppTheme.lightCardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppTheme.primaryColor,
            child: Text(
              member.displayName.isNotEmpty
                  ? member.displayName[0].toUpperCase()
                  : '?',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        member.displayName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color:
                              isDarkMode
                                  ? AppTheme.darkPrimaryTextColor
                                  : AppTheme.lightPrimaryTextColor,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        member.getRoleDisplayName(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${context.tr('tasks')}: $completedTasks/${memberTasks.length} ${context.tr('completed')}',
                  style: TextStyle(
                    fontSize: 14,
                    color:
                        isDarkMode
                            ? AppTheme.darkSecondaryTextColor
                            : AppTheme.lightSecondaryTextColor,
                  ),
                ),
                if (memberTasks.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value:
                        memberTasks.isNotEmpty
                            ? (completedTasks / memberTasks.length).toDouble()
                            : 0.0,
                    backgroundColor:
                        isDarkMode
                            ? AppTheme.darkDisabledTextColor
                            : AppTheme.lightDisabledTextColor,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppTheme.primaryColor,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (canManage && member.role != TeamRole.owner)
            PopupMenuButton<String>(
              icon: Icon(
                Icons.more_vert,
                color:
                    isDarkMode
                        ? AppTheme.darkSecondaryTextColor
                        : AppTheme.lightSecondaryTextColor,
              ),
              itemBuilder:
                  (context) => [
                    PopupMenuItem(
                      value: 'change_role',
                      child: Row(
                        children: [
                          const Icon(Icons.admin_panel_settings),
                          const SizedBox(width: 8),
                          Text(context.tr('change_role')),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'remove',
                      child: Row(
                        children: [
                          Icon(Icons.remove_circle, color: AppTheme.accentRed),
                          const SizedBox(width: 8),
                          Text(
                            context.tr('remove_member'),
                            style: TextStyle(color: AppTheme.accentRed),
                          ),
                        ],
                      ),
                    ),
                  ],
              onSelected: (value) {
                switch (value) {
                  case 'change_role':
                    _showChangeRoleDialog(context, member);
                    break;
                  case 'remove':
                    _showRemoveMemberDialog(context, member);
                    break;
                }
              },
            ),
        ],
      ),
    );
  }

  Widget _buildProgressTab(BuildContext context, List<Task> teamTasks) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final completedTasks = teamTasks.where((t) => t.isCompleted).length;
    final totalTasks = teamTasks.length;
    final progressPercentage =
        totalTasks > 0 ? (completedTasks / totalTasks) * 100 : 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Overall progress card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color:
                  isDarkMode ? AppTheme.darkCardColor : AppTheme.lightCardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  context.tr('Team Progress'),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color:
                        isDarkMode
                            ? AppTheme.darkPrimaryTextColor
                            : AppTheme.lightPrimaryTextColor,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: 120,
                  height: 120,
                  child: CircularProgressIndicator(
                    value: totalTasks > 0 ? completedTasks / totalTasks : 0,
                    strokeWidth: 8,
                    backgroundColor:
                        isDarkMode
                            ? AppTheme.darkDisabledTextColor
                            : AppTheme.lightDisabledTextColor,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppTheme.primaryColor,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '${progressPercentage.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
                Text(
                  '$completedTasks ${context.tr('of')} $totalTasks ${context.tr('Tasks Completed')}',
                  style: TextStyle(
                    fontSize: 14,
                    color:
                        isDarkMode
                            ? AppTheme.darkSecondaryTextColor
                            : AppTheme.lightSecondaryTextColor,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Member progress
          Text(
            context.tr('Member Progress'),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color:
                  isDarkMode
                      ? AppTheme.darkPrimaryTextColor
                      : AppTheme.lightPrimaryTextColor,
            ),
          ),
          const SizedBox(height: 16),

          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.team.members.length,
            itemBuilder: (context, index) {
              final member = widget.team.members[index];
              return _buildMemberProgressCard(context, member);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMemberProgressCard(BuildContext context, TeamMember member) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final taskProvider = Provider.of<TaskProvider>(context);
    final memberTasks = taskProvider.getTasksForTeamMember(
      widget.team.id,
      member.userId,
    );
    final completedTasks = memberTasks.where((t) => t.isCompleted).length;
    final memberProgress =
        memberTasks.isNotEmpty
            ? (completedTasks / memberTasks.length).toDouble()
            : 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? AppTheme.darkCardColor : AppTheme.lightCardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppTheme.primaryColor,
            child: Text(
              member.displayName.isNotEmpty
                  ? member.displayName[0].toUpperCase()
                  : '?',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.displayName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color:
                        isDarkMode
                            ? AppTheme.darkPrimaryTextColor
                            : AppTheme.lightPrimaryTextColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$completedTasks/${memberTasks.length} ${context.tr('Tasks Completed')}',
                  style: TextStyle(
                    fontSize: 14,
                    color:
                        isDarkMode
                            ? AppTheme.darkSecondaryTextColor
                            : AppTheme.lightSecondaryTextColor,
                  ),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: memberProgress,
                  backgroundColor:
                      isDarkMode
                          ? AppTheme.darkDisabledTextColor
                          : AppTheme.lightDisabledTextColor,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${(memberProgress * 100).toStringAsFixed(0)}%',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  void _createNewTask(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => AddEditTaskScreen(
              task: null,
              preSelectedTeamId: widget.team.id,
            ),
      ),
    );
  }

  void _showInviteMemberDialog(BuildContext context) {
    // Implementation similar to teams_screen.dart
    final emailController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    TeamRole selectedRole = TeamRole.member;

    showDialog(
      context: context,
      builder:
          (dialogContext) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  title: Text(context.tr('invite_member')),
                  content: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          controller: emailController,
                          decoration: InputDecoration(
                            labelText: context.tr('member_email'),
                            border: const OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return context.tr('invalid_email');
                            }
                            if (!RegExp(
                              r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                            ).hasMatch(value!)) {
                              return context.tr('invalid_email');
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<TeamRole>(
                          value: selectedRole,
                          decoration: InputDecoration(
                            labelText: context.tr('change_role'),
                            border: const OutlineInputBorder(),
                          ),
                          dropdownColor:
                              Theme.of(context).brightness == Brightness.dark
                                  ? AppTheme.darkSurfaceColor
                                  : AppTheme.lightSurfaceColor,
                          style: TextStyle(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? AppTheme.darkPrimaryTextColor
                                    : AppTheme.lightPrimaryTextColor,
                          ),
                          items: [
                            DropdownMenuItem(
                              value: TeamRole.member,
                              child: Text(
                                context.tr('team_member'),
                                style: TextStyle(
                                  color:
                                      Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? AppTheme.darkPrimaryTextColor
                                          : AppTheme.lightPrimaryTextColor,
                                ),
                              ),
                            ),
                            DropdownMenuItem(
                              value: TeamRole.admin,
                              child: Text(
                                context.tr('team_admin'),
                                style: TextStyle(
                                  color:
                                      Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? AppTheme.darkPrimaryTextColor
                                          : AppTheme.lightPrimaryTextColor,
                                ),
                              ),
                            ),
                          ],
                          onChanged:
                              (role) => setState(() => selectedRole = role!),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      child: Text(context.tr('cancel')),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (formKey.currentState?.validate() ?? false) {
                          final teamProvider = Provider.of<TeamProvider>(
                            context,
                            listen: false,
                          );
                          final taskProvider = Provider.of<TaskProvider>(
                            context,
                            listen: false,
                          );

                          teamProvider.inviteToTeam(
                            teamId: widget.team.id,
                            inviteeEmail: emailController.text,
                            role: selectedRole,
                            inviter: taskProvider.currentUser,
                          );

                          Navigator.pop(dialogContext);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(context.tr('invitation_sent')),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                      child: Text(context.tr('send_invitation')),
                    ),
                  ],
                ),
          ),
    );
  }

  void _showChangeRoleDialog(BuildContext context, TeamMember member) {
    TeamRole selectedRole = member.role;

    showDialog(
      context: context,
      builder:
          (dialogContext) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  title: Text(context.tr('change_role')),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${context.tr('change_role_for')} ${member.displayName}',
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<TeamRole>(
                        value: selectedRole,
                        decoration: InputDecoration(
                          labelText: context.tr('change_role'),
                          border: const OutlineInputBorder(),
                        ),
                        dropdownColor:
                            Theme.of(context).brightness == Brightness.dark
                                ? AppTheme.darkSurfaceColor
                                : AppTheme.lightSurfaceColor,
                        style: TextStyle(
                          color:
                              Theme.of(context).brightness == Brightness.dark
                                  ? AppTheme.darkPrimaryTextColor
                                  : AppTheme.lightPrimaryTextColor,
                        ),
                        items: [
                          DropdownMenuItem(
                            value: TeamRole.member,
                            child: Text(
                              context.tr('team_member'),
                              style: TextStyle(
                                color:
                                    Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? AppTheme.darkPrimaryTextColor
                                        : AppTheme.lightPrimaryTextColor,
                              ),
                            ),
                          ),
                          DropdownMenuItem(
                            value: TeamRole.admin,
                            child: Text(
                              context.tr('team_admin'),
                              style: TextStyle(
                                color:
                                    Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? AppTheme.darkPrimaryTextColor
                                        : AppTheme.lightPrimaryTextColor,
                              ),
                            ),
                          ),
                        ],
                        onChanged:
                            (role) => setState(() => selectedRole = role!),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      child: Text(context.tr('cancel')),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        final teamProvider = Provider.of<TeamProvider>(
                          context,
                          listen: false,
                        );
                        teamProvider.changeMemberRole(
                          widget.team.id,
                          member.userId,
                          selectedRole,
                        );
                        Navigator.pop(dialogContext);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(context.tr('role_updated')),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                      child: Text(context.tr('update')),
                    ),
                  ],
                ),
          ),
    );
  }

  void _showRemoveMemberDialog(BuildContext context, TeamMember member) {
    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: Text(context.tr('remove_member')),
            content: Text(
              '${context.tr('remove_member_confirm')} ${member.displayName}?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text(context.tr('cancel')),
              ),
              ElevatedButton(
                onPressed: () {
                  final teamProvider = Provider.of<TeamProvider>(
                    context,
                    listen: false,
                  );
                  teamProvider.removeMember(widget.team.id, member.userId);
                  Navigator.pop(dialogContext);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(context.tr('member_removed')),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentRed,
                  foregroundColor: Colors.white,
                ),
                child: Text(context.tr('remove')),
              ),
            ],
          ),
    );
  }

  void _showTeamSettingsDialog(BuildContext context) {
    // Implementation for team settings (edit name, description, etc.)
    final nameController = TextEditingController(text: widget.team.name);
    final descriptionController = TextEditingController(
      text: widget.team.description,
    );
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: Text(context.tr('team_settings')),
            content: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: context.tr('team_name'),
                      border: const OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value?.trim().isEmpty ?? true) {
                        return context.tr('team_name_required');
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: descriptionController,
                    decoration: InputDecoration(
                      labelText: context.tr('team_description'),
                      border: const OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text(context.tr('cancel')),
              ),
              ElevatedButton(
                onPressed: () {
                  if (formKey.currentState?.validate() ?? false) {
                    final teamProvider = Provider.of<TeamProvider>(
                      context,
                      listen: false,
                    );
                    teamProvider.updateTeamById(
                      widget.team.id,
                      nameController.text.trim(),
                      descriptionController.text.trim(),
                    );
                    Navigator.pop(dialogContext);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(context.tr('team_updated')),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                },
                child: Text(context.tr('update')),
              ),
            ],
          ),
    );
  }
}
