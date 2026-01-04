import 'package:alarm/alarm.dart';
import 'package:flutter/material.dart';

// Import kedua halaman tujuan
import '../daily/daily_home_page.dart';
import '../scheduled/scheduled_page.dart'; // Pastikan path ini benar

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
                    // A. Matikan alarm saat ini
                    await Alarm.stop(alarmSettings.id);

                    // B. Set waktu baru (5 menit lagi)
                    final now = DateTime.now();
                    final newTime = now.add(const Duration(minutes: 5));

                    // C. Buat alarm baru (Copy settings lama termasuk payload)
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

                    // D. Jadwalkan ulang
                    await Alarm.set(alarmSettings: newAlarmSettings);

                    // E. Tutup halaman
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
                // 2. TOMBOL KERJAKAN (STOP & NAVIGASI)
                // ==========================
                ElevatedButton(
                  onPressed: () async {
                    // A. Matikan alarm
                    await Alarm.stop(alarmSettings.id);

                    // B. LOGIKA NAVIGASI BERDASARKAN PAYLOAD
                    if (context.mounted) {
                      // Cek Payload yang kita titipkan tadi
                      if (alarmSettings.payload == 'scheduled') {
                        // Jika Scheduled Habit -> Ke Halaman Jadwal
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ScheduledPage(),
                          ),
                        );
                      } else {
                        // Default / Daily -> Ke Halaman Daily Home
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const DailyHomePage(),
                          ),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFA726),
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
