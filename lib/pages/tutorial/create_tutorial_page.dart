import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../../models/tutorial_model.dart';

class CreateTutorialPage extends StatefulWidget {
  const CreateTutorialPage({super.key});

  @override
  State<CreateTutorialPage> createState() => _CreateTutorialPageState();
}

class _CreateTutorialPageState extends State<CreateTutorialPage> {
  final titleC = TextEditingController();
  final descC = TextEditingController();
  final urlC = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<TutorialModel>('tutorial_box');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Tambah Video Baru",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFFFFA726),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // JUDUL
          const Text("Judul Video",
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(
            controller: titleC,
            decoration: InputDecoration(
              hintText: "Misal: Cara Mengatur Waktu",
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 20),

          // DESKRIPSI
          const Text("Penjelasan Singkat",
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(
            controller: descC,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: "Video ini membahas tentang...",
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 20),

          // URL VIDEO
          const Text("Link YouTube",
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(
            controller: urlC,
            decoration: InputDecoration(
              hintText: "https://youtube.com/watch?v=...",
              prefixIcon: const Icon(Icons.link, color: Colors.orange),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 40),

          // TOMBOL SIMPAN
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () async {
                if (titleC.text.isEmpty || urlC.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("Judul dan Link wajib diisi!")),
                  );
                  return;
                }

                await box.add(TutorialModel(
                  title: titleC.text,
                  description: descC.text,
                  videoUrl: urlC.text,
                ));

                if (context.mounted) Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFA726),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
              ),
              child: const Text("SIMPAN VIDEO",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}
