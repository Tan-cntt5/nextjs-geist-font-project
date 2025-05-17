import 'package:flutter/material.dart';
import 'package:eventease/theme/app_theme.dart';

class Constants {
  // App Info
  static const String appName = 'EventEase';
  static const String appVersion = '1.0.0';
  
  // Firebase Collections
  static const String usersCollection = 'users';
  static const String eventsCollection = 'events';
  static const String tasksCollection = 'tasks';
  static const String commentsCollection = 'comments';

  // Task Statuses
  static const String taskStatusPending = 'pending';
  static const String taskStatusInProgress = 'inProgress';
  static const String taskStatusCompleted = 'completed';

  // User Roles
  static const String roleOrganizer = 'organizer';
  static const String roleParticipant = 'participant';
  static const String roleUser = 'user';

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 350);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // Task Status Colors & Labels
  static Map<String, Color> taskStatusColors = {
    taskStatusPending: AppTheme.warningColor,
    taskStatusInProgress: AppTheme.primaryColor,
    taskStatusCompleted: AppTheme.successColor,
  };

  static Map<String, String> taskStatusLabels = {
    taskStatusPending: 'Pending',
    taskStatusInProgress: 'In Progress',
    taskStatusCompleted: 'Completed',
  };

  // Event Filter Options
  static const List<Map<String, String>> eventFilters = [
    {'id': 'all', 'label': 'All Events'},
    {'id': 'upcoming', 'label': 'Upcoming'},
    {'id': 'ongoing', 'label': 'Ongoing'},
    {'id': 'completed', 'label': 'Completed'},
  ];

  // Validation Patterns
  static final RegExp emailPattern = RegExp(
    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
  );

  static final RegExp passwordPattern = RegExp(
    r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$',
  );

  // Error Messages
  static const String errorRequired = 'This field is required';
  static const String errorInvalidEmail = 'Please enter a valid email address';
  static const String errorInvalidPassword = 'Password must be at least 8 characters with letters and numbers';
  static const String errorPasswordMismatch = 'Passwords do not match';
  static const String errorGeneric = 'Something went wrong. Please try again.';
  static const String errorNoInternet = 'No internet connection';
  static const String errorUnauthorized = 'You are not authorized to perform this action';

  // Success Messages
  static const String successEventCreated = 'Event created successfully';
  static const String successEventUpdated = 'Event updated successfully';
  static const String successTaskCreated = 'Task created successfully';
  static const String successTaskUpdated = 'Task updated successfully';
  static const String successCommentAdded = 'Comment added successfully';
  static const String successProfileUpdated = 'Profile updated successfully';
  static const String successPasswordReset = 'Password reset email sent successfully';

  // Placeholder Images
  static const String defaultEventImage = 'https://picsum.photos/seed/event/800/400';
  static const String defaultAvatarImage = 'https://picsum.photos/seed/avatar/200/200';

  // Date Formats
  static const String dateFormatFull = 'EEEE, MMMM d, y';
  static const String dateFormatShort = 'MMM d, y';
  static const String dateFormatCompact = 'MM/dd/yy';
  static const String timeFormat = 'h:mm a';

  // UI Constants
  static const double borderRadius = 12.0;
  static const double spacing = 16.0;
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  
  static const double cardElevation = 4.0;
  static const double iconSize = 24.0;
  static const double avatarSize = 40.0;
  
  static const double maxWidth = 600.0;
  static const double minButtonHeight = 48.0;

  // Shimmer Effect Colors
  static final Color shimmerBaseColor = Colors.grey[300]!;
  static final Color shimmerHighlightColor = Colors.grey[100]!;

  // Chart Colors
  static const List<Color> chartColors = [
    Color(0xFF2563EB), // Primary
    Color(0xFF3B82F6), // Secondary
    Color(0xFF059669), // Success
    Color(0xFFF59E0B), // Warning
    Color(0xFFDC2626), // Error
  ];

  // Loading States
  static Widget get loadingIndicator => const Center(
    child: CircularProgressIndicator(),
  );

  static Widget get loadingMinimal => const SizedBox(
    height: 20,
    width: 20,
    child: CircularProgressIndicator(
      strokeWidth: 2,
    ),
  );

  // Empty States
  static Widget emptyState({
    required String message,
    IconData icon = Icons.inbox_rounded,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Error States
  static Widget errorState({
    required String message,
    VoidCallback? onRetry,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 64,
            color: AppTheme.errorColor,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ],
      ),
    );
  }
}
