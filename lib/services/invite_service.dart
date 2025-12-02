import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:quit_habit/services/goal_service.dart';
import 'package:share_plus/share_plus.dart';

class InviteService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Send Invite
  Future<Map<String, dynamic>> sendInvite(String senderId, String email) async {
    try {
      // 0. Validate sender exists
      final senderDoc = await _firestore.collection('users').doc(senderId).get();
      if (!senderDoc.exists) {
        return {'success': false, 'message': 'Invalid sender'};
      }

      // 1. Check if user exists with this email
      final userQuery = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (userQuery.docs.isEmpty) {
        // User not found, trigger share
        await SharePlus.instance.share(
          ShareParams(
            text:
                'Join me on Quit Habit! Download the app and let\'s quit together: https://quithabit.app',
          ),
        );
        
        // Count as invite for goal (even if external)
        await GoalService().checkSocialGoals(senderId, 1);
        
        return {'success': true, 'type': 'external', 'message': 'Invitation shared externally'};
      }

      final receiverDoc = userQuery.docs.first;
      final receiverId = receiverDoc.id;

      if (receiverId == senderId) {
        return {'success': false, 'message': 'You cannot invite yourself'};
      }

      // 2. Transaction: Check Connection & Create Invite
      await _firestore.runTransaction((transaction) async {
        // Check for existing connection using deterministic ID
        final userIds = [senderId, receiverId]..sort();
        final connectionId = userIds.join('_');
        final connectionRef = _firestore.collection('connections').doc(connectionId);
        
        final connectionSnapshot = await transaction.get(connectionRef);
        if (connectionSnapshot.exists) {
          throw Exception('You are already connected with this user');
        }

        // Check for existing invite using deterministic ID
        final inviteIds = [senderId, receiverId]..sort();
        final inviteId = inviteIds.join('_');
        final inviteRef = _firestore.collection('invites').doc(inviteId);
        
        final inviteSnapshot = await transaction.get(inviteRef);
        if (inviteSnapshot.exists) {
          final data = inviteSnapshot.data() as Map<String, dynamic>;
          // If invite exists and is pending or accepted, we can't send another
          if (data['status'] == 'pending') {
            throw Exception('Invite already pending');
          } else if (data['status'] == 'accepted') {
            throw Exception('An accepted invite already exists');
          }
          // If rejected, we might want to allow re-sending, but for now we follow "throw if exists"
          // or we can overwrite if rejected. The prompt said "throw if the document already exists".
          // However, strictly throwing prevents re-inviting after rejection.
          // Given the prompt "throw if the document already exists to preserve atomicity", 
          // I will throw.
          throw Exception('Invite already sent (Status: ${data['status']})');
        }

        transaction.set(inviteRef, {
          'senderId': senderId,
          'receiverId': receiverId,
          'receiverEmail': email,
          'status': 'pending',
          'createdAt': FieldValue.serverTimestamp(),
        });
      });

      // 3. Update Goal
      await GoalService().checkSocialGoals(senderId, 1);

      final receiverData = receiverDoc.data();
      final receiverName = receiverData['fullName'] as String? ?? 
                          receiverData['displayName'] as String? ?? 
                          email;

      return {'success': true, 'type': 'internal', 'message': 'Invite sent to $receiverName'};
    } catch (e) {
      // Clean up error message
      String message = e.toString();
      if (message.startsWith('Exception: ')) {
        message = message.substring(11);
      }
      return {'success': false, 'message': message};
    }
  }

  // Get Received Invites
  Stream<QuerySnapshot> getReceivedInvites(String userId) {
    return _firestore
        .collection('invites')
        .where('receiverId', isEqualTo: userId)
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Get Sent Invites
  Stream<QuerySnapshot> getSentInvites(String userId) {
    return _firestore
        .collection('invites')
        .where('senderId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Accept Invite
  Future<void> acceptInvite(String inviteId) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      throw Exception('User not authenticated');
    }

    await _firestore.runTransaction((transaction) async {
      final inviteRef = _firestore.collection('invites').doc(inviteId);
      final inviteSnapshot = await transaction.get(inviteRef);

      if (!inviteSnapshot.exists) {
        throw Exception('Invite not found');
      }

      final data = inviteSnapshot.data() as Map<String, dynamic>;
      if (data['receiverId'] != currentUser.uid) {
        throw Exception('Unauthorized: You are not the receiver of this invite');
      }

      if (data['status'] != 'pending') {
        throw Exception('Invite is already ${data['status']}');
      }

      // Compute deterministic connection ID
      final userIds = [data['senderId'] as String, data['receiverId'] as String];
      userIds.sort();
      final connectionId = userIds.join('_');
      final connectionRef = _firestore.collection('connections').doc(connectionId);

      // Check for duplicate connection
      final connectionSnapshot = await transaction.get(connectionRef);
      if (connectionSnapshot.exists) {
        throw Exception('Connection already exists');
      }

      // Update invite status
      transaction.update(inviteRef, {
        'status': 'accepted',
        'acceptedAt': FieldValue.serverTimestamp(),
      });

      // Create connection
      transaction.set(connectionRef, {
        'users': [data['senderId'], data['receiverId']],
        'createdAt': FieldValue.serverTimestamp(),
        'inviteId': inviteId,
      });
    });
  }

  // Reject Invite
  Future<void> rejectInvite(String inviteId) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      throw Exception('User not authenticated');
    }

    await _firestore.runTransaction((transaction) async {
      final inviteRef = _firestore.collection('invites').doc(inviteId);
      final inviteSnapshot = await transaction.get(inviteRef);

      if (!inviteSnapshot.exists) {
        throw Exception('Invite not found');
      }

      final data = inviteSnapshot.data() as Map<String, dynamic>;
      if (data['receiverId'] != currentUser.uid) {
        throw Exception('Unauthorized: You are not the receiver of this invite');
      }

      if (data['status'] != 'pending') {
        throw Exception('Invite is already ${data['status']}');
      }

      transaction.update(inviteRef, {
        'status': 'rejected',
        'rejectedAt': FieldValue.serverTimestamp(),
      });
    });
  }
  // Get Friends (Connections)
  Stream<QuerySnapshot> getFriends(String userId) {
    return _firestore
        .collection('connections')
        .where('users', arrayContains: userId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Get User Basic Info
  Future<Map<String, dynamic>?> getUserBasicInfo(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'fullName': data['fullName'] as String? ?? data['displayName'] as String? ?? '',
          'photoUrl': data['photoUrl'] as String? ?? '',
          'email': data['email'] as String? ?? '',
        };
      }
      return null;
    } catch (e, stackTrace) {
      debugPrint('Error fetching user info: $e\n$stackTrace');
      return null;
    }
  }
}
