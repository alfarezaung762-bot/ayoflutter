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
    // Isi form dengan data lama
    titleC.text = widget.habit.title;
    noteC.text = widget.habit.note;
    timeC.text = widget.habit.time;

    // Set dropdown sesuai data lama
    if (widget.habit.priority == 0) {
      priority = "RENDAH";
    } else if (widget.habit.priority == 1) {
      priority = "SEDANG";
    } else {
      priority = "TINGGI";
    }
  }

  // Fungsi Time Picker
  Future<void> pickTime() async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        // [UI FIX] Tema Picker agar tetap terang dan terbaca
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFFFA726),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final formatted =
          "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}";
      setState(() {
        timeC.text = formatted;
      });
    }
  }

  // [UI FIX] Helper Input Style agar terlihat di Dark Mode
  InputDecoration _inputDecor(String hint, bool isDark) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.grey),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        // Garis putih di dark mode, abu di light mode
        borderSide: BorderSide(color: isDark ? Colors.white54 : Colors.grey),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFFFA726)),
      ),
      suffixIconColor: const Color(0xFFFFA726),
    );
  }

  @override
  Widget build(BuildContext context) {
    // [UI FIX] Deteksi Mode Gelap
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;

    return Scaffold(
      // [UI FIX] Background mengikuti tema
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      appBar: AppBar(
        title: const Text("EDIT TUGAS",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFFFFA726),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header Container dihilangkan agar lebih bersih (sudah ada di AppBar)

          Text("Tugas",
              style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
          const SizedBox(height: 8),
          TextField(
            controller: titleC,
            style: TextStyle(color: textColor), // Teks input warna dinamis
            decoration: _inputDecor("Nama tugas", isDark),
          ),

          const SizedBox(height: 16),

          Text("Catatan",
              style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
          const SizedBox(height: 8),
          TextField(
            controller: noteC,
            maxLines: 3,
            style: TextStyle(color: textColor),
            decoration: _inputDecor("Catatan tambahan", isDark),
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Waktu",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: textColor)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: timeC,
                      readOnly: true,
                      onTap: pickTime,
                      style: TextStyle(color: textColor),
                      decoration: _inputDecor("Pilih Jam", isDark).copyWith(
                        suffixIcon: const Icon(Icons.access_time),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Prioritas",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: textColor)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField(
                      value: priority,
                      // [UI FIX] Warna dropdown menu saat dibuka
                      dropdownColor:
                          isDark ? const Color(0xFF2C2C3E) : Colors.white,
                      style: TextStyle(color: textColor),
                      decoration: _inputDecor("", isDark),
                      items: ["RENDAH", "SEDANG", "TINGGI"]
                          .map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                      onChanged: (v) => setState(() => priority = v!),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // ====== BUTTON SIMPAN ======
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

              // TODO: Jika ingin alarm juga terupdate,
              // Anda perlu memanggil ulang logika Alarm.set() di sini seperti di halaman create.
              // Tapi untuk sekarang, kode ini hanya mengupdate data di database.

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
              "SIMPAN PERUBAHAN",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
