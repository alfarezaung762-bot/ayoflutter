import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:alarm/alarm.dart';
// [WAJIB] Tambahkan import ini untuk menggantikan Alarm.getNotificationPermission
import 'package:permission_handler/permission_handler.dart';
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

  @override
  void initState() {
    super.initState();
    // Cek izin saat halaman dibuka
    checkAndroidNotificationPermission();
  }

  // [PERBAIKAN] Menggunakan Permission Handler
  Future<void> checkAndroidNotificationPermission() async {
    final status = await Permission.notification.status;
    if (status.isDenied) {
      print("Meminta izin notifikasi...");
      await Permission.notification.request();
    }
  }

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

  InputDecoration _inputDecor(String hint, bool isDark) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.grey),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: isDark ? Colors.white54 : Colors.grey),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFFFA726)),
      ),
      suffixIconColor: const Color(0xFFFFA726),
    );
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
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

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        Navigator.of(context).pop();
        Navigator.of(context).pop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<ScheduledHabitModel>('scheduled_box');
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;

    return Scaffold(
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
            dropdownColor: isDark ? const Color(0xFF2C2C3E) : Colors.white,
            style: TextStyle(color: textColor),
            decoration: _inputDecor("", isDark),
            items: ["RENDAH", "SEDANG", "TINGGI"]
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: (v) => setState(() => priority = v!),
          ),

          const SizedBox(height: 40),

          // --- TOMBOL SIMPAN ---
          ElevatedButton(
            onPressed: () async {
              if (titleC.text.isEmpty ||
                  selectedDate == null ||
                  selectedTime == null) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text("Judul, Tanggal, dan Jam wajib diisi!"),
                    backgroundColor: Colors.red));
                return;
              }

              // Variabel untuk menyimpan ID sementara
              int? idFromHive;

              try {
                // 1. Simpan ke Hive
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

                idFromHive = await box.add(newItem);
                print("Data tersimpan di Hive ID: $idFromHive");

                // 2. Cek Waktu Alarm
                final dateTimeAlarm = DateTime(
                  selectedDate!.year,
                  selectedDate!.month,
                  selectedDate!.day,
                  selectedTime!.hour,
                  selectedTime!.minute,
                  0,
                );

                if (dateTimeAlarm.isBefore(DateTime.now())) {
                  // Rollback: Hapus data Hive jika waktu salah
                  await box.delete(idFromHive);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content:
                          Text("Waktu sudah lewat! Pilih waktu masa depan."),
                      backgroundColor: Colors.orange));
                  return;
                }

                // 3. Set Alarm
                final alarmSettings = AlarmSettings(
                  id: idFromHive,
                  dateTime: dateTimeAlarm,
                  assetAudioPath: 'assets/alarm.mp3',
                  loopAudio: true,
                  vibrate: true,
                  androidFullScreenIntent: true,
                  androidStopAlarmOnTermination: false,
                  payload: 'scheduled',
                  volumeSettings: VolumeSettings.fixed(
                    volume: null,
                    volumeEnforced: true,
                  ),
                  notificationSettings: NotificationSettings(
                    title: "Jadwal: ${titleC.text}",
                    body: noteC.text.isEmpty
                        ? "Ketuk untuk mematikan"
                        : "${noteC.text}\n(Ketuk untuk mematikan)",
                    stopButton: 'MATIKAN', // Saya biarkan sesuai request
                    icon: 'notification_icon',
                  ),
                );

                await Alarm.set(alarmSettings: alarmSettings);

                if (mounted) {
                  _showSuccessDialog(
                      "Jadwal '${titleC.text}'\nberhasil disimpan!");
                }
              } catch (e) {
                // Rollback
                if (idFromHive != null) {
                  await box.delete(idFromHive);
                }
                print("Error Alarm: $e");
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text("Gagal menyimpan jadwal. Coba lagi."),
                    backgroundColor: Colors.red));
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
