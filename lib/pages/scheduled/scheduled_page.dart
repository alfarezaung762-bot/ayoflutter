import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../models/scheduled_habit_model.dart';
import '../../widgets/side_menu_drawer.dart';
import 'create_scheduled_page.dart';

class ScheduledPage extends StatefulWidget {
  const ScheduledPage({super.key});

  @override
  State<ScheduledPage> createState() => _ScheduledPageState();
}

class _ScheduledPageState extends State<ScheduledPage> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  late Box<ScheduledHabitModel> box;

  @override
  void initState() {
    super.initState();
    box = Hive.box<ScheduledHabitModel>('scheduled_box');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: const Color(0xFFF7F7F7),
      drawer: const SideMenuDrawer(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateScheduledPage()),
          );
        },
        backgroundColor: Colors.orange,
        icon: const Icon(Icons.add),
        label: const Text(
          "Jadwal Baru",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _header(scaffoldKey),

            // --- INFO HEADER (Judul Daftar) ---
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: const Text(
                "Daftar Semua Jadwal",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87),
              ),
            ),

            // --- LIST TUGAS ---
            Expanded(
              child: ValueListenableBuilder(
                valueListenable: box.listenable(),
                builder: (context, box, _) {
                  // 1. Ambil semua data
                  final tasks = box.values.toList();

                  // 2. Urutkan berdasarkan tanggal terdekat (Ascending)
                  tasks.sort((a, b) => a.date.compareTo(b.date));

                  if (tasks.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.event_available,
                            size: 80,
                            color: Colors.grey.shade300,
                          ),
                          const SizedBox(height: 15),
                          const Text(
                            "Belum ada jadwal tersimpan",
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      return _taskCard(task);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header(GlobalKey<ScaffoldState> key) {
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
          Row(
            children: [
              IconButton(
                onPressed: () => key.currentState?.openDrawer(),
                icon: const Icon(Icons.menu, color: Colors.white, size: 28),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 12),
              const Text(
                "Tugas Bertanggal",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Padding(
            padding: EdgeInsets.only(left: 4),
            child: Text(
              "Jangan lewatkan jadwal pentingmu",
              style: TextStyle(color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET CARD MODERN ---
  Widget _taskCard(ScheduledHabitModel h) {
    final priorityColor = [
      Colors.green, // 0
      Colors.orange, // 1
      Colors.red // 2
    ][h.priority];

    final priorityText = ["Rendah", "Sedang", "Tinggi"][h.priority];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        // Garis warna di kiri
        border: Border(
          left: BorderSide(
            color: h.isDone ? Colors.grey : priorityColor,
            width: 6,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Baris 1: Judul
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    h.title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      decoration: h.isDone ? TextDecoration.lineThrough : null,
                      color: h.isDone ? Colors.grey : Colors.black87,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    h.isDone = !h.isDone;
                    h.save();
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: h.isDone ? Colors.green : Colors.transparent,
                      border: Border.all(
                        color: h.isDone ? Colors.green : Colors.grey.shade400,
                        width: 2,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: h.isDone
                          ? const Icon(Icons.check,
                              size: 16, color: Colors.white)
                          : const SizedBox(width: 16, height: 16),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Baris 2: Info
            Row(
              children: [
                _infoChip(Icons.calendar_today,
                    "${h.date.day}-${h.date.month}-${h.date.year}"),
                const SizedBox(width: 12),
                _infoChip(Icons.access_time, h.time),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: h.isDone
                        ? Colors.grey.withOpacity(0.2)
                        : priorityColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    priorityText,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: h.isDone ? Colors.grey : priorityColor,
                    ),
                  ),
                ),
              ],
            ),

            // Baris 3: Catatan
            if (h.note.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F7FA),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  h.note,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                ),
              ),
            ],

            // Baris 4: Edit & Hapus (SUDAH ADA DISINI)
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // TOMBOL EDIT
                InkWell(
                  onTap: () {
                    Navigator.pushNamed(context, '/edit-scheduled',
                        arguments: h);
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    child: Text(
                      "Edit",
                      style: TextStyle(
                          color: Colors.orange,
                          fontSize: 12,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // TOMBOL HAPUS
                InkWell(
                  onTap: () => h.delete(),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    child: Text(
                      "Hapus",
                      style: TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoChip(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}
