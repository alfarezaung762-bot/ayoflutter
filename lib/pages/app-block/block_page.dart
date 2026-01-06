// File: lib/pages/app-block/block_page.dart

import 'package:flutter/material.dart';

class BlockPage extends StatefulWidget {
  const BlockPage({super.key});

  @override
  State<BlockPage> createState() => _BlockPageState();
}

class _BlockPageState extends State<BlockPage> {
  // [Placeholder] List aplikasi yang diblokir (Nanti bisa diganti data real)
  final List<Map<String, dynamic>> _blockedApps = [
    {'name': 'Instagram', 'icon': Icons.camera_alt, 'isBlocked': true},
    {'name': 'TikTok', 'icon': Icons.music_note, 'isBlocked': true},
    {'name': 'YouTube', 'icon': Icons.play_circle_fill, 'isBlocked': false},
    {'name': 'Facebook', 'icon': Icons.facebook, 'isBlocked': false},
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    final textColor = isDark ? Colors.white : Colors.black87;
    final cardColor = isDark ? Theme.of(context).cardColor : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFA726),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "App Blocker",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Header Info
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFFFA726),
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                const Icon(Icons.shield, size: 48, color: Colors.white),
                const SizedBox(height: 10),
                const Text(
                  "Fokus Mode Aktif",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  "Aplikasi yang dipilih tidak bisa dibuka sampai tugas harian selesai.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Judul List
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Icon(Icons.apps, color: textColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  "Daftar Aplikasi",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // List Aplikasi
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _blockedApps.length,
              itemBuilder: (context, index) {
                final app = _blockedApps[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        app['icon'] as IconData,
                        color: Colors.orange,
                      ),
                    ),
                    title: Text(
                      app['name'] as String,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    subtitle: Text(
                      app['isBlocked'] ? "Sedang Diblokir" : "Diizinkan",
                      style: TextStyle(
                        fontSize: 12,
                        color: app['isBlocked'] ? Colors.red : Colors.green,
                      ),
                    ),
                    trailing: Switch(
                      value: app['isBlocked'] as bool,
                      activeColor: Colors.orange,
                      onChanged: (val) {
                        setState(() {
                          app['isBlocked'] = val;
                        });
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
