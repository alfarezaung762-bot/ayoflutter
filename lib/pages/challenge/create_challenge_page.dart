import 'dart:math';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:alarm/alarm.dart'; // Import Alarm
import '../../models/challenge_model.dart';

class CreateChallengePage extends StatefulWidget {
  const CreateChallengePage({super.key});

  @override
  State<CreateChallengePage> createState() => _CreateChallengePageState();
}

class _CreateChallengePageState extends State<CreateChallengePage> {
  final titleC = TextEditingController();
  final noteC = TextEditingController(); // Description

  // List Controller untuk tugas (Dinamis)
  List<TextEditingController> taskControllers = [TextEditingController()];

  int duration = 7; // Default 7 hari
  TimeOfDay? selectedTime; // Untuk Alarm

  // Warna-warna preset
  final List<int> _colors = [
    0xFF4CAF50,
    0xFF2196F3,
    0xFF9C27B0,
    0xFFFF9800,
    0xFFE91E63,
    0xFF009688,
  ];

  // Fungsi Tambah Input Tugas
  void _addTaskField() {
    if (taskControllers.length < 5) {
      setState(() {
        taskControllers.add(TextEditingController());
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Maksimal 5 tugas harian!")));
    }
  }

  // Fungsi Hapus Input Tugas
  void _removeTaskField(int index) {
    if (taskControllers.length > 1) {
      setState(() {
        taskControllers.removeAt(index);
      });
    }
  }

  // Fungsi Pilih Jam Alarm
  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFFFA726),
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => selectedTime = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Buat Challenge",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFFFFA726),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // 1. NAMA CHALLENGE
          _buildLabel("Nama Challenge"),
          TextField(
            controller: titleC,
            style: TextStyle(color: textColor),
            decoration: _inputDecor("Contoh: 75 Hard", isDark),
          ),

          const SizedBox(height: 20),

          // 2. DESKRIPSI SINGKAT
          _buildLabel("Deskripsi / Motivasi"),
          TextField(
            controller: noteC,
            style: TextStyle(color: textColor),
            decoration: _inputDecor("Contoh: Disiplin pangkal kaya!", isDark),
          ),

          const SizedBox(height: 20),

          // 3. DURASI (PILIHAN CHIP)
          _buildLabel("Durasi Tantangan"),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [7, 14, 21, 30, 90].map((days) {
                final isSelected = duration == days;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text("$days Hari"),
                    selected: isSelected,
                    onSelected: (val) => setState(() => duration = days),
                    selectedColor: const Color(0xFFFFA726),
                    labelStyle: TextStyle(
                        color: isSelected ? Colors.white : textColor,
                        fontWeight: FontWeight.bold),
                    backgroundColor: isDark ? Colors.white10 : Colors.grey[200],
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    showCheckmark: false,
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 24),

          // 4. DAFTAR TUGAS HARIAN (DINAMIS)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildLabel("Tugas Harian (${taskControllers.length}/5)"),
              if (taskControllers.length < 5)
                TextButton.icon(
                  onPressed: _addTaskField,
                  icon: const Icon(Icons.add_circle, color: Color(0xFFFFA726)),
                  label: const Text("Tambah",
                      style: TextStyle(color: Color(0xFFFFA726))),
                )
            ],
          ),
          ...List.generate(taskControllers.length, (index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: taskControllers[index],
                      style: TextStyle(color: textColor),
                      decoration: _inputDecor("Tugas ke-${index + 1}", isDark),
                    ),
                  ),
                  if (taskControllers.length > 1)
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline,
                          color: Colors.red),
                      onPressed: () => _removeTaskField(index),
                    )
                ],
              ),
            );
          }),

          const SizedBox(height: 20),

          // 5. REMINDER (ALARM)
          _buildLabel("Ingatkan Saya Setiap Hari"),
          const SizedBox(height: 8),
          InkWell(
            onTap: _pickTime,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border:
                    Border.all(color: isDark ? Colors.white54 : Colors.grey),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.alarm,
                      color: selectedTime != null
                          ? const Color(0xFFFFA726)
                          : Colors.grey),
                  const SizedBox(width: 12),
                  Text(
                    selectedTime != null
                        ? "${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}"
                        : "Atur Jam Reminder (Opsional)",
                    style: TextStyle(
                        color: selectedTime != null
                            ? (isDark ? Colors.white : Colors.black)
                            : Colors.grey,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 40),

          // TOMBOL SIMPAN
          ElevatedButton(
            onPressed: _saveChallenge,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFA726),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
            ),
            child: const Text("BUAT TANTANGAN",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // --- LOGIKA SIMPAN ---
  Future<void> _saveChallenge() async {
    // Validasi
    if (titleC.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Nama Challenge wajib diisi!")));
      return;
    }
    // Filter tugas yang kosong
    List<String> validTasks = [];
    for (var c in taskControllers) {
      if (c.text.trim().isNotEmpty) validTasks.add(c.text.trim());
    }
    if (validTasks.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Minimal harus ada 1 tugas harian!")));
      return;
    }

    final box = Hive.box<ChallengeModel>('challenge_box');
    int randomColor = _colors[Random().nextInt(_colors.length)];

    // Generate Alarm ID jika user set waktu
    int? alarmId;
    String? timeString;
    if (selectedTime != null) {
      alarmId = DateTime.now().millisecondsSinceEpoch % 100000;
      timeString = "${selectedTime!.hour}:${selectedTime!.minute}";

      // LOGIKA SET ALARM (Package Alarm)
      final now = DateTime.now();
      DateTime dt = DateTime(now.year, now.month, now.day, selectedTime!.hour,
          selectedTime!.minute);
      if (dt.isBefore(now)) dt = dt.add(const Duration(days: 1));

      final alarmSettings = AlarmSettings(
        id: alarmId,
        dateTime: dt,
        assetAudioPath: 'assets/alarm.mp3',
        loopAudio: true,
        vibrate: true,
        androidFullScreenIntent: true,
        // [FIX] Menambahkan volumeSettings yang wajib ada
        volumeSettings: VolumeSettings.fixed(
          volume: null,
          volumeEnforced: true,
        ),
        notificationSettings: NotificationSettings(
          title: "Challenge: ${titleC.text}",
          body: "Jangan lupa kerjakan tugas challenge kamu!",
          stopButton: null, // Sesuai strategi kita sebelumnya
          icon: 'notification_icon',
        ),
        payload:
            'challenge', // Payload agar bisa dinavigasi ke halaman challenge nanti
      );
      await Alarm.set(alarmSettings: alarmSettings);
    }

    // Simpan ke Hive
    final newChallenge = ChallengeModel(
      title: titleC.text,
      description: noteC.text.isEmpty ? "Semangat!" : noteC.text,
      durationDays: duration,
      colorCode: randomColor,
      dailyTasks: validTasks,
      isJoined: false, // Masuk ke list 'All Challenges' dulu
      progressDay: 0,
      todayTaskStatus:
          List.filled(validTasks.length, false), // Checkbox awal false semua
      reminderTime: timeString,
      alarmId: alarmId,
    );

    await box.add(newChallenge);

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Challenge berhasil dibuat!")));
    }
  }

  // Helper UI
  Widget _buildLabel(String text) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Text(text,
        style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: isDark ? Colors.white70 : Colors.black87));
  }

  InputDecoration _inputDecor(String hint, bool isDark) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.grey),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
            BorderSide(color: isDark ? Colors.white24 : Colors.grey.shade400),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFFFA726)),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}
