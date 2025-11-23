import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../models/habit_model.dart';
import 'edit_habit_page.dart';

class DailyHomePage extends StatelessWidget {
  const DailyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    var box = Hive.box<HabitModel>('daily_habits');

    return Scaffold(
      appBar: AppBar(title: const Text("Daily Habit")),
      body: ValueListenableBuilder(
        valueListenable: box.listenable(),
        builder: (context, box, _) {
          final tasks = box.values.toList();

          return ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final habit = tasks[index];

              return ListTile(
                title: Text(habit.title),
                subtitle: Text(habit.note),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditHabitPage(habit: habit),
                    ),
                  );
                },
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => habit.delete(),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
