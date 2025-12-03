// lib/widgets/side_menu_drawer.dart

import 'package:flutter/material.dart';
import '../routes/app_routes.dart'; // Pastikan import routes kamu benar

class SideMenuDrawer extends StatelessWidget {
  const SideMenuDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white, // Background putih sesuai desain
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(0),
          bottomRight: Radius.circular(0),
        ),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
          children: [
            // === HEADER: MODE LIST ===
            const Padding(
              padding: EdgeInsets.only(left: 16, bottom: 20, top: 10),
              child: Text(
                "Mode List",
                style: TextStyle(
                  fontFamily: 'monospace', // Font agak kotak sesuai gambar
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),

            // === MENU ITEMS ===

            // 1. PERBAIKAN: Diarahkan ke dailyHome (Halaman Utama)
            _menuItem(context, "daily repeat", AppRoutes.dailyHome),

            _menuItem(context, "Tugas Bertanggal", AppRoutes.scheduled),

            _menuItem(context, "Challenge Habit", "/challenge"), // Placeholder
            _menuItem(context, "Video Tutorial", "/tutorial"), // Placeholder
            _menuItem(context, "Pengaturan", "/settings"), // Placeholder
          ],
        ),
      ),
    );
  }

  Widget _menuItem(BuildContext context, String title, String routeName) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      title: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF1A237E), // Warna biru tua/gelap mirip gambar
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
      trailing: const Icon(Icons.arrow_drop_down, color: Colors.black),
      onTap: () {
        // Tutup drawer dulu
        Navigator.pop(context);

        // Pindah halaman
        try {
          // 2. PERBAIKAN: Gunakan pushReplacementNamed agar halaman tidak menumpuk
          Navigator.pushReplacementNamed(context, routeName);
        } catch (e) {
          print("Route $routeName belum dibuat atau error: $e");
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Menu $title belum tersedia")));
        }
      },
    );
  }
}
