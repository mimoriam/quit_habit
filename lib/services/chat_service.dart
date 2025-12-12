import 'package:cloud_firestore/cloud_firestore.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get chat sessions for a user
  Stream<QuerySnapshot> getUserChatSessions(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('chat_sessions')
        .orderBy('updatedAt', descending: true)
        .snapshots();
  }

  // Get messages for a session
  Stream<QuerySnapshot> getSessionMessages(String userId, String sessionId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('chat_sessions')
        .doc(sessionId)
        .collection('messages')
        .orderBy('createdAt', descending: false)
        .snapshots();
  }

  // Create a new session
  Future<String> createChatSession(String userId, String firstMessage) async {
    final docRef = await _firestore
        .collection('users')
        .doc(userId)
        .collection('chat_sessions')
        .add({
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'title': firstMessage.length > 30 
          ? '${firstMessage.substring(0, 30)}...' 
          : firstMessage,
    });
    return docRef.id;
  }

  // Add message to session
  Future<void> addMessage(String userId, String sessionId, String text, bool isUser) async {
    final sessionRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('chat_sessions')
        .doc(sessionId);

    // Add message
    await sessionRef.collection('messages').add({
      'text': text,
      'isUser': isUser,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Update session timestamp and title if it's the first user message of a generic named session
    // For simplicity, we just update the timestamp here. 
    // Title update logic could be more complex but we'll stick to creation-time title or just updatedAt for now.
    // Actually, updating the title on the first user message if it was "New Chat" would be good, 
    // but the createChatSession already handles the title from the first message.
    // So just update the timestamp.
    await sessionRef.update({
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Delete session
  Future<void> deleteSession(String userId, String sessionId) async {
    final sessionRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('chat_sessions')
        .doc(sessionId);
    
    // Delete all messages first
    final messages = await sessionRef.collection('messages').get();
    final batch = _firestore.batch();
    
    for (final doc in messages.docs) {
      batch.delete(doc.reference);
    }
    
    // Delete the session document
    batch.delete(sessionRef);
    
    await batch.commit();
  }}
