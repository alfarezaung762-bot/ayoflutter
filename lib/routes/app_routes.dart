// lib/routes/app_routes.dart
import 'package:flutter/material.dart';

import '../models/habit_model.dart';

// DAILY PAGES
import '../pages/daily/daily_home_page.dart';
import '../pages/daily/create_habit_page.dart';
import '../pages/daily/edit_habit_page.dart';
import '../pages/daily/daily_repeat_page.dart';

// OTHER PAGES (jika belum ada file, komen saja import ini)
import '../pages/scheduled/scheduled_page.dart';
// import '../pages/challenge/challenge_page.dart';
// import '../pages/tutorial/tutorial_page.dart';

class AppRoutes {
  // ROUTE NAMES
  static const String dailyHome = '/daily-home';
  static const String createHabit = '/create-habit';
  static const String editHabit =
      '/edit-habit'; // expects HabitModel in arguments
  static const String dailyRepeat = '/daily-repeat';
  static const String scheduled = '/scheduled';
  // static const String challenge = '/challenge';
  // static const String tutorial = '/tutorial';

  // ROUTE MAP (tidak memasukkan editHabit karena butuh argument)
  static Map<String, WidgetBuilder> routes = {
    dailyHome: (_) => const DailyHomePage(),
    createHabit: (_) => const CreateHabitPage(),
    dailyRepeat: (_) => const DailyRepeatPage(),
    scheduled: (_) => const ScheduledPage(),
    // challenge: (_) => const ChallengePage(),
    // tutorial: (_) => const TutorialPage(),
  };

  // onGenerateRoute -> menangani route yang butuh arguments (EditHabitPage)
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    if (settings.name == editHabit) {
      final args = settings.arguments;
      if (args is HabitModel) {
        return MaterialPageRoute(
          builder: (_) => EditHabitPage(habit: args),
          settings: settings,
        );
      } else {
        // Jika arguments tidak diberikan atau salah tipe, tampilkan halaman error kecil
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('Error')),
            body: Center(
              child: Text(
                'EditHabit: missing or invalid arguments for ${settings.name}',
              ),
            ),
          ),
        );
      }
    }

    // kembalikan null agar MaterialApp menggunakan routes map (jika ditemukan)
    return null;
  }
}
