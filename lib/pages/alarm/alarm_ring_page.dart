import 'package:alarm/alarm.dart';
import 'package:flutter/material.dart';

// [PERBAIKAN 1] Gunakan jalur relatif (titik dua) agar pasti ketemu,
// tidak peduli apa nama package-nya.
import '../daily/daily_home_page.dart';

class AlarmRingPage extends StatelessWidget {
  final AlarmSettings alarmSettings;

  const AlarmRingPage({super.key, required this.alarmSettings});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Judul / Pesan
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "Alarm berbunyi!\n${alarmSettings.notificationSettings.title}",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // Gambar Lonceng
            const Text(
              "🔔",
              style: TextStyle(fontSize: 100),
            ),

            // Deskripsi
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "Kerjakan lalu masuk ke aplikasi\natau tunda 5 menit.",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.red),
              ),
            ),

            // Tombol Aksi
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // ==========================
                // 1. TOMBOL SNOOZE (TUNDA)
                // ==========================
                ElevatedButton(
                  onPressed: () async {
                    // A. Matikan alarm yang sedang bunyi sekarang
                    await Alarm.stop(alarmSettings.id);

                    // B. Atur waktu baru (5 menit dari sekarang)
                    final now = DateTime.now();
                    final newTime = now.add(const Duration(minutes: 5));

                    // C. [PERBAIKAN 2] Masukkan body ke dalam notificationSettings
                    final newAlarmSettings = alarmSettings.copyWith(
                      dateTime: newTime,
                      notificationSettings: NotificationSettings(
                        title: alarmSettings.notificationSettings.title,
                        body:
                            "Snooze: ${alarmSettings.notificationSettings.body}",
                        stopButton:
                            alarmSettings.notificationSettings.stopButton,
                        icon: alarmSettings.notificationSettings.icon,
                      ),
                    );

                    // D. Set alarm baru
                    await Alarm.set(alarmSettings: newAlarmSettings);

                    // E. Tutup halaman ini
                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade200,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 15),
                  ),
                  child: const Text(
                    "Snooze",
                    style: TextStyle(fontSize: 20, color: Colors.black87),
                  ),
                ),

                // ==========================
                // 2. TOMBOL KERJAKAN (STOP)
                // ==========================
                ElevatedButton(
                  onPressed: () async {
                    // A. Matikan alarm
                    await Alarm.stop(alarmSettings.id);

                    // B. Arahkan pengguna ke Halaman Utama (To Do List)
                    if (context.mounted) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DailyHomePage(),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFA726), // Warna Orange
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 15),
                  ),
                  child: const Text(
                    "Kerjakan",
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
