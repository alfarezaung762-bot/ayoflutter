import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:alarm/alarm.dart';
import 'package:permission_handler/permission_handler.dart';
import 'routes/app_routes.dart';

// --- IMPORT MODEL ---
import 'models/habit_model.dart';
import 'models/scheduled_habit_model.dart';
import 'models/tutorial_model.dart';
import 'models/challenge_model.dart';

// --- IMPORT HALAMAN ALARM ---
import 'pages/alarm/alarm_ring_page.dart';

// GLOBAL KEY NAVIGASI
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Init Hive
  await Hive.initFlutter();

  // --- REGISTER ADAPTERS ---
  Hive.registerAdapter(HabitModelAdapter());
  Hive.registerAdapter(ScheduledHabitModelAdapter());
  Hive.registerAdapter(TutorialModelAdapter());
  Hive.registerAdapter(ChallengeModelAdapter());

  // --- OPEN BOXES ---
  await Hive.openBox<HabitModel>('habits');
  await Hive.openBox<ScheduledHabitModel>('scheduled_box');
  await Hive.openBox<TutorialModel>('tutorial_box');
  await Hive.openBox<ChallengeModel>('challenge_box');

  // [BARU] Buka Box untuk Pengaturan
  await Hive.openBox('settings');

  // --- INIT ALARM ---
  await Alarm.init();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    _checkAndroidNotificationPermission();

    Alarm.ringStream.stream.listen((alarmSettings) {
      navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (context) => AlarmRingPage(alarmSettings: alarmSettings),
        ),
      );
    });
  }

  Future<void> _checkAndroidNotificationPermission() async {
    final status = await Permission.notification.status;
    if (status.isDenied) {
      await Permission.notification.request();
    }
    if (await Permission.scheduleExactAlarm.isDenied) {
      await Permission.scheduleExactAlarm.request();
    }
  }

  @override
  Widget build(BuildContext context) {
    // [PENTING] Bungkus MaterialApp dengan ValueListenableBuilder
    // Ini mendengarkan perubahan di box 'settings'
    return ValueListenableBuilder(
      valueListenable: Hive.box('settings').listenable(),
      builder: (context, Box box, widget) {
        // Ambil status dark mode (default false/mati)
        final bool isDark = box.get('isDarkMode', defaultValue: false);

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          navigatorKey: navigatorKey,

          // --- KONFIGURASI TEMA ---
          // Mode: Ikuti status isDark
          themeMode: isDark ? ThemeMode.dark : ThemeMode.light,

          // TEMA TERANG (Light)
          theme: ThemeData(
            brightness: Brightness.light,
            scaffoldBackgroundColor: const Color(0xFFF7F7F7),
            primaryColor: const Color(0xFFFFA726),
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFFFFA726),
              brightness: Brightness.light,
            ),
            useMaterial3: true,
          ),

          // TEMA GELAP (Dark)
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            // Warna background gelap tapi agak biru dikit (Elegan)
            scaffoldBackgroundColor: const Color(0xFF1E1E2C),
            primaryColor: const Color(0xFFFFA726),
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFFFFA726), // Tetap Orange
              secondary: Colors.orangeAccent,
              surface: Color(0xFF2C2C3E), // Warna kartu di mode gelap
            ),
            useMaterial3: true,
          ),
          // -------------------------

          initialRoute: AppRoutes.dailyHome,
          routes: AppRoutes.routes,
          onGenerateRoute: AppRoutes.onGenerateRoute,
        );
      },
    );
  }
}
