import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../../models/habit_model.dart';
import 'package:alarm/alarm.dart';

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

  Future<void> pickTime() async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        // Tema Picker agar tetap terang dan terbaca
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

  // [HELPER UI] Input Style Dinamis
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
    final box = Hive.box<HabitModel>('habits');

    // [UI FIX] Deteksi Mode
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;

    return Scaffold(
      // [UI FIX] Background mengikuti tema
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      appBar: AppBar(
        title: const Text("Buat Tugas Harian",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFFFFA726),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header "BUAT TUGAS" dihapus karena sudah ada di AppBar
          // Agar tampilan lebih bersih

          Text("Tugas",
              style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
          const SizedBox(height: 8),
          TextField(
            controller: titleC,
            style: TextStyle(color: textColor), // Warna teks input
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
                      // [UI FIX] Dropdown menu warna
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

          ElevatedButton(
            onPressed: () async {
              if (titleC.text.isEmpty || timeC.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Harap isi Judul dan Waktu tugas!"),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              // LOGIKA ALARM (SAMA SEPERTI KODEMU)
              final now = DateTime.now();
              final timeParts = timeC.text.split(':');
              final hour = int.parse(timeParts[0]);
              final minute = int.parse(timeParts[1]);

              var selectedDateTime = DateTime(
                now.year,
                now.month,
                now.day,
                hour,
                minute,
              );

              if (selectedDateTime.isBefore(now)) {
                selectedDateTime =
                    selectedDateTime.add(const Duration(days: 1));
              }

              // ID Unik (Offset + 5000 agar beda dari Scheduled)
              final alarmId =
                  (DateTime.now().millisecondsSinceEpoch % 1000000) + 5000;

              final alarmSettings = AlarmSettings(
                id: alarmId,
                dateTime: selectedDateTime,
                assetAudioPath: 'assets/alarm.mp3',
                loopAudio: true,
                vibrate: true,
                androidFullScreenIntent: true,
                androidStopAlarmOnTermination: false,

                payload: 'daily', // Navigasi Benar

                volumeSettings: VolumeSettings.fixed(
                  volume: null,
                  volumeEnforced: true,
                ),
                notificationSettings: NotificationSettings(
                  title: titleC.text,
                  body: noteC.text.isEmpty
                      ? "Waktunya mengerjakan tugas!"
                      : noteC.text,
                  stopButton: 'Tunda / Kerjakan',
                  icon: 'notification_icon',
                ),
              );

              await Alarm.set(alarmSettings: alarmSettings);
              print("Alarm Daily berhasil diset ID: $alarmId");

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

              if (mounted) Navigator.pop(context);
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
    );
  }
}
