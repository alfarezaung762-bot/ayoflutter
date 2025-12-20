import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'dart:math'; // Import untuk Random Color
import '../../models/challenge_model.dart';

class CreateChallengePage extends StatefulWidget {
  const CreateChallengePage({super.key});

  @override
  State<CreateChallengePage> createState() => _CreateChallengePageState();
}

class _CreateChallengePageState extends State<CreateChallengePage> {
  final titleC = TextEditingController();
  final task1C = TextEditingController();
  final task2C = TextEditingController();
  int duration = 7;

  // List warna-warna cerah untuk challenge baru agar terlihat menarik di daftar
  final List<int> _colors = [
    0xFF4CAF50, // Green
    0xFF2196F3, // Blue
    0xFF9C27B0, // Purple
    0xFFFF9800, // Orange
    0xFFE91E63, // Pink
    0xFF009688, // Teal
  ];

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<ChallengeModel>('challenge_box');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Buat Challenge Baru",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFFFFA726),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text("Nama Challenge",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          TextField(
              controller: titleC,
              decoration: InputDecoration(
                hintText: "Contoh: Lari Sore",
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              )),
          const SizedBox(height: 24),
          const Text("Durasi (Hari)",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          Row(
            children: [
              Expanded(
                child: Slider(
                  value: duration.toDouble(),
                  min: 3,
                  max: 30,
                  divisions: 27,
                  label: "$duration Hari",
                  activeColor: Colors.orange,
                  onChanged: (val) => setState(() => duration = val.toInt()),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text("$duration Hari",
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.orange)),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text("Tugas Harian 1 (Wajib)",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          TextField(
              controller: task1C,
              decoration: InputDecoration(
                hintText: "Contoh: Lari 15 menit",
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              )),
          const SizedBox(height: 16),
          const Text("Tugas Harian 2 (Opsional)",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          TextField(
              controller: task2C,
              decoration: InputDecoration(
                hintText: "Contoh: Minum air putih",
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              )),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: () {
              if (titleC.text.isEmpty || task1C.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text("Judul dan Tugas 1 harus diisi!")));
                return;
              }

              List<String> tasks = [task1C.text];
              if (task2C.text.isNotEmpty) tasks.add(task2C.text);

              // Pilih warna acak dari daftar agar tampilan kartu bervariasi
              int randomColor = _colors[Random().nextInt(_colors.length)];

              // Simpan ke Hive
              box.add(ChallengeModel(
                title: titleC.text,
                description: "Tantangan Pribadi",
                durationDays: duration,
                colorCode: randomColor,
                dailyTasks: tasks,
                isJoined:
                    false, // <--- UBAH JADI FALSE (Agar masuk ke 'All Challenges' dulu)
                progressDay: 0, // <--- UBAH JADI 0 (Karena belum dimulai)
              ));

              Navigator.pop(context); // Kembali ke halaman utama Challenge
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            child: const Text("SIMPAN KE DAFTAR",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 16)),
          )
        ],
      ),
    );
  }
}
