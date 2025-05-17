import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventease/services/firestore_service.dart';
import 'package:eventease/providers/auth_provider.dart';

final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});

// Events Stream Provider
final eventsStreamProvider = StreamProvider((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value([]);
  
  return FirebaseFirestore.instance
      .collection('events')
      .where('organizerId', isEqualTo: user.uid)
      .orderBy('date')
      .snapshots()
      .map((snapshot) => snapshot.docs);
});

// Single Event Stream Provider
final eventStreamProvider = StreamProvider.family((ref, String eventId) {
  return FirebaseFirestore.instance
      .collection('events')
      .doc(eventId)
      .snapshots();
});

// Tasks Stream Provider
final tasksStreamProvider = StreamProvider.family((ref, String eventId) {
  return FirebaseFirestore.instance
      .collection('events')
      .doc(eventId)
      .collection('tasks')
      .orderBy('createdAt')
      .snapshots()
      .map((snapshot) => snapshot.docs);
});

// Comments Stream Provider
final commentsStreamProvider = StreamProvider.family((ref, String eventId) {
  return FirebaseFirestore.instance
      .collection('events')
      .doc(eventId)
      .collection('comments')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs);
});

// Event Statistics Provider
final eventStatisticsProvider = FutureProvider((ref) async {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return null;
  
  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.getEventStatistics(user.uid);
});

// Task Statistics Provider
final taskStatisticsProvider = FutureProvider.family((ref, String eventId) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.getTaskStatistics(eventId);
});

class EventNotifier extends StateNotifier<AsyncValue<void>> {
  final FirestoreService _firestoreService;
  final Ref _ref;

  EventNotifier(this._firestoreService, this._ref)
      : super(const AsyncValue.data(null));

  Future<String> createEvent({
    required String title,
    required DateTime date,
    required String location,
    required String description,
    String? imageUrl,
  }) async {
    try {
      state = const AsyncValue.loading();
      final user = _ref.read(authStateProvider).value;
      if (user == null) throw Exception('User not authenticated');

      final eventId = await _firestoreService.createEvent(
        title: title,
        date: date,
        location: location,
        description: description,
        organizerId: user.uid,
        imageUrl: imageUrl,
      );

      state = const AsyncValue.data(null);
      return eventId;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
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
      state = const AsyncValue.loading();

      await _firestoreService.updateEvent(
        eventId: eventId,
        title: title,
        date: date,
        location: location,
        description: description,
        imageUrl: imageUrl,
        progress: progress,
      );

      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> deleteEvent(String eventId) async {
    try {
      state = const AsyncValue.loading();
      await _firestoreService.deleteEvent(eventId);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<String> createTask({
    required String eventId,
    required String title,
    required String assigneeId,
    String? description,
  }) async {
    try {
      state = const AsyncValue.loading();
      
      final taskId = await _firestoreService.createTask(
        eventId: eventId,
        title: title,
        assigneeId: assigneeId,
        description: description,
      );

      state = const AsyncValue.data(null);
      return taskId;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> updateTaskStatus({
    required String eventId,
    required String taskId,
    required String status,
  }) async {
    try {
      state = const AsyncValue.loading();
      
      await _firestoreService.updateTaskStatus(
        eventId: eventId,
        taskId: taskId,
        status: status,
      );

      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<String> addComment({
    required String eventId,
    required String content,
  }) async {
    try {
      state = const AsyncValue.loading();
      
      final user = _ref.read(authStateProvider).value;
      if (user == null) throw Exception('User not authenticated');

      final commentId = await _firestoreService.addComment(
        eventId: eventId,
        userId: user.uid,
        content: content,
      );

      state = const AsyncValue.data(null);
      return commentId;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

final eventNotifierProvider =
    StateNotifierProvider<EventNotifier, AsyncValue<void>>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return EventNotifier(firestoreService, ref);
});

// Event Loading State Provider
final eventLoadingProvider = StateProvider<bool>((ref) => false);

// Event Error Provider
final eventErrorProvider = StateProvider<String?>((ref) => null);

// Event Filter Provider
final eventFilterProvider = StateProvider<String>((ref) => 'all');

// Event Search Query Provider
final eventSearchQueryProvider = StateProvider<String>((ref) => '');

// Filtered Events Provider
final filteredEventsProvider = Provider<List<QueryDocumentSnapshot>>((ref) {
  final events = ref.watch(eventsStreamProvider).value ?? [];
  final filter = ref.watch(eventFilterProvider);
  final searchQuery = ref.watch(eventSearchQueryProvider).toLowerCase();

  return events.where((event) {
    final data = event.data() as Map<String, dynamic>;
    final title = data['title'].toString().toLowerCase();
    final matchesSearch = title.contains(searchQuery);

    switch (filter) {
      case 'upcoming':
        return matchesSearch &&
            (data['date'] as Timestamp).toDate().isAfter(DateTime.now());
      case 'completed':
        return matchesSearch && (data['progress'] as double) >= 1.0;
      case 'ongoing':
        final date = (data['date'] as Timestamp).toDate();
        final progress = data['progress'] as double;
        return matchesSearch &&
            date.isBefore(DateTime.now()) &&
            progress < 1.0;
      default:
        return matchesSearch;
    }
  }).toList();
});
