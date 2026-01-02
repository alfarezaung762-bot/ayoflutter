import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:alarm/alarm.dart'; // Import Alarm
import 'routes/app_routes.dart';

// --- IMPORT MODEL ---
import 'models/habit_model.dart';
import 'models/scheduled_habit_model.dart';
import 'models/tutorial_model.dart';
import 'models/challenge_model.dart';

// --- IMPORT HALAMAN ALARM (PENTING) ---
// Pastikan path ini sesuai dengan tempat kamu menyimpan file alarm_ring_page.dart
import 'pages/alarm/alarm_ring_page.dart';

// 1. BUAT GLOBAL KEY NAVIGASI (Di luar class apapun)
// Ini berguna agar kita bisa pindah halaman secara otomatis saat alarm bunyi
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

  // --- INIT ALARM ---
  await Alarm.init();

  runApp(const MyApp());
}

// 2. UBAH MyApp JADI STATEFUL WIDGET
// Kita butuh 'initState' untuk memasang pendengar (listener) alarm
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();

    // 3. PASANG "TELINGA" (LISTENER) UNTUK ALARM
    // Kode ini akan jalan otomatis saat alarm berbunyi
    Alarm.ringStream.stream.listen((alarmSettings) {
      // Saat alarm bunyi, langsung buka halaman AlarmRingPage
      navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (context) => AlarmRingPage(alarmSettings: alarmSettings),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      // 4. MASUKKAN KEY NAVIGASI DI SINI
      navigatorKey: navigatorKey, // <--- JANGAN LUPA INI

      // Halaman Awal
      initialRoute: AppRoutes.dailyHome,

      // Daftar Route
      routes: AppRoutes.routes,

      // Daftar Route Spesial
      onGenerateRoute: AppRoutes.onGenerateRoute,
    );
  }
}
