import 'package:flutter/material.dart';
import '../models/habit_model.dart';
import '../models/scheduled_habit_model.dart'; // 1. IMPORT MODEL BARU

// === DAILY PAGES ===
import '../pages/daily/daily_home_page.dart';
import '../pages/daily/create_habit_page.dart';
import '../pages/daily/edit_habit_page.dart';
import '../pages/daily/daily_repeat_page.dart';

// === OTHER PAGES ===
import '../pages/scheduled/scheduled_page.dart';
import '../pages/scheduled/edit_scheduled_page.dart'; // 2. IMPORT HALAMAN EDIT BARU
import '../pages/challenge/challenge_page.dart';
import '../pages/tutorial/tutorial_page.dart';
import '../pages/settings/settings_page.dart';

class AppRoutes {
  // --- DAFTAR NAMA ROUTE ---
  static const String dailyHome = '/daily-home';
  static const String createHabit = '/create-habit';
  static const String editHabit = '/edit-habit';
  static const String dailyRepeat = '/daily-repeat';

  // Route Baru
  static const String scheduled = '/scheduled';
  static const String editScheduled = '/edit-scheduled'; // 3. NAMA ROUTE BARU
  static const String challenge = '/challenge';
  static const String tutorial = '/tutorial';
  static const String settings = '/settings';

  // --- MAP ROUTE UTAMA ---
  static Map<String, WidgetBuilder> routes = {
    // Daily
    dailyHome: (_) => const DailyHomePage(),
    createHabit: (_) => const CreateHabitPage(),
    dailyRepeat: (_) => const DailyRepeatPage(),

    // Halaman Baru
    scheduled: (_) => const ScheduledPage(),
    challenge: (_) => const ChallengePage(),
    tutorial: (_) => const TutorialPage(),
    settings: (_) => const SettingsPage(),
  };

  // --- GENERATOR UNTUK ROUTE DENGAN ARGUMENT (EDIT) ---
  static Route<dynamic>? onGenerateRoute(RouteSettings routeSettings) {
    // A. LOGIKA EDIT DAILY HABIT
    if (routeSettings.name == editHabit) {
      final args = routeSettings.arguments;

      if (args is HabitModel) {
        return MaterialPageRoute(
          builder: (_) => EditHabitPage(
            habit: args,
          ),
          settings: routeSettings,
        );
      }
    }

    // B. LOGIKA EDIT SCHEDULED HABIT (BARU)
    if (routeSettings.name == editScheduled) {
      final args = routeSettings.arguments;

      // Pastikan argumen yang dikirim adalah ScheduledHabitModel
      if (args is ScheduledHabitModel) {
        return MaterialPageRoute(
          builder: (_) => EditScheduledPage(
            habit: args, // Kirim data ke halaman edit
          ),
          settings: routeSettings,
        );
      }
    }

    // Error Handling jika argument salah/kosong
    if (routeSettings.name == editHabit ||
        routeSettings.name == editScheduled) {
      return MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(title: const Text('Error')),
          body: Center(
            child: Text(
              'Argument Error: ${routeSettings.name} requires valid arguments.',
            ),
          ),
        ),
      );
    }

    return null;
  }
}
