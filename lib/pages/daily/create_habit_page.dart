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

  // --- [FUNGSI BARU] DIALOG SUKSES DI TENGAH ---
  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false, // User tidak bisa klik luar untuk tutup
      builder: (ctx) {
        // Cek mode untuk warna background dialog
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: isDark ? const Color(0xFF2C2C3E) : Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
          content: Column(
            mainAxisSize: MainAxisSize.min, // Ukuran menyesuaikan konten
            children: [
              const Icon(Icons.check_circle,
                  color: Colors.green, size: 70), // Ukuran ikon diperbesar
              const SizedBox(height: 20),
              Text(
                "Berhasil!",
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87),
              ),
              const SizedBox(height: 10),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 16,
                    color: isDark ? Colors.white70 : Colors.black54),
              ),
            ],
          ),
        );
      },
    );

    // Timer: Tutup Dialog & Halaman setelah 1.5 detik
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        Navigator.of(context).pop(); // Tutup Dialog
        Navigator.of(context).pop(); // Kembali ke Halaman Sebelumnya
      }
    });
  }

  // --- HELPER UI: INPUT STYLE ---
  InputDecoration _inputDecor(String hint, bool isDark) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.grey),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        // Border putih di dark mode, abu di light mode
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

    // [UI] Deteksi Mode Gelap
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;

    return Scaffold(
      // [UI] Background mengikuti tema
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
          Text("Tugas",
              style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
          const SizedBox(height: 8),
          TextField(
            controller: titleC,
            style: TextStyle(color: textColor), // Warna teks input dinamis
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
                      // [UI] Dropdown background dinamis
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

          // ====== TOMBOL SIMPAN ======
          ElevatedButton(
            onPressed: () async {
              // 1. VALIDASI
              if (titleC.text.isEmpty || timeC.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Harap isi Judul dan Waktu tugas!"),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              // 2. LOGIKA ALARM
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

              // Jika waktu sudah lewat hari ini, set untuk besok
              if (selectedDateTime.isBefore(now)) {
                selectedDateTime =
                    selectedDateTime.add(const Duration(days: 1));
              }

              // ID Unik (Offset + 5000000 agar beda dari Scheduled)
              final alarmId =
                  (DateTime.now().millisecondsSinceEpoch % 1000000) + 5000000;

              final alarmSettings = AlarmSettings(
                id: alarmId,
                dateTime: selectedDateTime,
                assetAudioPath: 'assets/alarm.mp3',
                loopAudio: true,
                vibrate: true,
                androidFullScreenIntent: true,
                androidStopAlarmOnTermination: false,

                // Payload untuk navigasi
                payload: 'daily',

                volumeSettings: VolumeSettings.fixed(
                  volume: null,
                  volumeEnforced: true,
                ),
                notificationSettings: NotificationSettings(
                  // Pastikan judul diambil dari text controller
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

              // 3. SIMPAN KE HIVE
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

              // 4. [POPUP SUKSES]
              if (mounted) {
                // Memanggil fungsi dialog yang baru kita buat
                _showSuccessDialog("Tugas '${titleC.text}'\nberhasil dibuat!");
              }

              // NOTE: Kita tidak pakai Navigator.pop disini lagi,
              // karena sudah dihandle otomatis oleh timer di dalam _showSuccessDialog
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
