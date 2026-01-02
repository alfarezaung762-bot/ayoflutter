import 'package:alarm/alarm.dart';
import 'package:flutter/material.dart';

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

            // Gambar Lonceng (Emoji besar)
            const Text(
              "🔔",
              style: TextStyle(fontSize: 100),
            ),

            // Deskripsi Custom user
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
                // TOMBOL SNOOZE (Tunda)
                ElevatedButton(
                  onPressed: () {
                    // Nanti kita isi logika Snooze di sini
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 15),
                  ),
                  child: const Text(
                    "Snooze",
                    style: TextStyle(fontSize: 20),
                  ),
                ),

                // TOMBOL STOP (Kerjakan/Masuk App)
                ElevatedButton(
                  onPressed: () {
                    // Nanti kita isi logika Stop di sini
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 15),
                  ),
                  child: const Text(
                    "Kerjakan",
                    style: TextStyle(fontSize: 20),
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
