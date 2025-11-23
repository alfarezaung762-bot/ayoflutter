import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../models/habit_model.dart';
import '../../routes/app_routes.dart';

class DailyRepeatPage extends StatelessWidget {
  const DailyRepeatPage({super.key});

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<HabitModel>('daily_habits');

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: const Text("Daily Habit", style: TextStyle(color: Colors.white)),
      ),

      body: ValueListenableBuilder(
        valueListenable: box.listenable(),
        builder: (context, Box<HabitModel> habits, _) {
          if (habits.isEmpty) {
            return const Center(child: Text("Belum ada habit"));
          }

          return ListView.builder(
            itemCount: habits.length,
            itemBuilder: (context, i) {
              final habit = habits.getAt(i)!;

              return ListTile(
                title: Text(habit.title),
                subtitle: Text("${habit.note}\nWaktu: ${habit.time}"),
                isThreeLine: true,
                leading: Checkbox(
                  value: habit.isDone,
                  onChanged: (value) {
                    habit.isDone = value!;
                    habit.save();
                  },
                ),
              );
            },
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.createHabit);
        },
      ),
    );
  }
}
