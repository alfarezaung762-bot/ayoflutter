import 'package:flutter/material.dart';
import '../routes/app_routes.dart';

class SideMenuDrawer extends StatelessWidget {
  const SideMenuDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Deteksi Mode Gelap
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // 2. Palette Warna Dinamis
    final backgroundColor = isDark ? const Color(0xFF1E1E2C) : Colors.white;
    final textPrimary = isDark ? Colors.white : const Color(0xFF2D3436);

    // [FIX] Tambahkan '!' di belakang Colors.grey[600]! agar tidak dianggap null
    final textSecondary = isDark ? Colors.white54 : Colors.grey[600]!;

    final accentColor = const Color(0xFFFFA726); // Warna Orange
    final iconColor = isDark ? Colors.white70 : const Color(0xFFFFA726);

    return Drawer(
      backgroundColor: backgroundColor,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(0),
          bottomRight: Radius.circular(0),
        ),
      ),
      child: Column(
        children: [
          // === HEADER BAGIAN ATAS ===
          _buildHeader(
              context, isDark, textPrimary, textSecondary, accentColor),

          // === DAFTAR MENU ===
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              children: [
                _menuItem(
                  context: context,
                  title: "Daily Repeat",
                  icon: Icons.repeat_rounded,
                  routeName: AppRoutes.dailyHome,
                  textColor: textPrimary,
                  iconColor: iconColor,
                ),
                _menuItem(
                  context: context,
                  title: "Tugas Bertanggal",
                  icon: Icons.calendar_month_rounded,
                  routeName: AppRoutes.scheduled,
                  textColor: textPrimary,
                  iconColor: iconColor,
                ),
                _menuItem(
                  context: context,
                  title: "Challenge Habit",
                  icon: Icons.emoji_events_rounded,
                  routeName: AppRoutes.challenge,
                  textColor: textPrimary,
                  iconColor: iconColor,
                ),
                _menuItem(
                  context: context,
                  title: "Video Tutorial",
                  icon: Icons.play_circle_outline_rounded,
                  routeName: AppRoutes.tutorial,
                  textColor: textPrimary,
                  iconColor: iconColor,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Divider(
                      color: isDark ? Colors.white12 : Colors.grey[200]),
                ),
                _menuItem(
                  context: context,
                  title: "Pengaturan",
                  icon: Icons.settings_rounded,
                  routeName: AppRoutes.settings,
                  textColor: textPrimary,
                  iconColor: isDark ? Colors.grey : Colors.grey[600]!,
                ),
              ],
            ),
          ),

          // === FOOTER ===
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text(
              "Versi 1.0.0",
              style: TextStyle(
                color: textSecondary,
                fontSize: 12,
                letterSpacing: 1.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget Header Custom
  Widget _buildHeader(BuildContext context, bool isDark, Color titleColor,
      Color subtitleColor, Color accent) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
      decoration: BoxDecoration(
        color:
            isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFFFF8E1),
        border: Border(
          bottom: BorderSide(
            color: isDark ? Colors.transparent : Colors.orange.withOpacity(0.1),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: accent.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.check_circle_outline, color: accent, size: 32),
          ),
          const SizedBox(height: 16),
          Text(
            "AYO PRODUCTIVE",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
              color: titleColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Kelola harimu lebih baik",
            style: TextStyle(
              fontSize: 14,
              color: subtitleColor,
            ),
          ),
        ],
      ),
    );
  }

  // Widget Menu Item
  Widget _menuItem({
    required BuildContext context,
    required String title,
    required IconData icon,
    required String routeName,
    required Color textColor,
    required Color iconColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onTap: () {
          Navigator.pop(context);
          try {
            Navigator.pushReplacementNamed(context, routeName);
          } catch (e) {
            debugPrint("Route error: $e");
          }
        },
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
        trailing: Icon(Icons.arrow_forward_ios_rounded,
            size: 14, color: textColor.withOpacity(0.3)),
      ),
    );
  }
}
