import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../../models/habit_model.dart';
import 'package:alarm/alarm.dart'; // Pastikan import ini ada

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

            // ====== BUTTON BUAT TUGAS ======
            ElevatedButton(
              onPressed: () async {
                // [VALIDASI] Cek apakah Judul atau Waktu masih kosong?
                if (titleC.text.isEmpty || timeC.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Harap isi Judul dan Waktu tugas!"),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return; // Stop di sini, jangan lanjut ke bawah
                }

                // ===============================
                // 1. AMBIL WAKTU DARI TEXT FIELD
                // ===============================
                final now = DateTime.now();
                final timeParts = timeC.text.split(':');
                final hour = int.parse(timeParts[0]);
                final minute = int.parse(timeParts[1]);

                // ===============================
                // 2. BUAT DATETIME ALARM
                // ===============================
                var selectedDateTime = DateTime(
                  now.year,
                  now.month,
                  now.day,
                  hour,
                  minute,
                );

                // ===============================
                // 3. JIKA WAKTU SUDAH LEWAT → BESOK
                // ===============================
                if (selectedDateTime.isBefore(now)) {
                  selectedDateTime =
                      selectedDateTime.add(const Duration(days: 1));
                }

                // ===============================
                // 4. ID UNIK ALARM
                // ===============================
                final alarmId = DateTime.now().millisecondsSinceEpoch % 10000;

                // ===============================
                // 5. KONFIGURASI ALARM (DAILY)
                // ===============================

                // Catatan: Sesuai dokumentasi alarm 5.1.5, kita gunakan 'payload'
                final alarmSettings = AlarmSettings(
                  id: alarmId,
                  dateTime: selectedDateTime,
                  assetAudioPath:
                      'assets/alarm.mp3', // Pastikan file ini ada di assets
                  loopAudio: true,
                  vibrate: true,
                  androidFullScreenIntent: true,
                  androidStopAlarmOnTermination: false,

                  // [PERBAIKAN] Menggunakan 'payload' sesuai dokumentasi v5.1.5
                  payload: 'daily',

                  // Volume Settings
                  // Jika .fixed tidak dikenali, gunakan VolumeSettings(volume: null, fadeDuration: null, volumeEnforced: true)
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

                // ===============================
                // 6. SET ALARM
                // ===============================
                await Alarm.set(alarmSettings: alarmSettings);

                // ===============================
                // 7. SIMPAN KE HIVE
                // ===============================
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
      ),
    );
  }
}
