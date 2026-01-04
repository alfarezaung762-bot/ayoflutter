import 'package:alarm/alarm.dart';
import 'package:flutter/material.dart';

// Import semua halaman tujuan
import '../daily/daily_home_page.dart';
import '../scheduled/scheduled_page.dart';
// [BARU] Import Challenge Page agar bisa diarahkan kesana
import '../challenge/challenge_page.dart';

class AlarmRingPage extends StatelessWidget {
  final AlarmSettings alarmSettings;

  const AlarmRingPage({super.key, required this.alarmSettings});

  @override
  Widget build(BuildContext context) {
    // 1. Deteksi Mode Gelap
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // 2. Warna Dinamis
    final backgroundColor = isDark ? const Color(0xFF1E1E2C) : Colors.white;
    final titleColor = isDark ? Colors.white : Colors.black87;
    final bodyColor = isDark ? Colors.white70 : Colors.grey[700];
    final accentColor = const Color(0xFFFFA726); // Orange

    // [LOGIKA UI] Cek apakah body berisi instruksi sistem (KETUK DISINI)?
    // Jika ya, kita sembunyikan text itu di layar ini agar rapi.
    final String bodyText = alarmSettings.notificationSettings.body;
    final bool isSystemInstruction =
        bodyText.contains("KETUK DISINI") || bodyText.contains("Ketuk untuk");

    return Scaffold(
      backgroundColor: backgroundColor,
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
                      letterSpacing: 2.5,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.orangeAccent : Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Text(
                    alarmSettings.notificationSettings.title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: titleColor,
                      height: 1.2,
                    ),
                  ),

                  // [UI FIX] Hanya tampilkan kotak teks jika BUKAN instruksi sistem
                  if (!isSystemInstruction) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white10 : Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        bodyText,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          color: bodyColor,
                        ),
                      ),
                    ),
                  ],
                ],
              ),

              // --- BAGIAN TENGAH: IKON BERDENYUT ---
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 220,
                    height: 220,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: accentColor.withOpacity(0.1),
                    ),
                  ),
                  Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: accentColor.withOpacity(0.2),
                    ),
                  ),
                  Icon(
                    Icons.alarm,
                    size: 80,
                    color: accentColor,
                  ),
                ],
              ),

              // --- BAGIAN BAWAH: TOMBOL AKSI ---
              Column(
                children: [
                  // TOMBOL KERJAKAN
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () async {
                        // 1. Matikan Alarm saat ini
                        await Alarm.stop(alarmSettings.id);

                        // 2. [LOGIKA BARU] Reschedule Alarm untuk BESOK
                        // Ini berlaku untuk 'daily' habit DAN 'challenge' habit
                        if (alarmSettings.payload == 'daily' ||
                            alarmSettings.payload == 'challenge') {
                          // Buat jadwal untuk besok di jam yang sama
                          final nextAlarmDateTime = alarmSettings.dateTime
                              .add(const Duration(days: 1));

                          final nextAlarm = alarmSettings.copyWith(
                            dateTime: nextAlarmDateTime,
                          );

                          await Alarm.set(alarmSettings: nextAlarm);
                          debugPrint(
                              "Alarm dijadwalkan ulang untuk besok: $nextAlarmDateTime");
                        }

                        // 3. Navigasi Pintar
                        if (context.mounted) {
                          if (alarmSettings.payload == 'scheduled') {
                            // Ke Halaman Scheduled
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const ScheduledPage()),
                              (route) => false,
                            );
                          } else if (alarmSettings.payload == 'challenge') {
                            // [BARU] Ke Halaman Challenge
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const ChallengePage()),
                              (route) => false,
                            );
                          } else {
                            // Default: Ke Daily Home
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const DailyHomePage()),
                              (route) => false,
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentColor,
                        foregroundColor: Colors.white,
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        shadowColor: accentColor.withOpacity(0.5),
                      ),
                      child: const Text(
                        "KERJAKAN SEKARANG",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // TOMBOL SNOOZE
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton(
                      onPressed: () async {
                        await Alarm.stop(alarmSettings.id);

                        // Set Alarm Baru 5 Menit Lagi
                        final now = DateTime.now();
                        final newTime = now.add(const Duration(minutes: 5));

                        final newAlarmSettings = alarmSettings.copyWith(
                          dateTime: newTime,
                          notificationSettings: NotificationSettings(
                            title: alarmSettings.notificationSettings.title,
                            body:
                                "Snooze: ${alarmSettings.notificationSettings.body}",
                            // Tetap gunakan settingan lama (null jika challenge)
                            stopButton:
                                alarmSettings.notificationSettings.stopButton,
                            icon: alarmSettings.notificationSettings.icon,
                          ),
                        );

                        await Alarm.set(alarmSettings: newAlarmSettings);

                        if (context.mounted) {
                          if (Navigator.canPop(context)) {
                            Navigator.pop(context);
                          } else {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const DailyHomePage()),
                            );
                          }
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor:
                            isDark ? Colors.white70 : Colors.grey[700],
                        side: BorderSide(
                          color: isDark ? Colors.white24 : Colors.grey.shade300,
                          width: 2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        "Tunda 5 Menit",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
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
