import 'package:flutter/material.dart';
import '../../widgets/side_menu_drawer.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: const Color(0xFFF7F7F7),
      drawer: const SideMenuDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            _header(scaffoldKey, "Pengaturan", "Sesuaikan aplikasimu"),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: const [
                  ListTile(
                    leading: Icon(Icons.person),
                    title: Text("Akun Saya"),
                  ),
                  Divider(),
                  ListTile(
                    leading: Icon(Icons.notifications),
                    title: Text("Notifikasi"),
                  ),
                  Divider(),
                  ListTile(
                    leading: Icon(Icons.color_lens),
                    title: Text("Tema Aplikasi"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header(GlobalKey<ScaffoldState> key, String title, String subtitle) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 34),
      decoration: const BoxDecoration(
        color: Color(0xFFFFA726),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => key.currentState?.openDrawer(),
                icon: const Icon(Icons.menu, color: Colors.white, size: 28),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(
              subtitle,
              style: const TextStyle(color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }
}
