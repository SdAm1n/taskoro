import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/team.dart';
import '../models/user.dart';

class FirebaseTeamService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID
  String? get _currentUserId => _auth.currentUser?.uid;

  // Collection references
  CollectionReference get _teamsCollection => _firestore.collection('teams');
  CollectionReference get _invitationsCollection =>
      _firestore.collection('team_invitations');

  // Create a new team
  Future<String> createTeam({
    required String name,
    required String description,
    required AppUser owner,
  }) async {
    if (_currentUserId == null) throw Exception('User not authenticated');

    try {
      final teamId = _teamsCollection.doc().id;

      final team = Team(
        id: teamId,
        name: name,
        description: description,
        ownerId: owner.id,
        members:
            [], // Start with empty members list, owner will be added separately if needed
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _teamsCollection.doc(teamId).set(team.toMap());
      return teamId;
    } catch (e) {
      throw Exception('Failed to create team: $e');
    }
  }

  // Get all teams where user is owner or member
  Stream<List<Team>> getUserTeams() {
    if (_currentUserId == null) return Stream.value([]);

    return _teamsCollection
        .where('ownerId', isEqualTo: _currentUserId)
        .snapshots()
        .asyncMap((ownerSnapshot) async {
          // Get teams where user is owner
          final ownerTeams =
              ownerSnapshot.docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                data['id'] = doc.id;
                return Team.fromMap(data);
              }).toList();

          // Get teams where user is a member
          final memberSnapshot =
              await _teamsCollection
                  .where('members', arrayContainsAny: [_currentUserId])
                  .get();

          final memberTeams =
              memberSnapshot.docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                data['id'] = doc.id;
                return Team.fromMap(data);
              }).toList();

          // Combine and remove duplicates
          final allTeams = [...ownerTeams, ...memberTeams];
          final uniqueTeams = <String, Team>{};
          for (final team in allTeams) {
            uniqueTeams[team.id] = team;
          }

          return uniqueTeams.values.toList();
        });
  }

  // Get teams where user is owner
  Stream<List<Team>> getOwnedTeams() {
    if (_currentUserId == null) return Stream.value([]);

    return _teamsCollection
        .where('ownerId', isEqualTo: _currentUserId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            data['id'] = doc.id;
            return Team.fromMap(data);
          }).toList();
        });
  }

  // Get teams where user is a member
  Stream<List<Team>> getMemberTeams() {
    if (_currentUserId == null) return Stream.value([]);

    return _teamsCollection
        .where('members', arrayContainsAny: [_currentUserId])
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            data['id'] = doc.id;
            return Team.fromMap(data);
          }).toList();
        });
  }

  // Get team by ID
  Future<Team?> getTeamById(String teamId) async {
    try {
      final doc = await _teamsCollection.doc(teamId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return Team.fromMap(data);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get team: $e');
    }
  }

  // Update team information
  Future<void> updateTeam(Team team) async {
    if (_currentUserId == null) throw Exception('User not authenticated');

    try {
      final teamData = team.copyWith(updatedAt: DateTime.now()).toMap();
      await _teamsCollection.doc(team.id).update(teamData);
    } catch (e) {
      throw Exception('Failed to update team: $e');
    }
  }

  // Update team with individual parameters
  Future<void> updateTeamById(
    String teamId,
    String name,
    String description,
  ) async {
    if (_currentUserId == null) throw Exception('User not authenticated');

    try {
      await _teamsCollection.doc(teamId).update({
        'name': name,
        'description': description,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      throw Exception('Failed to update team: $e');
    }
  }

  // Delete a team
  Future<void> deleteTeam(String teamId) async {
    if (_currentUserId == null) throw Exception('User not authenticated');

    try {
      // Delete the team
      await _teamsCollection.doc(teamId).delete();

      // Delete related invitations
      final invitationsSnapshot =
          await _invitationsCollection.where('teamId', isEqualTo: teamId).get();

      final batch = _firestore.batch();
      for (final doc in invitationsSnapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to delete team: $e');
    }
  }

  // Add member to team
  Future<void> addMemberToTeam(String teamId, TeamMember member) async {
    if (_currentUserId == null) throw Exception('User not authenticated');

    try {
      await _teamsCollection.doc(teamId).update({
        'members': FieldValue.arrayUnion([member.toMap()]),
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      throw Exception('Failed to add member to team: $e');
    }
  }

  // Remove member from team
  Future<void> removeMemberFromTeam(String teamId, String memberId) async {
    if (_currentUserId == null) throw Exception('User not authenticated');

    try {
      final team = await getTeamById(teamId);
      if (team != null) {
        final updatedMembers =
            team.members
                .where((member) => member.userId != memberId)
                .map((member) => member.toMap())
                .toList();

        await _teamsCollection.doc(teamId).update({
          'members': updatedMembers,
          'updatedAt': DateTime.now().millisecondsSinceEpoch,
        });
      }
    } catch (e) {
      throw Exception('Failed to remove member from team: $e');
    }
  }

  // Update member role
  Future<void> updateMemberRole(
    String teamId,
    String memberId,
    TeamRole newRole,
  ) async {
    if (_currentUserId == null) throw Exception('User not authenticated');

    try {
      final team = await getTeamById(teamId);
      if (team != null) {
        final updatedMembers =
            team.members
                .map((member) {
                  if (member.userId == memberId) {
                    return member.copyWith(role: newRole);
                  }
                  return member;
                })
                .map((member) => member.toMap())
                .toList();

        await _teamsCollection.doc(teamId).update({
          'members': updatedMembers,
          'updatedAt': DateTime.now().millisecondsSinceEpoch,
        });
      }
    } catch (e) {
      throw Exception('Failed to update member role: $e');
    }
  }

  // Send team invitation
  Future<void> inviteToTeam({
    required String teamId,
    required String inviteeEmail,
    required TeamRole role,
    required AppUser inviter,
  }) async {
    if (_currentUserId == null) throw Exception('User not authenticated');

    try {
      final team = await getTeamById(teamId);
      if (team == null) throw Exception('Team not found');

      final invitationId = _invitationsCollection.doc().id;
      final invitation = TeamInvitation(
        id: invitationId,
        teamId: teamId,
        teamName: team.name,
        inviterUserId: inviter.id,
        inviterName: inviter.displayName,
        inviteeEmail: inviteeEmail,
        role: role,
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(days: 7)),
      );

      await _invitationsCollection.doc(invitationId).set(invitation.toMap());
    } catch (e) {
      throw Exception('Failed to send invitation: $e');
    }
  }

  // Get team invitations
  Stream<List<TeamInvitation>> getTeamInvitations(String teamId) {
    return _invitationsCollection
        .where('teamId', isEqualTo: teamId)
        .where('isAccepted', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            data['id'] = doc.id;
            return TeamInvitation.fromMap(data);
          }).toList();
        });
  }

  // Get all pending invitations sent by user
  Stream<List<TeamInvitation>> getUserSentInvitations() {
    if (_currentUserId == null) return Stream.value([]);

    return _invitationsCollection
        .where('inviterUserId', isEqualTo: _currentUserId)
        .where('isAccepted', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            data['id'] = doc.id;
            return TeamInvitation.fromMap(data);
          }).toList();
        });
  }

  // Get invitations for current user's email
  Stream<List<TeamInvitation>> getUserReceivedInvitations() {
    final userEmail = _auth.currentUser?.email;
    if (userEmail == null) return Stream.value([]);

    return _invitationsCollection
        .where('inviteeEmail', isEqualTo: userEmail)
        .where('isAccepted', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            data['id'] = doc.id;
            return TeamInvitation.fromMap(data);
          }).toList();
        });
  }

  // Accept team invitation
  Future<void> acceptInvitation(String invitationId, AppUser user) async {
    if (_currentUserId == null) throw Exception('User not authenticated');

    try {
      final invitationDoc =
          await _invitationsCollection.doc(invitationId).get();
      if (!invitationDoc.exists) throw Exception('Invitation not found');

      final data = invitationDoc.data() as Map<String, dynamic>;
      data['id'] = invitationDoc.id;
      final invitation = TeamInvitation.fromMap(data);

      if (!invitation.isValid) throw Exception('Invitation is no longer valid');

      // Add user to team
      final newMember = TeamMember(
        userId: user.id,
        email: user.email,
        displayName: user.displayName,
        role: invitation.role,
        joinedAt: DateTime.now(),
      );

      await addMemberToTeam(invitation.teamId, newMember);

      // Mark invitation as accepted
      await _invitationsCollection.doc(invitationId).update({
        'isAccepted': true,
        'acceptedAt': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      throw Exception('Failed to accept invitation: $e');
    }
  }

  // Decline team invitation
  Future<void> declineInvitation(String invitationId) async {
    try {
      await _invitationsCollection.doc(invitationId).delete();
    } catch (e) {
      throw Exception('Failed to decline invitation: $e');
    }
  }

  // Cancel invitation
  Future<void> cancelInvitation(String invitationId) async {
    if (_currentUserId == null) throw Exception('User not authenticated');

    try {
      await _invitationsCollection.doc(invitationId).delete();
    } catch (e) {
      throw Exception('Failed to cancel invitation: $e');
    }
  }

  // Clean up expired invitations
  Future<void> cleanUpExpiredInvitations() async {
    try {
      final now = DateTime.now();
      final expiredSnapshot =
          await _invitationsCollection
              .where('expiresAt', isLessThan: now.millisecondsSinceEpoch)
              .where('isAccepted', isEqualTo: false)
              .get();

      final batch = _firestore.batch();
      for (final doc in expiredSnapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to clean up expired invitations: $e');
    }
  }

  // Get all invitations (for admin purposes)
  Stream<List<TeamInvitation>> getAllInvitations() {
    if (_currentUserId == null) return Stream.value([]);

    return _invitationsCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            data['id'] = doc.id;
            return TeamInvitation.fromMap(data);
          }).toList();
        });
  }
}
