import 'package:flutter/material.dart';
import '../../models/habit_model.dart';

class EditHabitPage extends StatefulWidget {
  // Kita butuh data habit mana yang mau diedit
  final HabitModel habit;

  const EditHabitPage({super.key, required this.habit});

  @override
  State<EditHabitPage> createState() => _EditHabitPageState();
}

class _EditHabitPageState extends State<EditHabitPage> {
  // Controller
  final titleC = TextEditingController();
  final noteC = TextEditingController();
  final timeC = TextEditingController();

  String priority = "SEDANG";

  @override
  void initState() {
    super.initState();
    // ----------------------------------------------------
    // INI BEDANYA: Kita isi form dengan data yang lama
    // ----------------------------------------------------
    titleC.text = widget.habit.title;
    noteC.text = widget.habit.note;
    timeC.text = widget.habit.time;

    // Set dropdown sesuai data lama
    priority = widget.habit.priority == 0
        ? "RENDAH"
        : widget.habit.priority == 1
        ? "SEDANG"
        : "TINGGI";
  }

  // Fungsi Time Picker (Sama persis)
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
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ========= HEADER (Sama persis, cuma ganti teks) =========
            Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: const BoxDecoration(color: Color(0xFFFFA726)),
              child: const Center(
                child: Text(
                  "EDIT TUGAS", // Ganti Teks
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
                // FIELD WAKTU
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
                        readOnly: true,
                        onTap: pickTime,
                        decoration: const InputDecoration(
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

            // ====== BUTTON SIMPAN (Logika Berbeda) ======
            ElevatedButton(
              onPressed: () {
                // UPDATE data yang ada di widget.habit
                widget.habit.title = titleC.text;
                widget.habit.note = noteC.text;
                widget.habit.time = timeC.text;
                widget.habit.priority = priority == "RENDAH"
                    ? 0
                    : priority == "SEDANG"
                    ? 1
                    : 2;

                // SIMPAN PERUBAHAN KE HIVE
                widget.habit.save();

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
                "SIMPAN PERUBAHAN", // Ganti Teks Tombol
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
