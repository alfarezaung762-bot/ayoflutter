import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

// GLOBAL KEY NAVIGASI (Penting untuk membuka layar dari background)
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Kunci orientasi ke Portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

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

  // Box Pengaturan
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

    // 1. Cek & Minta Izin
    _checkAndroidPermissions();

    // 2. Setup Listener Alarm
    _configureAlarmListener();

    // 3. Cek alarm saat start (VERSI FIX UNTUK ALARM 5.1.5)
    _checkIfAlarmIsRingingOnStart();
  }

  void _configureAlarmListener() {
    Alarm.ringStream.stream.listen((alarmSettings) {
      debugPrint("Alarm Ring Stream Triggered: ${alarmSettings.id}");
      _navigateToRingPage(alarmSettings);
    });
  }

  // [PERBAIKAN UTAMA UNTUK ALARM 5.1.5]
  // getRingIds() sudah dihapus, jadi kita pakai logika ini:
  Future<void> _checkIfAlarmIsRingingOnStart() async {
    // Tunggu sebentar biar sistem siap
    await Future.delayed(const Duration(milliseconds: 500));

    // Ambil semua alarm yang terdaftar
    final allAlarms = await Alarm.getAlarms();

    // Cek satu per satu apakah ada yang sedang 'ringing'
    for (final alarm in allAlarms) {
      // Alarm.isRinging(id) adalah cara baru di versi 5.x
      final isRinging = await Alarm.isRinging(alarm.id);

      if (isRinging) {
        debugPrint("Active alarm found on start: ${alarm.id}");
        _navigateToRingPage(alarm);
        break; // Stop jika sudah ketemu satu
      }
    }
  }

  // Fungsi Navigasi Terpusat
  void _navigateToRingPage(AlarmSettings settings) {
    // Pastikan navigator siap
    if (navigatorKey.currentState == null) return;

    // Gunakan pushReplacement agar user tidak bisa 'back' sembarangan
    navigatorKey.currentState!.push(
      MaterialPageRoute(
        builder: (context) => AlarmRingPage(alarmSettings: settings),
      ),
    );
  }

  Future<void> _checkAndroidPermissions() async {
    // Izin Notifikasi (Android 13+)
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }
    // Izin Alarm Akurat (Android 12+)
    if (await Permission.scheduleExactAlarm.isDenied) {
      await Permission.scheduleExactAlarm.request();
    }
    // Izin Overlay / Display Over Other Apps (WAJIB untuk Fullscreen di atas YouTube)
    if (await Permission.systemAlertWindow.isDenied) {
      await Permission.systemAlertWindow.request();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Hive.box('settings').listenable(),
      builder: (context, Box box, widget) {
        final bool isDark = box.get('isDarkMode', defaultValue: false);

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          navigatorKey: navigatorKey, // Pasang Global Key
          title: 'Ayo',

          // --- KONFIGURASI TEMA ---
          themeMode: isDark ? ThemeMode.dark : ThemeMode.light,

          theme: ThemeData(
            brightness: Brightness.light,
            scaffoldBackgroundColor: const Color(0xFFF7F7F7),
            primaryColor: const Color(0xFFFFA726),
            cardColor: Colors.white,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFFFFA726),
              brightness: Brightness.light,
            ),
            useMaterial3: true,
          ),

          darkTheme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF1E1E2C),
            primaryColor: const Color(0xFFFFA726),
            cardColor: const Color(0xFF2C2C3E),
            colorScheme: ColorScheme.dark(
              primary: const Color(0xFFFFA726),
              secondary: Colors.orangeAccent,
              surface: const Color(0xFF2C2C3E),
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
