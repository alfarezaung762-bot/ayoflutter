import 'package:flutter/material.dart';
import '../../models/habit_model.dart';

class EditHabitPage extends StatefulWidget {
  final HabitModel habit;

  const EditHabitPage({super.key, required this.habit});

  @override
  State<EditHabitPage> createState() => _EditHabitPageState();
}

class _EditHabitPageState extends State<EditHabitPage> {
  late TextEditingController titleC;
  late TextEditingController noteC;

  @override
  void initState() {
    super.initState();
    titleC = TextEditingController(text: widget.habit.title);
    noteC = TextEditingController(text: widget.habit.note);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Habit")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: titleC,
              decoration: const InputDecoration(labelText: "Judul"),
            ),
            TextField(
              controller: noteC,
              decoration: const InputDecoration(labelText: "Catatan"),
            ),
            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                widget.habit.title = titleC.text;
                widget.habit.note = noteC.text;

                widget.habit.save();
                Navigator.pop(context);
              },
              child: const Text("SIMPAN"),
            ),
          ],
        ),
      ),
    );
  }
}
