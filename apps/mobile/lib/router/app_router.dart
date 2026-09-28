import 'package:baseline/screens/account_screens.dart';
import 'package:baseline/screens/age_gate_screen.dart';
import 'package:baseline/screens/court_detail_screen.dart';
import 'package:baseline/screens/discover_screen.dart';
import 'package:baseline/screens/drill_detail_screen.dart';
import 'package:baseline/screens/email_code_screen.dart';
import 'package:baseline/screens/home_screen.dart';
import 'package:baseline/screens/learn_screen.dart';
import 'package:baseline/screens/lesson_reader_screen.dart';
import 'package:baseline/screens/onboarding_screen.dart';
import 'package:baseline/screens/paywall_screen.dart';
import 'package:baseline/screens/plan_preview_screen.dart';
import 'package:baseline/screens/profile_screen.dart';
import 'package:baseline/screens/search_screen.dart';
import 'package:baseline/screens/shell_screen.dart';
import 'package:baseline/screens/sign_in_screen.dart';
import 'package:baseline/screens/train_screen.dart';
import 'package:baseline/screens/video_credits_screen.dart';
import 'package:baseline/screens/video_screen.dart';
import 'package:baseline/screens/welcome_screen.dart';
import 'package:baseline/state/player_session.dart';
import 'package:baseline/state/session_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final session = ref.read(sessionProvider.notifier);
  final rootKey = GlobalKey<NavigatorState>(debugLabel: 'root');

  return GoRouter(
    navigatorKey: rootKey,
    initialLocation: '/welcome',
    refreshListenable: session.refresh,
    redirect: (context, state) {
      return sessionRedirect(ref.read(sessionProvider), state.matchedLocation);
    },
    routes: [
      GoRoute(path: '/', redirect: (context, state) => '/welcome'),
      GoRoute(
        path: '/welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/sign-in',
        builder: (context, state) => const SignInScreen(),
      ),
      GoRoute(path: '/email', builder: (context, state) => const EmailScreen()),
      GoRoute(
        path: '/code',
        builder: (context, state) => const EmailCodeScreen(),
      ),
      GoRoute(path: '/age', builder: (context, state) => const AgeGateScreen()),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/plan',
        builder: (context, state) => const PlanPreviewScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/learn',
                builder: (context, state) => const LearnScreen(),
                routes: [
                  GoRoute(
                    path: 'level/:levelId',
                    builder: (context, state) => LessonListScreen(
                      levelId: int.parse(state.pathParameters['levelId']!),
                    ),
                  ),
                  GoRoute(
                    path: 'lesson/:slug',
                    builder: (context, state) =>
                        LessonReaderScreen(slug: state.pathParameters['slug']!),
                  ),
                  GoRoute(
                    path: 'glossary',
                    builder: (context, state) => const GlossaryScreen(),
                  ),
                  GoRoute(
                    path: 'techniques',
                    builder: (context, state) => const TechniqueListScreen(),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/train',
                builder: (context, state) => const TrainScreen(),
                routes: [
                  GoRoute(
                    path: 'drill/:slug',
                    builder: (context, state) =>
                        DrillDetailScreen(slug: state.pathParameters['slug']!),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/discover',
                builder: (context, state) => const DiscoverScreen(),
                routes: [
                  GoRoute(
                    path: 'court/:id',
                    builder: (context, state) =>
                        CourtDetailScreen(id: state.pathParameters['id']!),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfileScreen(),
                routes: [
                  GoRoute(
                    path: 'privacy',
                    builder: (context, state) => const PrivacyScreen(),
                  ),
                  GoRoute(
                    path: 'notifications',
                    builder: (context, state) => const NotificationsScreen(),
                  ),
                  GoRoute(
                    path: 'equipment',
                    builder: (context, state) => const EquipmentScreen(),
                  ),
                  GoRoute(
                    path: 'matches',
                    builder: (context, state) => const MatchLogScreen(),
                  ),
                  GoRoute(
                    path: 'inbox',
                    builder: (context, state) => const InboxScreen(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/credits',
        parentNavigatorKey: rootKey,
        builder: (context, state) => const VideoCreditsScreen(),
      ),
      GoRoute(
        path: '/videos',
        parentNavigatorKey: rootKey,
        builder: (context, state) => const VideoLibraryScreen(),
      ),
      GoRoute(
        path: '/video/:id',
        parentNavigatorKey: rootKey,
        builder: (context, state) =>
            VideoPlayerScreen(id: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/search',
        parentNavigatorKey: rootKey,
        builder: (context, state) => const SearchScreen(),
      ),
      GoRoute(
        path: '/paywall',
        parentNavigatorKey: rootKey,
        builder: (context, state) => const PaywallScreen(),
      ),
    ],
  );
});
