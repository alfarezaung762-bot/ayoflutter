import 'package:alarm/alarm.dart';
import 'package:flutter/material.dart';

// Import kedua halaman tujuan
import '../daily/daily_home_page.dart';
import '../scheduled/scheduled_page.dart';

class AlarmRingPage extends StatelessWidget {
  final AlarmSettings alarmSettings;

  const AlarmRingPage({super.key, required this.alarmSettings});

  @override
  Widget build(BuildContext context) {
    // [UI FIX] Deteksi Mode Gelap
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final bgColor = isDark ? const Color(0xFF1E1E2C) : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // --- BAGIAN ATAS: JUDUL ---
              Column(
                children: [
                  Text(
                    "ALARM BERBUNYI",
                    style: TextStyle(
                      fontSize: 16,
                      letterSpacing: 2.0,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.orangeAccent : Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    alarmSettings.notificationSettings.title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    alarmSettings.notificationSettings.body,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: isDark ? Colors.white70 : Colors.grey[700],
                    ),
                  ),
                ],
              ),

              // --- BAGIAN TENGAH: IKON ANIMASI ---
              // Kita buat efek berdenyut (Ripple) sederhana dengan Container
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.orange.withOpacity(0.1),
                    ),
                  ),
                  Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.orange.withOpacity(0.2),
                    ),
                  ),
                  const Icon(
                    Icons.alarm_on,
                    size: 80,
                    color: Colors.orange,
                  ),
                ],
              ),

              // --- BAGIAN BAWAH: TOMBOL AKSI ---
              Column(
                children: [
                  // TOMBOL KERJAKAN (UTAMA)
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () async {
                        // 1. Matikan Alarm
                        await Alarm.stop(alarmSettings.id);

                        // 2. Navigasi Pintar
                        if (context.mounted) {
                          if (alarmSettings.payload == 'scheduled') {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const ScheduledPage()),
                            );
                          } else {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const DailyHomePage()),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFA726),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 5,
                        shadowColor: Colors.orange.withOpacity(0.4),
                      ),
                      child: const Text(
                        "KERJAKAN SEKARANG",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // TOMBOL SNOOZE (SECONDARY)
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: OutlinedButton(
                      onPressed: () async {
                        await Alarm.stop(alarmSettings.id);

                        final now = DateTime.now();
                        final newTime = now.add(const Duration(minutes: 5));

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

                        await Alarm.set(alarmSettings: newAlarmSettings);

                        if (context.mounted) Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: isDark ? Colors.white30 : Colors.grey.shade300,
                          width: 2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        "Tunda 5 Menit",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white70 : Colors.grey[700],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
