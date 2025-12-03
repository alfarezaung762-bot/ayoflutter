import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../../models/habit_model.dart';

class CreateHabitPage extends StatefulWidget {
  const CreateHabitPage({super.key});

  @override
  State<CreateHabitPage> createState() => _CreateHabitPageState();
}

class _CreateHabitPageState extends State<CreateHabitPage> {
  final titleC = TextEditingController();
  final noteC = TextEditingController();
  final timeC = TextEditingController();

  String priority = "SEDANG";

  // -----------------------------
  // Fungsi open Time Picker
  // -----------------------------
  Future<void> pickTime() async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      final formatted =
          "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}";

      setState(() {
        timeC.text = formatted;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<HabitModel>('habits');

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ========= HEADER =========
            Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: const BoxDecoration(color: Color(0xFFFFA726)),
              child: const Center(
                child: Text(
                  "BUAT TUGAS",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
              ),
            ),

            const SizedBox(height: 16),

            const Text("Tugas", style: TextStyle(fontWeight: FontWeight.bold)),
            TextField(controller: titleC),

            const SizedBox(height: 16),

            const Text(
              "Catatan",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextField(controller: noteC, maxLines: 3),

            const SizedBox(height: 16),

            Row(
              children: [
                // =======================
                // FIELD WAKTU (TimePicker)
                // =======================
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Waktu",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextField(
                        controller: timeC,
                        readOnly:
                            true, // ← tidak bisa diketik biar tidak masuk huruf
                        onTap: pickTime, // ← buka time picker
                        decoration: InputDecoration(
                          suffixIcon: Icon(Icons.access_time),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 16),

                // PRIORITAS
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Prioritas",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      DropdownButtonFormField(
                        value: priority,
                        items: ["RENDAH", "SEDANG", "TINGGI"]
                            .map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)),
                            )
                            .toList(),
                        onChanged: (v) => setState(() => priority = v!),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // ====== BUTTON BUAT TUGAS ======
            ElevatedButton(
              onPressed: () {
                box.add(
                  HabitModel(
                    title: titleC.text,
                    note: noteC.text,
                    time: timeC.text,
                    priority: priority == "RENDAH"
                        ? 0
                        : priority == "SEDANG"
                        ? 1
                        : 2,
                  ),
                );

                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFA726),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text(
                "BUAT TUGAS",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
