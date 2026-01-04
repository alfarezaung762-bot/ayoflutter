import 'package:flutter/material.dart';
import 'package:alarm/alarm.dart';
import '../../models/scheduled_habit_model.dart';

class EditScheduledPage extends StatefulWidget {
  final ScheduledHabitModel habit;

  const EditScheduledPage({super.key, required this.habit});

  @override
  State<EditScheduledPage> createState() => _EditScheduledPageState();
}

class _EditScheduledPageState extends State<EditScheduledPage> {
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
    // Isi data lama
    titleC.text = widget.habit.title;
    noteC.text = widget.habit.note;
    timeC.text = widget.habit.time;

    selectedDate = widget.habit.date;
    dateC.text =
        "${selectedDate!.day.toString().padLeft(2, '0')}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.year}";

    try {
      final parts = widget.habit.time.split(':');
      selectedTime =
          TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    } catch (e) {
      selectedTime = TimeOfDay.now();
    }

    if (widget.habit.priority == 0)
      priority = "RENDAH";
    else if (widget.habit.priority == 1)
      priority = "SEDANG";
    else
      priority = "TINGGI";
  }

  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  Future<void> pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
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
      initialTime: selectedTime ?? TimeOfDay.now(),
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
    // [UI FIX] Deteksi Mode
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;

    return Scaffold(
      // [UI FIX] Background
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      appBar: AppBar(
        title: const Text("Edit Jadwal",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFFFFA726),
        iconTheme: const IconThemeData(color: Colors.white),
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
            decoration: _inputDecor("Judul", isDark),
          ),
          const SizedBox(height: 16),
          Text("Catatan",
              style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
          const SizedBox(height: 8),
          TextField(
            controller: noteC,
            maxLines: 2,
            style: TextStyle(color: textColor),
            decoration: _inputDecor("Catatan", isDark),
          ),
          const SizedBox(height: 16),
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
                      decoration: _inputDecor("", isDark).copyWith(
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
                      decoration: _inputDecor("", isDark)
                          .copyWith(suffixIcon: const Icon(Icons.access_time)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text("Prioritas",
              style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
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
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () async {
              if (titleC.text.isEmpty ||
                  selectedDate == null ||
                  selectedTime == null) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text("Judul, Tanggal, dan Jam wajib diisi!")));
                return;
              }

              try {
                // 1. UPDATE DATABASE
                widget.habit.title = titleC.text;
                widget.habit.note = noteC.text;
                widget.habit.date = selectedDate!;
                widget.habit.time = timeC.text;
                widget.habit.priority = priority == "RENDAH"
                    ? 0
                    : priority == "SEDANG"
                        ? 1
                        : 2;

                await widget.habit.save();

                // 2. UPDATE ALARM (PENTING!)
                // Kita gunakan key dari Hive object sebagai ID Alarm agar konsisten
                // (Asumsi key adalah int, jika bukan cast ke int yang aman)
                final alarmId = widget.habit.key as int;

                // Stop alarm lama dulu biar bersih
                await Alarm.stop(alarmId);

                // Set Alarm Baru
                final dateTimeAlarm = DateTime(
                    selectedDate!.year,
                    selectedDate!.month,
                    selectedDate!.day,
                    selectedTime!.hour,
                    selectedTime!.minute);

                if (dateTimeAlarm.isAfter(DateTime.now())) {
                  final alarmSettings = AlarmSettings(
                    id: alarmId,
                    dateTime: dateTimeAlarm,
                    assetAudioPath: 'assets/alarm.mp3',
                    loopAudio: true,
                    vibrate: true,
                    androidFullScreenIntent: true,
                    androidStopAlarmOnTermination: false,

                    // [PENTING] Payload agar navigasi benar
                    payload: 'scheduled',

                    volumeSettings: VolumeSettings.fixed(
                      volume: 1.0,
                      volumeEnforced: true,
                    ),
                    notificationSettings: NotificationSettings(
                      title: "Jadwal: ${titleC.text}",
                      body: noteC.text.isEmpty
                          ? "Waktunya jadwalmu!"
                          : noteC.text,
                      stopButton: 'Selesai',
                      icon: 'notification_icon',
                    ),
                  );
                  await Alarm.set(alarmSettings: alarmSettings);
                  print("Alarm Updated ID: $alarmId");
                }

                if (context.mounted) Navigator.pop(context);
              } catch (e) {
                print("Error: $e");
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFA726),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
            ),
            child: const Text("SIMPAN PERUBAHAN",
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
