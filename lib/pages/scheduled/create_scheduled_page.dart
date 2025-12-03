import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../../models/scheduled_habit_model.dart';

class CreateScheduledPage extends StatefulWidget {
  const CreateScheduledPage({super.key});

  @override
  State<CreateScheduledPage> createState() => _CreateScheduledPageState();
}

class _CreateScheduledPageState extends State<CreateScheduledPage> {
  final titleC = TextEditingController();
  final noteC = TextEditingController();
  final timeC = TextEditingController();
  final dateC = TextEditingController();

  DateTime? selectedDate;
  String priority = "SEDANG";

  // --- FUNGSI PEMBERSIH TANGGAL (PENTING!) ---
  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  Future<void> pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        // Simpan tanggal yang sudah dibersihkan jamnya
        selectedDate = _normalizeDate(picked);

        // Tampilkan di TextField
        dateC.text =
            "${picked.day.toString().padLeft(2, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.year}";
      });
    }
  }

  Future<void> pickTime() async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      final formatted =
          "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}";
      setState(() => timeC.text = formatted);
    }
  }

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<ScheduledHabitModel>('scheduled_box');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Buat Jadwal Baru",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFFFFA726),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text("Judul Tugas",
              style: TextStyle(fontWeight: FontWeight.bold)),
          TextField(controller: titleC),
          const SizedBox(height: 16),

          const Text("Catatan", style: TextStyle(fontWeight: FontWeight.bold)),
          TextField(controller: noteC, maxLines: 2),
          const SizedBox(height: 16),

          // TANGGAL & JAM
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Tanggal",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    TextField(
                      controller: dateC,
                      readOnly: true,
                      onTap: pickDate,
                      decoration: const InputDecoration(
                          suffixIcon:
                              Icon(Icons.calendar_today, color: Colors.orange)),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Jam",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    TextField(
                      controller: timeC,
                      readOnly: true,
                      onTap: pickTime,
                      decoration: const InputDecoration(
                          suffixIcon:
                              Icon(Icons.access_time, color: Colors.orange)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          const Text("Prioritas",
              style: TextStyle(fontWeight: FontWeight.bold)),
          DropdownButtonFormField(
            value: priority,
            items: ["RENDAH", "SEDANG", "TINGGI"]
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: (v) => setState(() => priority = v!),
          ),

          const SizedBox(height: 32),

          ElevatedButton(
            onPressed: () async {
              if (titleC.text.isEmpty || selectedDate == null) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text("Judul dan Tanggal wajib diisi!")));
                return;
              }

              try {
                // SIMPAN KE HIVE (Pastikan pakai tanggal yang sudah dinormalisasi)
                await box.add(ScheduledHabitModel(
                  title: titleC.text,
                  note: noteC.text,
                  date:
                      selectedDate!, // Tanggal ini sudah bersih dari fungsi pickDate
                  time: timeC.text,
                  priority: priority == "RENDAH"
                      ? 0
                      : priority == "SEDANG"
                          ? 1
                          : 2,
                ));

                if (context.mounted) Navigator.pop(context);
              } catch (e) {
                print("Error: $e");
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFA726),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
            ),
            child: const Text("SIMPAN JADWAL",
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
