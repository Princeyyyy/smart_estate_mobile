import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'constants/theme.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/main_screen.dart';
import 'screens/payment/payment_screen.dart';
import 'screens/payment/payment_history_screen.dart';
import 'screens/maintenance/report_issue_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/profile/edit_profile_screen.dart';
import 'screens/settings/notification_settings_screen.dart';
import 'screens/visitor/visitor_management_screen.dart';
import 'screens/community/community_post_detail_screen.dart';
import 'screens/emergency/emergency_alerts_screen.dart';
import 'screens/events/events_calendar_screen.dart';
import 'models/community_post.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const SmartEstateApp());
}

class SmartEstateApp extends StatelessWidget {
  const SmartEstateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'SmartEstate',
      theme: AppTheme.lightTheme,
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(path: '/main', builder: (context, state) => const MainScreen()),
    GoRoute(
      path: '/payment',
      builder: (context, state) => const PaymentScreen(),
    ),
    GoRoute(
      path: '/payment-history',
      builder: (context, state) => const PaymentHistoryScreen(),
    ),
    GoRoute(
      path: '/report-issue',
      builder: (context, state) => const ReportIssueScreen(),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: '/edit-profile',
      builder: (context, state) => const EditProfileScreen(),
    ),
    GoRoute(
      path: '/notification-settings',
      builder: (context, state) => const NotificationSettingsScreen(),
    ),
    GoRoute(
      path: '/visitor-management',
      builder: (context, state) => const VisitorManagementScreen(),
    ),
    GoRoute(
      path: '/community-post/:postId',
      builder: (context, state) {
        final postId = state.pathParameters['postId']!;
        // Create a sample post for demonstration - in real app this would come from API
        final post = CommunityPost(
          id: postId,
          userId: 'user1',
          userName: 'Clementina',
          content:
              'Hey everyone! I\'m moving to a new place. Does anyone have any moving tips?',
          images: const [
            'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400',
            'https://images.unsplash.com/photo-1560518883-ce09059eeffa?w=400',
            'https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=400',
          ],
          likesCount: 34,
          commentsCount: 23,
          sharesCount: 12,
          isLiked: false,
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
          updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
        );
        return CommunityPostDetailScreen(post: post);
      },
    ),
    GoRoute(
      path: '/emergency-alerts',
      builder: (context, state) => const EmergencyAlertsScreen(),
    ),
    GoRoute(
      path: '/events-calendar',
      builder: (context, state) => const EventsCalendarScreen(),
    ),
  ],
);
