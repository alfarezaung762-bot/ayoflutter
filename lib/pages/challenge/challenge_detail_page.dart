import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // WAJIB: Pastikan package 'intl' sudah ada di pubspec.yaml
import '../../models/challenge_model.dart';

class ChallengeDetailPage extends StatefulWidget {
  final ChallengeModel challenge;

  const ChallengeDetailPage({super.key, required this.challenge});

  @override
  State<ChallengeDetailPage> createState() => _ChallengeDetailPageState();
}

class _ChallengeDetailPageState extends State<ChallengeDetailPage> {
  late List<bool> tasksStatus;

  @override
  void initState() {
    super.initState();
    tasksStatus =
        List.generate(widget.challenge.dailyTasks.length, (_) => false);
  }

  void _toggleTask(int index) {
    setState(() {
      tasksStatus[index] = !tasksStatus[index];
    });
  }

  // --- WIDGET GENERATE KALENDER DINAMIS ---
  Widget _buildWeeklyCalendar() {
    final now = DateTime.now();

    // Kita buat 7 hari (3 hari lalu, hari ini, 3 hari depan) agar hari ini di tengah
    // ATAU: Senin-Minggu minggu ini. Mari kita buat Senin-Minggu sederhana.

    // Cari hari Senin minggu ini
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (index) {
        final date = startOfWeek.add(Duration(days: index));
        final dayName =
            DateFormat('E').format(date)[0]; // Ambil huruf pertama (M, T, W...)
        final bool isToday = date.day == now.day && date.month == now.month;

        return Container(
          width: 40,
          height: 60,
          decoration: BoxDecoration(
            color: isToday ? Colors.white : Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(
                20), // Bentuk lonjong seperti gambar referensi
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                dayName,
                style: TextStyle(
                    color: isToday ? Colors.black : Colors.white70,
                    fontWeight: FontWeight.bold,
                    fontSize: 12),
              ),
              const SizedBox(height: 4),
              // Titik indikator jika hari ini
              if (isToday)
                Container(
                  width: 4,
                  height: 4,
                  decoration: const BoxDecoration(
                      color: Colors.orange, shape: BoxShape.circle),
                )
            ],
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.challenge;
    double progress = c.progressDay / c.durationDays;

    return Scaffold(
      backgroundColor: const Color(0xFF1E1E2C),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- HEADER ---
            Container(
              padding: const EdgeInsets.fromLTRB(20, 50, 20, 30),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(c.colorCode),
                    Color(c.colorCode).withOpacity(0.6)
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius:
                    const BorderRadius.vertical(bottom: Radius.circular(40)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                          icon:
                              const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => Navigator.pop(context)),
                      IconButton(
                          icon:
                              const Icon(Icons.more_vert, color: Colors.white),
                          onPressed: () {}),
                    ],
                  ),
                  const SizedBox(height: 10),

                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(c.title,
                                style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white)),
                            const SizedBox(height: 8),
                            Text("${(progress * 100).toInt()}% done",
                                style: const TextStyle(
                                    color: Colors.white70, fontSize: 16)),
                          ],
                        ),
                      ),
                      // Ilustrasi Progress (Circle)
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 80,
                            height: 80,
                            child: CircularProgressIndicator(
                              value: progress,
                              strokeWidth: 8,
                              backgroundColor: Colors.white24,
                              valueColor: const AlwaysStoppedAnimation(
                                  Colors.orangeAccent),
                            ),
                          ),
                          // Matahari Hiasan
                          Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                  color: Colors.orangeAccent.withOpacity(0.3),
                                  shape: BoxShape.circle)),
                        ],
                      )
                    ],
                  ),

                  const SizedBox(height: 30),

                  // --- KALENDER DINAMIS ---
                  _buildWeeklyCalendar(),
                ],
              ),
            ),

            // --- ISI TUGAS ---
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("TODAY'S TASKS",
                      style: TextStyle(
                          color: Colors.white70,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          letterSpacing: 1.2)),
                  const SizedBox(height: 20),
                  ...List.generate(c.dailyTasks.length,
                      (index) => _taskItem(index, c.dailyTasks[index])),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget Item Tugas
  Widget _taskItem(int index, String taskTitle) {
    bool isLast = index == widget.challenge.dailyTasks.length - 1;
    bool isDone = tasksStatus[index];

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              GestureDetector(
                onTap: () => _toggleTask(index),
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: isDone ? Colors.green : Colors.grey, width: 2),
                    color: isDone ? Colors.green : Colors.transparent,
                  ),
                  child: isDone
                      ? const Icon(Icons.check, size: 16, color: Colors.white)
                      : null,
                ),
              ),
              if (!isLast)
                Expanded(
                    child: Container(
                        width: 2, color: Colors.grey.withOpacity(0.3)))
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF2C2C3E),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        color:
                            Color(widget.challenge.colorCode).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8)),
                    child: Icon(Icons.star,
                        color: Color(widget.challenge.colorCode)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          taskTitle,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            decoration:
                                isDone ? TextDecoration.lineThrough : null,
                            decorationColor: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text("Keep going!",
                            style: TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
