import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'routes/app_routes.dart';
import 'models/habit_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // INIT HIVE
  await Hive.initFlutter();

  // REGISTER ADAPTER
  Hive.registerAdapter(HabitModelAdapter());

  // OPEN BOX
  await Hive.openBox<HabitModel>('habits');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      // HALAMAN AWAL
      initialRoute: AppRoutes.dailyHome,

      // ROUTES LIST
      routes: AppRoutes.routes,
    );
  }
}
