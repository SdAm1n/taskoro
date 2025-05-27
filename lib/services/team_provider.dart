import 'package:flutter/material.dart';
import 'dart:async';
import '../models/team.dart';
import '../models/user.dart';
import 'firebase_team_service.dart';
import 'firebase_user_service.dart';

class TeamProvider extends ChangeNotifier {
  final FirebaseTeamService _teamService = FirebaseTeamService();
  final FirebaseUserService _userService = FirebaseUserService();

  // Current user and teams
  AppUser _currentUser = AppUser.empty();
  List<Team> _teams = [];
  List<TeamInvitation> _invitations = [];
  StreamSubscription<List<Team>>? _teamsSubscription;
  StreamSubscription<List<TeamInvitation>>? _invitationsSubscription;
  StreamSubscription<AppUser?>? _userSubscription;

  // Loading states
  bool _isLoading = false;
  bool _isInitialized = false;

  // Constructor
  TeamProvider() {
    _initializeProvider();
  }

  // Initialize the provider with Firebase data
  void _initializeProvider() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Listen to user profile changes
      _userSubscription = _userService.getCurrentUserProfileStream().listen((
        user,
      ) {
        if (user != null) {
          _currentUser = user;
          _setupTeamsListener();
          _setupInvitationsListener();
        }
        notifyListeners();
      });

      _isInitialized = true;
    } catch (e) {
      // Debug: Error initializing TeamProvider: $e
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Setup real-time listener for teams
  void _setupTeamsListener() {
    _teamsSubscription?.cancel();
    _teamsSubscription = _teamService.getUserTeams().listen(
      (teams) {
        _teams = teams;
        notifyListeners();
      },
      onError: (error) {
        // Debug: Error listening to teams: $error
      },
    );
  }

  // Setup real-time listener for invitations
  void _setupInvitationsListener() {
    _invitationsSubscription?.cancel();
    _invitationsSubscription = _teamService.getUserReceivedInvitations().listen(
      (invitations) {
        _invitations = invitations;
        notifyListeners();
      },
      onError: (error) {
        // Debug: Error listening to invitations: $error
      },
    );
  }

  // Getters
  AppUser get currentUser => _currentUser;
  List<Team> get teams => _teams;
  List<TeamInvitation> get invitations => _invitations;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;

  // Create a new team
  Future<String?> createTeam({
    required String name,
    required String description,
    required AppUser owner,
  }) async {
    try {
      final teamId = await _teamService.createTeam(
        name: name,
        description: description,
        owner: owner,
      );
      // The team will be automatically added to _teams via the stream listener
      return teamId;
    } catch (e) {
      // Debug: Error creating team: $e
      return null;
    }
  }

  // Update team information
  Future<bool> updateTeam(Team updatedTeam) async {
    try {
      await _teamService.updateTeam(updatedTeam);
      // The team will be automatically updated in _teams via the stream listener
      return true;
    } catch (e) {
      // Debug: Error updating team: $e
      return false;
    }
  }

  // Delete a team
  Future<bool> deleteTeam(String teamId) async {
    try {
      await _teamService.deleteTeam(teamId);
      // The team will be automatically removed from _teams via the stream listener
      return true;
    } catch (e) {
      // Debug: Error deleting team: $e
      return false;
    }
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
  Future<bool> inviteToTeam({
    required String teamId,
    required String inviteeEmail,
    required TeamRole role,
    required AppUser inviter,
  }) async {
    try {
      await _teamService.inviteToTeam(
        teamId: teamId,
        inviteeEmail: inviteeEmail,
        role: role,
        inviter: inviter,
      );
      return true;
    } catch (e) {
      // Debug: Error sending invitation: $e
      return false;
    }
  }

  // Accept team invitation
  Future<bool> acceptInvitation(String invitationId, AppUser user) async {
    try {
      await _teamService.acceptInvitation(invitationId, user);
      return true;
    } catch (e) {
      // Debug: Error accepting invitation: $e
      return false;
    }
  }

  // Decline team invitation
  Future<bool> declineInvitation(String invitationId) async {
    try {
      await _teamService.declineInvitation(invitationId);
      return true;
    } catch (e) {
      // Debug: Error declining invitation: $e
      return false;
    }
  }

  // Remove member from team
  Future<bool> removeMemberFromTeam(String teamId, String memberId) async {
    try {
      await _teamService.removeMemberFromTeam(teamId, memberId);
      return true;
    } catch (e) {
      // Debug: Error removing member from team: $e
      return false;
    }
  }

  // Update member role
  Future<bool> updateMemberRole(
    String teamId,
    String memberId,
    TeamRole newRole,
  ) async {
    try {
      await _teamService.updateMemberRole(teamId, memberId, newRole);
      return true;
    } catch (e) {
      // Debug: Error updating member role: $e
      return false;
    }
  }

  // Alias method for changing member role (used by team detail screen)
  Future<bool> changeMemberRole(
    String teamId,
    String memberId,
    TeamRole newRole,
  ) async {
    return updateMemberRole(teamId, memberId, newRole);
  }

  // Alias method for removing member (used by team detail screen)
  Future<bool> removeMember(String teamId, String memberId) async {
    return removeMemberFromTeam(teamId, memberId);
  }

  // Update team with individual parameters (used by team detail screen)
  Future<bool> updateTeamById(
    String teamId,
    String name,
    String description,
  ) async {
    try {
      await _teamService.updateTeamById(teamId, name, description);
      return true;
    } catch (e) {
      // Debug: Error updating team by ID: $e
      return false;
    }
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
  Future<bool> cancelInvitation(String invitationId) async {
    try {
      await _teamService.cancelInvitation(invitationId);
      return true;
    } catch (e) {
      // Debug: Error canceling invitation: $e
      return false;
    }
  }

  // Clean up expired invitations
  Future<bool> cleanUpExpiredInvitations() async {
    try {
      await _teamService.cleanUpExpiredInvitations();
      return true;
    } catch (e) {
      // Debug: Error cleaning up expired invitations: $e
      return false;
    }
  }

  // Update user information
  void updateUser(AppUser updatedUser) {
    _currentUser = updatedUser;
    notifyListeners();
  }

  @override
  void dispose() {
    _teamsSubscription?.cancel();
    _invitationsSubscription?.cancel();
    _userSubscription?.cancel();
    super.dispose();
  }
}
