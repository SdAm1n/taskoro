import 'package:flutter/material.dart';
import '../models/team.dart';
import '../models/user.dart';

class TeamProvider extends ChangeNotifier {
  // Mock teams for development - in real app this would connect to backend
  List<Team> _teams = [];
  List<TeamInvitation> _invitations = [];

  List<Team> get teams => _teams;
  List<TeamInvitation> get invitations => _invitations;

  // Add sample teams for demo purposes
  TeamProvider() {
    _initializeSampleData();
  }

  void _initializeSampleData() {
    final now = DateTime.now();

    // Sample team members
    final member1 = TeamMember(
      userId: 'user1',
      email: 'john.doe@example.com',
      displayName: 'John Doe',
      role: TeamRole.admin,
      joinedAt: now.subtract(const Duration(days: 10)),
    );

    final member2 = TeamMember(
      userId: 'user2',
      email: 'jane.smith@example.com',
      displayName: 'Jane Smith',
      role: TeamRole.member,
      joinedAt: now.subtract(const Duration(days: 5)),
    );

    final member3 = TeamMember(
      userId: 'user3',
      email: 'alice.johnson@example.com',
      displayName: 'Alice Johnson',
      role: TeamRole.member,
      joinedAt: now.subtract(const Duration(days: 3)),
    );

    // Sample teams
    _teams = [
      Team(
        id: 'team1',
        name: 'Marketing Team',
        description: 'Digital marketing and content creation team',
        ownerId: 'current_user',
        members: [member1, member2],
        createdAt: now.subtract(const Duration(days: 20)),
        updatedAt: now.subtract(const Duration(days: 1)),
      ),
      Team(
        id: 'team2',
        name: 'Development Team',
        description: 'Software development and engineering team',
        ownerId: 'current_user',
        members: [member3],
        createdAt: now.subtract(const Duration(days: 15)),
        updatedAt: now.subtract(const Duration(days: 2)),
      ),
    ];

    // Sample invitation
    _invitations = [
      TeamInvitation(
        id: 'invite1',
        teamId: 'team1',
        teamName: 'Marketing Team',
        inviterUserId: 'current_user',
        inviterName: 'You',
        inviteeEmail: 'newmember@example.com',
        role: TeamRole.member,
        createdAt: now.subtract(const Duration(hours: 2)),
        expiresAt: now.add(const Duration(days: 7)),
      ),
    ];
  }

