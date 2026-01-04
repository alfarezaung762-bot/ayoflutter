import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:alarm/alarm.dart';
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

  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  String priority = "SEDANG";

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
        // [UI FIX] Tema Picker
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
      setState(() {
        selectedTime = picked;
        final formatted =
            "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}";
        timeC.text = formatted;
      });
    }
  }

  // [UI FIX] Helper Input Style
  InputDecoration _inputDecor(String hint, bool isDark) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.grey),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        // Border putih di dark mode
        borderSide: BorderSide(color: isDark ? Colors.white54 : Colors.grey),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFFFA726)),
      ),
      suffixIconColor: const Color(0xFFFFA726),
    );
  }

  // --- [FUNGSI BARU] POPUP SUKSES DI TENGAH ---
  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false, // User tidak bisa klik luar
      builder: (ctx) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: isDark ? const Color(0xFF2C2C3E) : Colors.white,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 60),
              const SizedBox(height: 16),
              Text(
                "Berhasil!",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style:
                    TextStyle(color: isDark ? Colors.white70 : Colors.black54),
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

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<ScheduledHabitModel>('scheduled_box');

    // [UI FIX] Deteksi Mode
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;

    return Scaffold(
      // [UI FIX] Background mengikuti tema
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

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
          Text("Judul Tugas",
              style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
          const SizedBox(height: 8),
          TextField(
            controller: titleC,
            style: TextStyle(color: textColor),
            decoration: _inputDecor("Contoh: Meeting Zoom", isDark),
          ),
          const SizedBox(height: 20),

          Text("Catatan",
              style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
          const SizedBox(height: 8),
          TextField(
            controller: noteC,
            maxLines: 2,
            style: TextStyle(color: textColor),
            decoration: _inputDecor("Detail tugas...", isDark),
          ),
          const SizedBox(height: 20),

          // TANGGAL & JAM
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Tanggal",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: textColor)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: dateC,
                      readOnly: true,
                      onTap: pickDate,
                      style: TextStyle(color: textColor),
                      decoration: _inputDecor("Pilih Tgl", isDark).copyWith(
                          suffixIcon: const Icon(Icons.calendar_today)),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Jam",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: textColor)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: timeC,
                      readOnly: true,
                      onTap: pickTime,
                      style: TextStyle(color: textColor),
                      decoration: _inputDecor("Pilih Jam", isDark)
                          .copyWith(suffixIcon: const Icon(Icons.access_time)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          Text("Prioritas",
              style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
          const SizedBox(height: 8),
          DropdownButtonFormField(
            value: priority,
            // [UI FIX] Background dropdown
            dropdownColor: isDark ? const Color(0xFF2C2C3E) : Colors.white,
            style: TextStyle(color: textColor),
            decoration: _inputDecor("", isDark),
            items: ["RENDAH", "SEDANG", "TINGGI"]
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: (v) => setState(() => priority = v!),
          ),

          const SizedBox(height: 40),

          // TOMBOL SIMPAN
          ElevatedButton(
            onPressed: () async {
              // 1. VALIDASI
              if (titleC.text.isEmpty ||
                  selectedDate == null ||
                  selectedTime == null) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text("Judul, Tanggal, dan Jam wajib diisi!"),
                    backgroundColor: Colors.red));
                return;
              }

              try {
                // 2. SIMPAN KE HIVE DULU (Agar dapat ID Unik)
                final newItem = ScheduledHabitModel(
                  title: titleC.text,
                  note: noteC.text,
                  date: selectedDate!,
                  time: timeC.text,
                  priority: priority == "RENDAH"
                      ? 0
                      : priority == "SEDANG"
                          ? 1
                          : 2,
                );

                final int idFromHive = await box.add(newItem);
                print("Data tersimpan dengan ID Hive: $idFromHive");

                // 3. GUNAKAN ID HIVE SEBAGAI ID ALARM
                final alarmId = idFromHive;

                // 4. KONFIGURASI ALARM
                final dateTimeAlarm = DateTime(
                  selectedDate!.year,
                  selectedDate!.month,
                  selectedDate!.day,
                  selectedTime!.hour,
                  selectedTime!.minute,
                  0,
                );

                if (dateTimeAlarm.isBefore(DateTime.now())) {
                  // Jika waktu lewat, tampilkan pesan error, tapi data tetap tersimpan
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content:
                          Text("Tugas disimpan, tapi waktu alarm sudah lewat."),
                      backgroundColor: Colors.orange));
                  if (context.mounted) Navigator.pop(context);
                  return;
                }

                final alarmSettings = AlarmSettings(
                  id: alarmId,
                  dateTime: dateTimeAlarm,
                  assetAudioPath: 'assets/alarm.mp3',
                  loopAudio: true,
                  vibrate: true,
                  androidFullScreenIntent: true,
                  androidStopAlarmOnTermination: false,

                  // Payload Navigasi
                  payload: 'scheduled',

                  volumeSettings: VolumeSettings.fixed(
                    volume: 1.0,
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

                await Alarm.set(alarmSettings: alarmSettings);
                print("Alarm sukses diset dengan ID: $alarmId");

                // 5. [POPUP SUKSES]
                if (mounted) {
                  // Memanggil fungsi dialog baru
                  _showSuccessDialog(
                      "Jadwal '${titleC.text}'\nberhasil disimpan!");
                }
                // (Navigator.pop sudah dihandle di dalam _showSuccessDialog)
              } catch (e) {
                print("Error: $e");
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text("Gagal: $e"), backgroundColor: Colors.red));
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFA726),
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
