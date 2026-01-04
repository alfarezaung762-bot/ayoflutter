import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:alarm/alarm.dart'; // Import Alarm
import '../../models/scheduled_habit_model.dart';

class CreateScheduledPage extends StatefulWidget {
  const CreateScheduledPage({super.key});

  @override
  State<CreateScheduledPage> createState() => _CreateScheduledPageState();
}

class _CreateScheduledPageState extends State<CreateScheduledPage> {
  final titleC = TextEditingController();
  final noteC = TextEditingController();
  final timeC = TextEditingController();
  final dateC = TextEditingController();

  DateTime? selectedDate; // Tanggal yang dipilih (Jamnya 00:00)
  TimeOfDay? selectedTime; // Jam yang dipilih
  String priority = "SEDANG";

  // --- FUNGSI PEMBERSIH TANGGAL ---
  // Memastikan jam, menit, detik jadi 0 agar bersih
  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  Future<void> pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFFFA726), // Orange
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
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
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFFFA726), // Orange
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        selectedTime = picked;
        final formatted =
            "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}";
        timeC.text = formatted;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<ScheduledHabitModel>('scheduled_box');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Buat Jadwal Baru",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFFFFA726),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text("Judul Tugas",
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(
            controller: titleC,
            decoration: InputDecoration(
              hintText: "Contoh: Meeting Zoom",
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFFFA726)),
              ),
            ),
          ),
          const SizedBox(height: 20),

          const Text("Catatan", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(
            controller: noteC,
            maxLines: 2,
            decoration: InputDecoration(
              hintText: "Detail tugas...",
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFFFA726)),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // TANGGAL & JAM
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Tanggal",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: dateC,
                      readOnly: true,
                      onTap: pickDate,
                      decoration: const InputDecoration(
                          hintText: "Pilih Tgl",
                          border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(12))),
                          suffixIcon: Icon(Icons.calendar_today,
                              color: Color(0xFFFFA726))),
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
                    const SizedBox(height: 8),
                    TextField(
                      controller: timeC,
                      readOnly: true,
                      onTap: pickTime,
                      decoration: const InputDecoration(
                          hintText: "Pilih Jam",
                          border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(12))),
                          suffixIcon: Icon(Icons.access_time,
                              color: Color(0xFFFFA726))),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          const Text("Prioritas",
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          DropdownButtonFormField(
            value: priority,
            decoration: const InputDecoration(
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12))),
            ),
            items: ["RENDAH", "SEDANG", "TINGGI"]
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: (v) => setState(() => priority = v!),
          ),

          const SizedBox(height: 40),

          // TOMBOL SIMPAN
          ElevatedButton(
            onPressed: () async {
              // 1. Validasi Input
              if (titleC.text.isEmpty ||
                  selectedDate == null ||
                  selectedTime == null) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text("Judul, Tanggal, dan Jam wajib diisi!"),
                    backgroundColor: Colors.red));
                return;
              }

              try {
                // 2. Gabungkan Tanggal & Jam Menjadi Satu Waktu Lengkap
                final dateTimeAlarm = DateTime(
                  selectedDate!.year,
                  selectedDate!.month,
                  selectedDate!.day,
                  selectedTime!.hour,
                  selectedTime!.minute,
                  0, // Detik 0 agar pas
                );

                // DEBUG PRINT: Cek di console apakah waktunya benar
                print("Mencoba set alarm untuk: $dateTimeAlarm");

                // 3. Cek apakah waktu sudah lewat?
                if (dateTimeAlarm.isBefore(DateTime.now())) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content:
                          Text("Waktu sudah lewat! Pilih waktu masa depan."),
                      backgroundColor: Colors.red));
                  return;
                }

                // 4. Siapkan ID Unik untuk Alarm
                // Menggunakan ID unik agar tidak bentrok dengan Daily Habit
                final alarmId = DateTime.now().millisecondsSinceEpoch % 100000;

                // 5. KONFIGURASI ALARM (SCHEDULED) - UPDATED
                final alarmSettings = AlarmSettings(
                  id: alarmId,
                  dateTime: dateTimeAlarm,
                  assetAudioPath: 'assets/alarm.mp3',
                  loopAudio: true,
                  vibrate: true,
                  androidFullScreenIntent: true,
                  androidStopAlarmOnTermination: false,

                  // [TAMBAHAN BARU] Penanda bahwa ini adalah Scheduled Habit
                  // Gunakan 'extraParameter' jika menggunakan package alarm v4+
                  // Jika package Anda custom/versi lama yang pakai 'payload', ubah 'extraParameter' jadi 'payload'
                  payload: 'scheduled',

                  volumeSettings: VolumeSettings.fixed(
                    volume: null,
                    volumeEnforced: true,
                  ),

                  notificationSettings: NotificationSettings(
                    title: "Jadwal: ${titleC.text}",
                    body:
                        noteC.text.isEmpty ? "Waktunya jadwalmu!" : noteC.text,
                    stopButton: 'Selesai',
                    icon: 'notification_icon',
                  ),
                );

                // 6. Eksekusi Set Alarm
                await Alarm.set(alarmSettings: alarmSettings);
                print("Alarm berhasil diset ID: $alarmId");

                // 7. Simpan ke Hive (Database Lokal)
                await box.add(ScheduledHabitModel(
                  title: titleC.text,
                  note: noteC.text,
                  date: selectedDate!,
                  time: timeC.text,
                  priority: priority == "RENDAH"
                      ? 0
                      : priority == "SEDANG"
                          ? 1
                          : 2,
                ));

                if (context.mounted) Navigator.pop(context);
              } catch (e) {
                print("Error setting alarm: $e");
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text("Gagal set alarm: $e"),
                    backgroundColor: Colors.red));
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFA726), // Orange
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
            ),
            child: const Text("SIMPAN JADWAL",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 16)),
          ),
        ],
      ),
    );
  }
}
