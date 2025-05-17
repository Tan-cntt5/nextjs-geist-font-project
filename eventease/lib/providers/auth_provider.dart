import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:eventease/services/auth_service.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final authStateProvider = StreamProvider<User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
});

final userRoleProvider = FutureProvider<String>((ref) async {
  final authService = ref.watch(authServiceProvider);
  if (authService.currentUser == null) return 'guest';
  return authService.getUserRole();
});

final isLoadingProvider = StateProvider<bool>((ref) => false);

final authExceptionProvider = StateProvider<String?>((ref) => null);

class AuthNotifier extends StateNotifier<AsyncValue<User?>> {
  final AuthService _authService;
  final Ref _ref;

  AuthNotifier(this._authService, this._ref)
      : super(const AsyncValue.loading()) {
    _init();
  }

  void _init() {
    _authService.authStateChanges.listen((user) {
      state = AsyncValue.data(user);
    });
  }

  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      _ref.read(isLoadingProvider.notifier).state = true;
      _ref.read(authExceptionProvider.notifier).state = null;
      
      await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      _ref.read(authExceptionProvider.notifier).state = e.toString();
      rethrow;
    } finally {
      _ref.read(isLoadingProvider.notifier).state = false;
    }
  }

  Future<void> registerWithEmailAndPassword({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      _ref.read(isLoadingProvider.notifier).state = true;
      _ref.read(authExceptionProvider.notifier).state = null;
      
      await _authService.registerWithEmailAndPassword(
        name: name,
        email: email,
        password: password,
      );
    } catch (e) {
      _ref.read(authExceptionProvider.notifier).state = e.toString();
      rethrow;
    } finally {
      _ref.read(isLoadingProvider.notifier).state = false;
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      _ref.read(isLoadingProvider.notifier).state = true;
      _ref.read(authExceptionProvider.notifier).state = null;
      
      await _authService.signInWithGoogle();
    } catch (e) {
      _ref.read(authExceptionProvider.notifier).state = e.toString();
      rethrow;
    } finally {
      _ref.read(isLoadingProvider.notifier).state = false;
    }
  }

  Future<void> signOut() async {
    try {
      _ref.read(isLoadingProvider.notifier).state = true;
      await _authService.signOut();
    } finally {
      _ref.read(isLoadingProvider.notifier).state = false;
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      _ref.read(isLoadingProvider.notifier).state = true;
      _ref.read(authExceptionProvider.notifier).state = null;
      
      await _authService.resetPassword(email);
    } catch (e) {
      _ref.read(authExceptionProvider.notifier).state = e.toString();
      rethrow;
    } finally {
      _ref.read(isLoadingProvider.notifier).state = false;
    }
  }
}

final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AsyncValue<User?>>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthNotifier(authService, ref);
});

// User Profile Provider
final userProfileProvider = FutureProvider.family<Map<String, dynamic>, String>(
  (ref, userId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get();
    return snapshot.data() ?? {};
  },
);

// Current User Profile Provider
final currentUserProfileProvider = FutureProvider<Map<String, dynamic>?>(
  (ref) async {
    final user = ref.watch(authStateProvider).value;
    if (user == null) return null;
    
    return ref.watch(userProfileProvider(user.uid).future);
  },
);
