import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../models/habit_model.dart';
import 'edit_habit_page.dart';
import 'create_habit_page.dart';

class DailyHomePage extends StatelessWidget {
  const DailyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<HabitModel>('habits');

    return Scaffold(
      body: Column(
        children: [
          // =======================
          // HEADER
          // =======================
          Container(
            padding: const EdgeInsets.only(
              top: 50,
              left: 20,
              right: 20,
              bottom: 15,
            ),
            color: Colors.orange,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Icon(Icons.menu, color: Colors.white),

                // TOMBOL BUAT HABIT
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CreateHabitPage()),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: const Text(
                      "Buat Habit",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),

                const CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, color: Colors.black),
                ),
              ],
            ),
          ),

          // =======================
          // LIST TUGAS
          // =======================
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: box.listenable(),
              builder: (context, box, _) {
                final tasksToday = box.values.where((e) => !e.isDone).toList();
                final tasksDone = box.values.where((e) => e.isDone).toList();

                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // =======================
                      // TUGAS HARI INI
                      // =======================
                      const Padding(
                        padding: EdgeInsets.all(12),
                        child: Text(
                          "Tugas Hari Ini",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),

                      for (var habit in tasksToday)
                        GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EditHabitPage(habit: habit),
                            ),
                          ),
                          child: _buildTaskCard(habit, Colors.redAccent),
                        ),

                      // =======================
                      // SELESAI DIKERJAKAN
                      // =======================
                      const Padding(
                        padding: EdgeInsets.all(12),
                        child: Text(
                          "Selesai dikerjakan",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),

                      for (var habit in tasksDone)
                        GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EditHabitPage(habit: habit),
                            ),
                          ),
                          child: _buildTaskCard(habit, Colors.yellow.shade600),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // =============================================================
  // CARD DESIGN
  // =============================================================
  Widget _buildTaskCard(HabitModel habit, Color color) {
    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                habit.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              Text(habit.note),
            ],
          ),

          IconButton(
            icon: const Icon(Icons.delete, color: Colors.black),
            onPressed: () => habit.delete(),
          ),
        ],
      ),
    );
  }
}