  // Create a new team
  Future<void> createTeam({
    required String name,
    required String description,
    required AppUser owner,
  }) async {
    final team = Team(
      id: 'team_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      description: description,
      ownerId: owner.id,
      members: [], // Start with empty members list
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    _teams.add(team);
    notifyListeners();
  }

  // Update team information
  Future<void> updateTeam(Team updatedTeam) async {
    final index = _teams.indexWhere((team) => team.id == updatedTeam.id);
    if (index != -1) {
      _teams[index] = updatedTeam.copyWith(updatedAt: DateTime.now());
      notifyListeners();
    }
  }

  // Delete a team
  Future<void> deleteTeam(String teamId) async {
    _teams.removeWhere((team) => team.id == teamId);
    // Also remove related invitations
    _invitations.removeWhere((invitation) => invitation.teamId == teamId);
    notifyListeners();
  }

  // Get team by ID
  Team? getTeamById(String teamId) {
    try {
      return _teams.firstWhere((team) => team.id == teamId);
    } catch (e) {
      return null;
    }
  }

  // Get teams where user is owner
  List<Team> getOwnedTeams(String userId) {
    return _teams.where((team) => team.ownerId == userId).toList();
  }

  // Get teams where user is a member
  List<Team> getMemberTeams(String userId) {
    return _teams
        .where((team) => team.members.any((member) => member.userId == userId))
        .toList();
  }

  // Get all teams where user has access (owned or member)
  List<Team> getUserTeams(String userId) {
    return _teams
        .where(
          (team) =>
              team.ownerId == userId ||
              team.members.any((member) => member.userId == userId),
        )
        .toList();
  }

  // Send team invitation
  Future<void> inviteToTeam({
    required String teamId,
    required String inviteeEmail,
    required TeamRole role,
    required AppUser inviter,
  }) async {
    final team = getTeamById(teamId);
    if (team == null) return;

    final invitation = TeamInvitation(
      id: 'invite_${DateTime.now().millisecondsSinceEpoch}',
      teamId: teamId,
      teamName: team.name,
      inviterUserId: inviter.id,
      inviterName: inviter.displayName,
      inviteeEmail: inviteeEmail,
      role: role,
      createdAt: DateTime.now(),
      expiresAt: DateTime.now().add(
        const Duration(days: 7),
      ), // 7 days to accept
    );

    _invitations.add(invitation);
    notifyListeners();

    // In a real app, you would send an email here
    // For demo purposes, we'll just show a success message
  }

  // Accept team invitation
  Future<void> acceptInvitation(String invitationId, AppUser user) async {
    final invitationIndex = _invitations.indexWhere(
      (inv) => inv.id == invitationId,
    );
    if (invitationIndex == -1) return;

    final invitation = _invitations[invitationIndex];
    if (!invitation.isValid) return;

    // Add user to team
    final teamIndex = _teams.indexWhere((team) => team.id == invitation.teamId);
    if (teamIndex != -1) {
      final newMember = TeamMember(
        userId: user.id,
        email: user.email,
        displayName: user.displayName,
        role: invitation.role,
        joinedAt: DateTime.now(),
      );

      final updatedTeam = _teams[teamIndex].copyWith(
        members: [..._teams[teamIndex].members, newMember],
        updatedAt: DateTime.now(),
      );

      _teams[teamIndex] = updatedTeam;
    }

    // Mark invitation as accepted
    _invitations[invitationIndex] = invitation.copyWith(isAccepted: true);
    notifyListeners();
  }

  // Decline team invitation
  Future<void> declineInvitation(String invitationId) async {
    _invitations.removeWhere((invitation) => invitation.id == invitationId);
    notifyListeners();
  }

  // Remove member from team
  Future<void> removeMemberFromTeam(String teamId, String memberId) async {
    final teamIndex = _teams.indexWhere((team) => team.id == teamId);
    if (teamIndex == -1) return;

    final team = _teams[teamIndex];
    final updatedMembers =
        team.members.where((member) => member.userId != memberId).toList();

    _teams[teamIndex] = team.copyWith(
      members: updatedMembers,
      updatedAt: DateTime.now(),
    );
    notifyListeners();
  }

  // Update member role
  Future<void> updateMemberRole(
    String teamId,
    String memberId,
    TeamRole newRole,
  ) async {
    final teamIndex = _teams.indexWhere((team) => team.id == teamId);
    if (teamIndex == -1) return;

    final team = _teams[teamIndex];
    final updatedMembers =
        team.members.map((member) {
          if (member.userId == memberId) {
            return member.copyWith(role: newRole);
          }
          return member;
        }).toList();

    _teams[teamIndex] = team.copyWith(
      members: updatedMembers,
      updatedAt: DateTime.now(),
    );
    notifyListeners();
  }

  // Alias method for changing member role (used by team detail screen)
  Future<void> changeMemberRole(
    String teamId,
    String memberId,
    TeamRole newRole,
  ) async {
    return updateMemberRole(teamId, memberId, newRole);
  }

  // Alias method for removing member (used by team detail screen)
  Future<void> removeMember(String teamId, String memberId) async {
    return removeMemberFromTeam(teamId, memberId);
  }

  // Update team with individual parameters (used by team detail screen)
  Future<void> updateTeamById(
    String teamId,
    String name,
    String description,
  ) async {
    final teamIndex = _teams.indexWhere((team) => team.id == teamId);
    if (teamIndex == -1) return;

    final team = _teams[teamIndex];
    _teams[teamIndex] = team.copyWith(
      name: name,
      description: description,
      updatedAt: DateTime.now(),
    );
    notifyListeners();
  }

  // Get pending invitations for a team
  List<TeamInvitation> getTeamInvitations(String teamId) {
    return _invitations
        .where(
          (invitation) => invitation.teamId == teamId && !invitation.isAccepted,
        )
        .toList();
  }

  // Get all pending invitations sent by user
  List<TeamInvitation> getUserSentInvitations(String userId) {
    return _invitations
        .where(
          (invitation) =>
              invitation.inviterUserId == userId && !invitation.isAccepted,
        )
        .toList();
  }

  // Cancel invitation
  Future<void> cancelInvitation(String invitationId) async {
    _invitations.removeWhere((invitation) => invitation.id == invitationId);
    notifyListeners();
  }

  // Clean up expired invitations
  void cleanUpExpiredInvitations() {
    final now = DateTime.now();
    _invitations.removeWhere(
      (invitation) =>
          invitation.expiresAt.isBefore(now) && !invitation.isAccepted,
    );
    notifyListeners();
  }
}
