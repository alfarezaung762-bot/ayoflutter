import 'package:flutter/material.dart';
import '../routes/app_routes.dart';

class SideMenuDrawer extends StatelessWidget {
  const SideMenuDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    // Cek apakah sedang Dark Mode
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    // Tentukan warna berdasarkan mode
    final Color bgColor = isDark ? const Color(0xFF1E1E2C) : Colors.white;
    final Color textColor = isDark ? Colors.white : Colors.black;
    final Color menuColor = isDark ? Colors.white70 : const Color(0xFF1A237E);

    return Drawer(
      backgroundColor: bgColor, // Warna dinamis
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
            Padding(
              padding: const EdgeInsets.only(left: 16, bottom: 20, top: 10),
              child: Text(
                "Mode List",
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: textColor, // Warna dinamis
                ),
              ),
            ),

            // === MENU ITEMS ===
            _menuItem(context, "Daily Repeat", AppRoutes.dailyHome, menuColor,
                textColor),
            _menuItem(context, "Tugas Bertanggal", AppRoutes.scheduled,
                menuColor, textColor),
            _menuItem(context, "Challenge Habit", AppRoutes.challenge,
                menuColor, textColor),
            _menuItem(context, "Video Tutorial", AppRoutes.tutorial, menuColor,
                textColor),
            _menuItem(context, "Pengaturan", AppRoutes.settings, menuColor,
                textColor),
          ],
        ),
      ),
    );
  }

  Widget _menuItem(BuildContext context, String title, String routeName,
      Color titleColor, Color iconColor) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      title: Text(
        title,
        style: TextStyle(
          color: titleColor, // Warna dinamis
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
      trailing: Icon(Icons.arrow_drop_down, color: iconColor), // Warna dinamis
      onTap: () {
        Navigator.pop(context); // Tutup drawer
        try {
          Navigator.pushReplacementNamed(context, routeName);
        } catch (e) {
          print("Route error: $e");
        }
      },
    );
  }
}
