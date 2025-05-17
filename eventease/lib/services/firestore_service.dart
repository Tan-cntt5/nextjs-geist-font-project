import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Events
  Future<String> createEvent({
    required String title,
    required DateTime date,
    required String location,
    required String description,
    required String organizerId,
    String? imageUrl,
  }) async {
    try {
      final docRef = await _firestore.collection('events').add({
        'title': title,
        'date': Timestamp.fromDate(date),
        'location': location,
        'description': description,
        'organizerId': organizerId,
        'imageUrl': imageUrl,
        'progress': 0.0,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create event: $e');
    }
  }

  Future<void> updateEvent({
    required String eventId,
    String? title,
    DateTime? date,
    String? location,
    String? description,
    String? imageUrl,
    double? progress,
  }) async {
    try {
      final updates = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (title != null) updates['title'] = title;
      if (date != null) updates['date'] = Timestamp.fromDate(date);
      if (location != null) updates['location'] = location;
      if (description != null) updates['description'] = description;
      if (imageUrl != null) updates['imageUrl'] = imageUrl;
      if (progress != null) updates['progress'] = progress;

      await _firestore.collection('events').doc(eventId).update(updates);
    } catch (e) {
      throw Exception('Failed to update event: $e');
    }
  }

  Stream<QuerySnapshot> getEvents(String userId) {
    return _firestore
        .collection('events')
        .where('organizerId', isEqualTo: userId)
        .orderBy('date')
        .snapshots();
  }

  Stream<DocumentSnapshot> getEventById(String eventId) {
    return _firestore.collection('events').doc(eventId).snapshots();
  }

  Future<void> deleteEvent(String eventId) async {
    try {
      // Delete all tasks
      final tasksDocs = await _firestore
          .collection('events')
          .doc(eventId)
          .collection('tasks')
          .get();
      
      for (var doc in tasksDocs.docs) {
        await doc.reference.delete();
      }

      // Delete all comments
      final commentsDocs = await _firestore
          .collection('events')
          .doc(eventId)
          .collection('comments')
          .get();
      
      for (var doc in commentsDocs.docs) {
        await doc.reference.delete();
      }

      // Delete the event
      await _firestore.collection('events').doc(eventId).delete();
    } catch (e) {
      throw Exception('Failed to delete event: $e');
    }
  }

  // Tasks
  Future<String> createTask({
    required String eventId,
    required String title,
    required String assigneeId,
    String? description,
  }) async {
    try {
      final docRef = await _firestore
          .collection('events')
          .doc(eventId)
          .collection('tasks')
          .add({
        'title': title,
        'assigneeId': assigneeId,
        'description': description,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create task: $e');
    }
  }

  Stream<QuerySnapshot> getTasks(String eventId) {
    return _firestore
        .collection('events')
        .doc(eventId)
        .collection('tasks')
        .orderBy('createdAt')
        .snapshots();
  }

  Future<void> updateTaskStatus({
    required String eventId,
    required String taskId,
    required String status,
  }) async {
    try {
      await _firestore
          .collection('events')
          .doc(eventId)
          .collection('tasks')
          .doc(taskId)
          .update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Update event progress
      await _updateEventProgress(eventId);
    } catch (e) {
      throw Exception('Failed to update task status: $e');
    }
  }

  Future<void> _updateEventProgress(String eventId) async {
    try {
      final tasksSnapshot = await _firestore
          .collection('events')
          .doc(eventId)
          .collection('tasks')
          .get();

      if (tasksSnapshot.docs.isEmpty) return;

      final completedTasks = tasksSnapshot.docs
          .where((doc) => doc.data()['status'] == 'completed')
          .length;
      final progress = completedTasks / tasksSnapshot.docs.length;

      await _firestore.collection('events').doc(eventId).update({
        'progress': progress,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update event progress: $e');
    }
  }

  // Comments
  Future<String> addComment({
    required String eventId,
    required String userId,
    required String content,
  }) async {
    try {
      final docRef = await _firestore
          .collection('events')
          .doc(eventId)
          .collection('comments')
          .add({
        'userId': userId,
        'content': content,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return docRef.id;
    } catch (e) {
      throw Exception('Failed to add comment: $e');
    }
  }

  Stream<QuerySnapshot> getComments(String eventId) {
    return _firestore
        .collection('events')
        .doc(eventId)
        .collection('comments')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Storage
  Future<String> uploadEventImage(String eventId, File imageFile) async {
    try {
      final ref = _storage.ref().child('events/$eventId/cover.jpg');
      await ref.putFile(imageFile);
      return await ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  // Statistics
  Future<Map<String, dynamic>> getEventStatistics(String userId) async {
    try {
      final eventsSnapshot = await _firestore
          .collection('events')
          .where('organizerId', isEqualTo: userId)
          .get();

      int totalEvents = eventsSnapshot.docs.length;
      int upcomingEvents = 0;
      int completedEvents = 0;

      for (var doc in eventsSnapshot.docs) {
        final data = doc.data();
        final date = (data['date'] as Timestamp).toDate();
        final progress = data['progress'] as double;

        if (date.isAfter(DateTime.now())) {
          upcomingEvents++;
        }
        if (progress >= 1.0) {
          completedEvents++;
        }
      }

      return {
        'totalEvents': totalEvents,
        'upcomingEvents': upcomingEvents,
        'completedEvents': completedEvents,
      };
    } catch (e) {
      throw Exception('Failed to get event statistics: $e');
    }
  }

  Future<Map<String, dynamic>> getTaskStatistics(String eventId) async {
    try {
      final tasksSnapshot = await _firestore
          .collection('events')
          .doc(eventId)
          .collection('tasks')
          .get();

      int totalTasks = tasksSnapshot.docs.length;
      int pendingTasks = 0;
      int inProgressTasks = 0;
      int completedTasks = 0;

      for (var doc in tasksSnapshot.docs) {
        final status = doc.data()['status'] as String;
        switch (status) {
          case 'pending':
            pendingTasks++;
            break;
          case 'inProgress':
            inProgressTasks++;
            break;
          case 'completed':
            completedTasks++;
            break;
        }
      }

      return {
        'totalTasks': totalTasks,
        'pendingTasks': pendingTasks,
        'inProgressTasks': inProgressTasks,
        'completedTasks': completedTasks,
      };
    } catch (e) {
      throw Exception('Failed to get task statistics: $e');
    }
  }
}
