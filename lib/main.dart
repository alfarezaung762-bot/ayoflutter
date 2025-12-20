import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'routes/app_routes.dart';

// --- IMPORT MODEL ---
import 'models/habit_model.dart'; // Daily
import 'models/scheduled_habit_model.dart'; // Scheduled
import 'models/tutorial_model.dart'; // Tutorial
import 'models/challenge_model.dart'; // Challenge (BARU)

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Init Hive
  await Hive.initFlutter();

  // --- REGISTER ADAPTERS ---
  Hive.registerAdapter(HabitModelAdapter()); // TypeId: 0
  Hive.registerAdapter(ScheduledHabitModelAdapter()); // TypeId: 1
  Hive.registerAdapter(TutorialModelAdapter()); // TypeId: 2
  Hive.registerAdapter(ChallengeModelAdapter()); // TypeId: 3 (BARU)

  // --- OPEN BOXES ---
  await Hive.openBox<HabitModel>('habits');
  await Hive.openBox<ScheduledHabitModel>('scheduled_box');
  await Hive.openBox<TutorialModel>('tutorial_box');
  await Hive.openBox<ChallengeModel>('challenge_box'); // (BARU)

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      // Halaman Awal
      initialRoute: AppRoutes.dailyHome,

      // 1. Daftar Route Biasa
      routes: AppRoutes.routes,

      // 2. DAFTAR ROUTE SPESIAL
      onGenerateRoute: AppRoutes.onGenerateRoute,
    );
  }
}
