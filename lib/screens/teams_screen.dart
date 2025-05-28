import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/team.dart';
import '../models/user.dart';
import '../services/team_provider.dart';
import '../services/task_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../localization/translation_helper.dart';
import 'team_detail_screen.dart';

class TeamsScreen extends StatefulWidget {
  const TeamsScreen({super.key});

  @override
  State<TeamsScreen> createState() => _TeamsScreenState();
}

class _TeamsScreenState extends State<TeamsScreen> {
  @override
  void initState() {
    super.initState();
    // Clean up expired invitations on screen load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TeamProvider>(
        context,
        listen: false,
      ).cleanUpExpiredInvitations();
    });
  }

  @override
  Widget build(BuildContext context) {
    final teamProvider = Provider.of<TeamProvider>(context);
    final taskProvider = Provider.of<TaskProvider>(context);
    final currentUser = taskProvider.currentUser;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDarkMode
              ? AppTheme.darkBackgroundColor
              : AppTheme.lightBackgroundColor,
      appBar: CustomAppBar(
        title: context.tr('teams'),
        automaticallyImplyLeading: false,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // In a real app, this would fetch teams from the server
          teamProvider.cleanUpExpiredInvitations();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with create team button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    context.tr('my_teams'),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color:
                          isDarkMode
                              ? AppTheme.darkPrimaryTextColor
                              : AppTheme.lightPrimaryTextColor,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _showCreateTeamDialog(context),
                    icon: const Icon(Icons.add, size: 18),
                    label: Text(context.tr('create_team')),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Teams list
              if (teamProvider.teams.isEmpty)
                _buildEmptyState(context)
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: teamProvider.teams.length,
                  separatorBuilder:
                      (context, index) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final team = teamProvider.teams[index];
                    return _buildTeamCard(context, team, currentUser);
                  },
                ),

              const SizedBox(height: 24),

              // Pending invitations section
              if (teamProvider.invitations.isNotEmpty) ...[
                Text(
                  context.tr('pending_invitations'),
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
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: teamProvider.invitations.length,
                  separatorBuilder:
                      (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final invitation = teamProvider.invitations[index];
                    return _buildInvitationCard(context, invitation);
                  },
                ),
                const SizedBox(height: 20),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Column(
        children: [
          const SizedBox(height: 60),
          Icon(
            Icons.groups_outlined,
            size: 80,
            color:
                isDarkMode
                    ? AppTheme.darkDisabledTextColor
                    : AppTheme.lightDisabledTextColor,
          ),
          const SizedBox(height: 16),
          Text(
            context.tr('no_teams_found'),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color:
                  isDarkMode
                      ? AppTheme.darkSecondaryTextColor
                      : AppTheme.lightSecondaryTextColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            context.tr('create_first_team'),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color:
                  isDarkMode
                      ? AppTheme.darkDisabledTextColor
                      : AppTheme.lightDisabledTextColor,
            ),
          ),
          const SizedBox(height: 24),
          CustomButton(
            text: context.tr('create_team'),
            onPressed: () => _showCreateTeamDialog(context),
            icon: Icons.add,
            width: 200,
          ),
        ],
      ),
    );
  }

  Widget _buildTeamCard(BuildContext context, Team team, AppUser currentUser) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final isOwner = team.isOwner(currentUser.id);

    return GestureDetector(
      onTap: () => _navigateToTeamDetail(context, team),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDarkMode ? AppTheme.darkCardColor : AppTheme.lightCardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Team header
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.groups, color: Colors.white, size: 24),
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
                              team.name,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color:
                                    isDarkMode
                                        ? AppTheme.darkPrimaryTextColor
                                        : AppTheme.lightPrimaryTextColor,
                              ),
                            ),
                          ),
                          if (isOwner)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                context.tr('team_owner'),
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
                        team.description,
                        style: TextStyle(
                          fontSize: 14,
                          color:
                              isDarkMode
                                  ? AppTheme.darkSecondaryTextColor
                                  : AppTheme.lightSecondaryTextColor,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
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
                          value: 'invite',
                          child: Row(
                            children: [
                              const Icon(Icons.person_add_outlined),
                              const SizedBox(width: 8),
                              Text(context.tr('invite_member')),
                            ],
                          ),
                        ),
                        if (isOwner) ...[
                          PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                const Icon(Icons.edit_outlined),
                                const SizedBox(width: 8),
                                Text(context.tr('edit')),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.delete_outline,
                                  color: AppTheme.accentRed,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  context.tr('delete_team'),
                                  style: const TextStyle(
                                    color: AppTheme.accentRed,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ] else
                          PopupMenuItem(
                            value: 'leave',
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.exit_to_app,
                                  color: AppTheme.accentRed,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  context.tr('leave_team'),
                                  style: const TextStyle(
                                    color: AppTheme.accentRed,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                  onSelected:
                      (value) =>
                          _handleTeamAction(context, value, team, currentUser),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Team stats
            Row(
              children: [
                _buildStatItem(
                  context,
                  Icons.people_outline,
                  '${team.memberCount}',
                  context.tr('team_members'),
                ),
                const SizedBox(width: 20),
                _buildStatItem(
                  context,
                  Icons.access_time,
                  '${DateTime.now().difference(team.createdAt).inDays}',
                  context.tr('days'),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Team members preview
            if (team.members.isNotEmpty) ...[
              Text(
                context.tr('team_members'),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color:
                      isDarkMode
                          ? AppTheme.darkPrimaryTextColor
                          : AppTheme.lightPrimaryTextColor,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 32,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: team.members.length > 5 ? 6 : team.members.length,
                  itemBuilder: (context, index) {
                    if (index == 5) {
                      // Show "+X more" indicator
                      return Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.2),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color:
                                isDarkMode
                                    ? AppTheme.darkBackgroundColor
                                    : AppTheme.lightBackgroundColor,
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            '+${team.members.length - 5}',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        ),
                      );
                    }

                    final member = team.members[index];
                    return Container(
                      width: 32,
                      height: 32,
                      margin: EdgeInsets.only(right: index < 4 ? 4 : 0),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.8),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color:
                              isDarkMode
                                  ? AppTheme.darkBackgroundColor
                                  : AppTheme.lightBackgroundColor,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          member.displayName.isNotEmpty
                              ? member.displayName[0].toUpperCase()
                              : 'M',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],

            const SizedBox(height: 12),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed:
                        () =>
                            _showTeamDetailsDialog(context, team, currentUser),
                    icon: const Icon(Icons.visibility_outlined, size: 16),
                    label: Text(context.tr('view_all')),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primaryColor,
                      side: BorderSide(color: AppTheme.primaryColor),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showInviteMemberDialog(context, team),
                    icon: const Icon(Icons.person_add, size: 16),
                    label: Text(context.tr('invite_member')),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToTeamDetail(BuildContext context, Team team) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TeamDetailScreen(team: team)),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    IconData icon,
    String value,
    String label,
  ) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        Icon(icon, size: 16, color: AppTheme.primaryColor),
        const SizedBox(width: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color:
                isDarkMode
                    ? AppTheme.darkPrimaryTextColor
                    : AppTheme.lightPrimaryTextColor,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color:
                isDarkMode
                    ? AppTheme.darkSecondaryTextColor
                    : AppTheme.lightSecondaryTextColor,
          ),
        ),
      ],
    );
  }

  Widget _buildInvitationCard(BuildContext context, TeamInvitation invitation) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.accentYellow.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.accentYellow.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.mail_outline, color: AppTheme.accentYellow, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  invitation.teamName,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color:
                        isDarkMode
                            ? AppTheme.darkPrimaryTextColor
                            : AppTheme.lightPrimaryTextColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'To: ${invitation.inviteeEmail}',
                  style: TextStyle(
                    fontSize: 12,
                    color:
                        isDarkMode
                            ? AppTheme.darkSecondaryTextColor
                            : AppTheme.lightSecondaryTextColor,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              Provider.of<TeamProvider>(
                context,
                listen: false,
              ).cancelInvitation(invitation.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(context.tr('invitation_cancelled')),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: Text(
              context.tr('cancel'),
              style: const TextStyle(color: AppTheme.accentRed),
            ),
          ),
        ],
      ),
    );
  }

  void _handleTeamAction(
    BuildContext context,
    String action,
    Team team,
    AppUser currentUser,
  ) {
    switch (action) {
      case 'invite':
        _showInviteMemberDialog(context, team);
        break;
      case 'edit':
        _showEditTeamDialog(context, team);
        break;
      case 'delete':
        _showDeleteConfirmation(context, team);
        break;
      case 'leave':
        _showLeaveConfirmation(context, team, currentUser);
        break;
    }
  }

  void _showCreateTeamDialog(BuildContext context) {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: Text(context.tr('create_team')),
            content: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomTextField(
                    controller: nameController,
                    hintText: context.tr('team_name'),
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return context.tr('please_enter_title');
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: descriptionController,
                    hintText: context.tr('team_description'),
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
                    final taskProvider = Provider.of<TaskProvider>(
                      context,
                      listen: false,
                    );

                    teamProvider.createTeam(
                      name: nameController.text,
                      description: descriptionController.text,
                      owner: taskProvider.currentUser,
                    );

                    Navigator.pop(dialogContext);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(context.tr('team_created')),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                },
                child: Text(context.tr('create_team')),
              ),
            ],
          ),
    );
  }

  void _showEditTeamDialog(BuildContext context, Team team) {
    final nameController = TextEditingController(text: team.name);
    final descriptionController = TextEditingController(text: team.description);
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: Text(context.tr('edit')),
            content: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomTextField(
                    controller: nameController,
                    hintText: context.tr('team_name'),
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return context.tr('please_enter_title');
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: descriptionController,
                    hintText: context.tr('team_description'),
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

                    final updatedTeam = team.copyWith(
                      name: nameController.text,
                      description: descriptionController.text,
                    );

                    teamProvider.updateTeam(updatedTeam);

                    Navigator.pop(dialogContext);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(context.tr('team_updated')),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                },
                child: Text(context.tr('save')),
              ),
            ],
          ),
    );
  }

  void _showInviteMemberDialog(BuildContext context, Team team) {
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
                        CustomTextField(
                          controller: emailController,
                          hintText: context.tr('member_email'),
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
                            teamId: team.id,
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

  void _showTeamDetailsDialog(
    BuildContext context,
    Team team,
    AppUser currentUser,
  ) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder:
          (dialogContext) => Dialog(
            child: Container(
              width: double.maxFinite,
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.8,
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          team.name,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color:
                                isDarkMode
                                    ? AppTheme.darkPrimaryTextColor
                                    : AppTheme.lightPrimaryTextColor,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    team.description,
                    style: TextStyle(
                      fontSize: 14,
                      color:
                          isDarkMode
                              ? AppTheme.darkSecondaryTextColor
                              : AppTheme.lightSecondaryTextColor,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    context.tr('team_members'),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color:
                          isDarkMode
                              ? AppTheme.darkPrimaryTextColor
                              : AppTheme.lightPrimaryTextColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Flexible(
                    child:
                        team.members.isEmpty
                            ? Center(
                              child: Text(
                                'No members yet',
                                style: TextStyle(
                                  color:
                                      isDarkMode
                                          ? AppTheme.darkSecondaryTextColor
                                          : AppTheme.lightSecondaryTextColor,
                                ),
                              ),
                            )
                            : ListView.builder(
                              shrinkWrap: true,
                              itemCount: team.members.length,
                              itemBuilder: (context, index) {
                                final member = team.members[index];
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color:
                                        isDarkMode
                                            ? AppTheme.darkSurfaceColor
                                            : AppTheme.lightSurfaceColor,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 16,
                                        backgroundColor: AppTheme.primaryColor
                                            .withOpacity(0.8),
                                        child: Text(
                                          member.displayName.isNotEmpty
                                              ? member.displayName[0]
                                                  .toUpperCase()
                                              : 'M',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              member.displayName,
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                                color:
                                                    isDarkMode
                                                        ? AppTheme
                                                            .darkPrimaryTextColor
                                                        : AppTheme
                                                            .lightPrimaryTextColor,
                                              ),
                                            ),
                                            Text(
                                              member.email,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color:
                                                    isDarkMode
                                                        ? AppTheme
                                                            .darkSecondaryTextColor
                                                        : AppTheme
                                                            .lightSecondaryTextColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppTheme.primaryColor
                                              .withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
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
                                );
                              },
                            ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Team team) {
    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: Text(context.tr('delete_team')),
            content: Text(context.tr('confirm_delete_team')),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text(context.tr('cancel')),
              ),
              ElevatedButton(
                onPressed: () {
                  Provider.of<TeamProvider>(
                    context,
                    listen: false,
                  ).deleteTeam(team.id);
                  Navigator.pop(dialogContext);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Team deleted'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentRed,
                ),
                child: Text(
                  context.tr('delete'),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

  void _showLeaveConfirmation(
    BuildContext context,
    Team team,
    AppUser currentUser,
  ) {
    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: Text(context.tr('leave_team')),
            content: Text(context.tr('confirm_leave_team')),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text(context.tr('cancel')),
              ),
              ElevatedButton(
                onPressed: () {
                  Provider.of<TeamProvider>(
                    context,
                    listen: false,
                  ).removeMemberFromTeam(team.id, currentUser.id);
                  Navigator.pop(dialogContext);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Left team'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentRed,
                ),
                child: Text(
                  context.tr('leave_team'),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }
}
