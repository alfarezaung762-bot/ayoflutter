import 'package:flutter/material.dart';
import '../../models/scheduled_habit_model.dart';

class EditScheduledPage extends StatefulWidget {
  final ScheduledHabitModel habit; // Terima data yang mau diedit

  const EditScheduledPage({super.key, required this.habit});

  @override
  State<EditScheduledPage> createState() => _EditScheduledPageState();
}

class _EditScheduledPageState extends State<EditScheduledPage> {
  final titleC = TextEditingController();
  final noteC = TextEditingController();
  final timeC = TextEditingController();
  final dateC = TextEditingController();

  DateTime? selectedDate;
  String priority = "SEDANG";

  // --- INIT STATE: ISI DATA LAMA ---
  @override
  void initState() {
    super.initState();
    // Isi Text Controller dengan data lama
    titleC.text = widget.habit.title;
    noteC.text = widget.habit.note;
    timeC.text = widget.habit.time;

    // Isi Tanggal
    selectedDate = widget.habit.date;
    dateC.text =
        "${selectedDate!.day.toString().padLeft(2, '0')}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.year}";

    // Isi Prioritas
    if (widget.habit.priority == 0)
      priority = "RENDAH";
    else if (widget.habit.priority == 1)
      priority = "SEDANG";
    else
      priority = "TINGGI";
  }

  // --- FUNGSI PEMBERSIH TANGGAL ---
  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  Future<void> pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        selectedDate = _normalizeDate(picked);
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
    // Tidak perlu buka box lagi, karena kita edit objek langsung (HiveObject)

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Edit Jadwal",
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
                // UPDATE DATA DI OBJEK LANGSUNG
                widget.habit.title = titleC.text;
                widget.habit.note = noteC.text;
                widget.habit.date = selectedDate!;
                widget.habit.time = timeC.text;
                widget.habit.priority = priority == "RENDAH"
                    ? 0
                    : priority == "SEDANG"
                        ? 1
                        : 2;

                // SIMPAN PERUBAHAN KE HIVE
                await widget.habit.save();

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
            child: const Text("SIMPAN PERUBAHAN",
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
