import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../models/habit_model.dart';
import 'create_habit_page.dart';
import 'edit_habit_page.dart';
// Import Sidebar yang baru kita buat
import '../../widgets/side_menu_drawer.dart';

class DailyHomePage extends StatefulWidget {
  const DailyHomePage({super.key});

  @override
  State<DailyHomePage> createState() => _DailyHomePageState();
}

class _DailyHomePageState extends State<DailyHomePage> {
  late Box<HabitModel> box;
  Duration timeLeft = const Duration(hours: 24);
  Timer? _timer;

  // KEY UNTUK MEMBUKA DRAWER SECARA MANUAL
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    box = Hive.box<HabitModel>('habits');

    // 1. Cek reset saat aplikasi pertama kali dibuka (Lazy Reset)
    _checkDailyReset();

    // 2. Jalankan timer untuk hitung mundur visual
    _updateTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateTime());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // --- LOGIKA RESET: Cek Tanggal ---
  void _checkDailyReset() {
    final now = DateTime.now();
    final todayStr = now.toIso8601String().split('T').first;

    for (var h in box.values) {
      if (h.lastResetDate != todayStr) {
        h.isDone = false;
        h.lastResetDate = todayStr;
        h.save();
      }
    }
  }

  // --- LOGIKA TIMER: Update Hitungan Mundur ---
  void _updateTime() {
    final now = DateTime.now();
    final end = DateTime(now.year, now.month, now.day + 1);
    final diff = end.difference(now);

    if (mounted) {
      setState(() {
        timeLeft = diff;
      });
    }

    if (diff.inSeconds == 0) {
      _checkDailyReset();
    }
  }

  String _fmt(Duration d) =>
      "${d.inHours.toString().padLeft(2, '0')}:${(d.inMinutes % 60).toString().padLeft(2, '0')}:${(d.inSeconds % 60).toString().padLeft(2, '0')}";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey, // 1. Pasang Key di sini
      backgroundColor: const Color(0xFFF7F7F7),

      // 2. Pasang Drawer di sini
      drawer: const SideMenuDrawer(),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CreateHabitPage()),
        ),
        backgroundColor: const Color(0xFFFFA726),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        label: const Text(
          "Buat Habit",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        icon: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 3. Update Header dengan Tombol Menu
            _header(),

            // Timer Text
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                "Reset dalam: ${_fmt(timeLeft)}",
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black54,
                ),
              ),
            ),

            const SizedBox(height: 10),

            // List Habits
            Expanded(
              child: ValueListenableBuilder(
                valueListenable: box.listenable(),
                builder: (_, __, ___) {
                  final all = box.values.toList();
                  final today = all.where((h) => !h.isDone).toList();
                  final done = all.where((h) => h.isDone).toList();

                  return ListView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    children: [
                      if (today.isNotEmpty) ...[
                        _sect("Tugas Hari Ini"),
                        ...today.map(_card),
                      ],
                      if (done.isNotEmpty) ...[
                        _sect("Sudah Selesai"),
                        ...done.map(_card),
                      ],
                      const SizedBox(height: 80),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET HEADER BARU (Dengan Tombol Menu) ---
  Widget _header() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 34),
      decoration: const BoxDecoration(
        color: Color(0xFFFFA726),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Baris atas: Icon Menu + Judul
          Row(
            children: [
              IconButton(
                onPressed: () {
                  // Buka Drawer pakai key
                  _scaffoldKey.currentState?.openDrawer();
                },
                icon: const Icon(Icons.menu, color: Colors.white, size: 28),
                padding: EdgeInsets.zero,
                constraints:
                    const BoxConstraints(), // Biar tidak ada padding default
                visualDensity: VisualDensity.compact,
              ),
              const SizedBox(width: 12),
              const Text(
                "Daily Habit",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Padding(
            padding: EdgeInsets.only(left: 4), // Sedikit indent biar rapi
            child: Text(
              "Atur dan selesaikan tugasmu hari ini",
              style: TextStyle(color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sect(String t) => Padding(
    padding: const EdgeInsets.only(top: 12, bottom: 8),
    child: Text(
      t,
      style: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w700,
        color: Colors.black87,
      ),
    ),
  );

  Widget _card(HabitModel h) {
    final color = [Colors.green, Colors.orange, Colors.red][h.priority];
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 7),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Colors.orange.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              h.isDone = !h.isDone;
              h.save();
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: h.isDone ? Colors.green : color,
                boxShadow: [
                  BoxShadow(color: color.withOpacity(0.4), blurRadius: 8),
                ],
              ),
              child: Icon(
                h.isDone ? Icons.check : Icons.flag,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  h.title,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    decoration: h.isDone ? TextDecoration.lineThrough : null,
                    color: h.isDone ? Colors.grey : Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  h.time,
                  style: TextStyle(fontSize: 13, color: Colors.orange.shade700),
                ),
                const SizedBox(height: 6),
                Text(
                  h.note,
                  style: TextStyle(
                    fontSize: 14,
                    color: h.isDone ? Colors.grey : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              IconButton(
                onPressed: () => Navigator.pushNamed(
                  context,
                  '/edit-habit', // Sesuaikan dengan AppRoutes
                  arguments: h,
                ),
                icon: const Icon(Icons.edit, color: Colors.orange),
              ),
              IconButton(
                onPressed: () => h.delete(),
                icon: const Icon(Icons.delete, color: Colors.redAccent),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
