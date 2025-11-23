import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../../models/habit_model.dart';

class CreateHabitPage extends StatefulWidget {
  const CreateHabitPage({super.key});

  @override
  State<CreateHabitPage> createState() => _CreateHabitPageState();
}

class _CreateHabitPageState extends State<CreateHabitPage> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController noteController = TextEditingController();

  TimeOfDay? selectedTime;
  int priority = 0; // 0=low, 1=medium, 2=high

  void saveHabit() async {
    if (titleController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Judul tidak boleh kosong")));
      return;
    }

    final box = Hive.box<HabitModel>('daily_habits');

    final habit = HabitModel(
      title: titleController.text,
      note: noteController.text,
      time: selectedTime != null
          ? "${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}"
          : "00:00",
      priority: priority,
    );

    await box.add(habit);

    Navigator.pop(context); // kembali setelah save
  }

  Future<void> pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (time != null) {
      setState(() => selectedTime = time);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: const Text("BUAT HABIT", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const Text("Judul"),
            TextField(
              controller: titleController,
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
            const SizedBox(height: 15),

            const Text("Catatan"),
            TextField(
              controller: noteController,
              maxLines: 3,
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
            const SizedBox(height: 15),

            const Text("Waktu"),
            ElevatedButton(
              onPressed: pickTime,
              child: Text(
                selectedTime == null
                    ? "Pilih Waktu"
                    : "${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}",
              ),
            ),
            const SizedBox(height: 15),

            const Text("Prioritas"),
            Row(
              children: [
                choice("Low", 0),
                const SizedBox(width: 10),
                choice("Medium", 1),
                const SizedBox(width: 10),
                choice("High", 2),
              ],
            ),

            const SizedBox(height: 30),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: saveHabit,
              child: const Text(
                "SIMPAN",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget choice(String label, int value) {
    return ChoiceChip(
      label: Text(label),
      selected: priority == value,
      onSelected: (_) => setState(() => priority = value),
    );
  }
}
