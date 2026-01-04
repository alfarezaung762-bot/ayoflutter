import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../widgets/side_menu_drawer.dart'; // [PENTING] Import Drawer

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // [BARU] Key untuk membuka Drawer secara manual
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final Box settingsBox = Hive.box('settings');
  bool _isNotificationOn = true;

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = settingsBox.get('isDarkMode', defaultValue: false);

    return Scaffold(
      key: _scaffoldKey, // [PENTING] Pasang Key

      // [PENTING] Pasang Drawer di sini agar menu samping tersedia
      drawer: const SideMenuDrawer(),

      appBar: AppBar(
        title: const Text(
          "Pengaturan",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFFFA726),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,

        // [PENTING] Ganti tombol Back default dengan tombol Menu
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
      ),
      body: ListView(
        children: [
          _sectionHeader("Akun Saya", isDarkMode),
          ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.grey.shade300,
              radius: 24,
              child: const Icon(Icons.person, color: Colors.grey, size: 30),
            ),
            title: const Text("Pengguna Ayo",
                style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text("user@example.com"),
            trailing: IconButton(
              icon: const Icon(Icons.edit, color: Colors.orange),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text("Fitur Edit Profil segera hadir!")),
                );
              },
            ),
          ),
          _divider(),
          _sectionHeader("Umum", isDarkMode),
          SwitchListTile(
            title: const Text("Notifikasi",
                style: TextStyle(fontWeight: FontWeight.w500)),
            secondary:
                const Icon(Icons.notifications_active, color: Colors.orange),
            value: _isNotificationOn,
            activeColor: Colors.orange,
            onChanged: (val) {
              setState(() => _isNotificationOn = val);
            },
          ),
          SwitchListTile(
            title: const Text("Mode Gelap",
                style: TextStyle(fontWeight: FontWeight.w500)),
            secondary: const Icon(Icons.dark_mode, color: Colors.orange),
            value: isDarkMode,
            activeColor: Colors.orange,
            onChanged: (val) {
              settingsBox.put('isDarkMode', val);
              setState(() {});
            },
          ),
          _divider(),
          _sectionHeader("Alarm", isDarkMode),
          ListTile(
            leading: const Icon(Icons.music_note, color: Colors.orange),
            title: const Text("Nada Dering Alarm",
                style: TextStyle(fontWeight: FontWeight.w500)),
            subtitle: const Text("Default (alarm.mp3)"),
            trailing: const Icon(Icons.arrow_forward_ios,
                size: 16, color: Colors.grey),
            onTap: _showRingtoneDialog,
          ),
          _divider(),
          _sectionHeader("Lainnya", isDarkMode),
          ListTile(
            leading: const Icon(Icons.favorite, color: Colors.redAccent),
            title: const Text("Donasi",
                style: TextStyle(fontWeight: FontWeight.w500)),
            trailing: const Icon(Icons.arrow_forward_ios,
                size: 16, color: Colors.grey),
            onTap: () {
              _launchURL('https://saweria.co/yourname');
            },
          ),
          ListTile(
            leading: const Icon(Icons.email, color: Colors.blueAccent),
            title: const Text("Kontak Email",
                style: TextStyle(fontWeight: FontWeight.w500)),
            trailing: const Icon(Icons.arrow_forward_ios,
                size: 16, color: Colors.grey),
            onTap: () {
              _launchURL(
                  'mailto:support@ayoapp.com?subject=Tanya%20Tentang%20Ayo');
            },
          ),
          const SizedBox(height: 30),
          Center(
            child: Text(
              "Versi 1.0.0",
              style: TextStyle(color: Colors.grey.shade400),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  // --- WIDGET HELPER ---

  Widget _sectionHeader(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: isDark ? Colors.orangeAccent : Colors.grey.shade600,
          fontWeight: FontWeight.bold,
          fontSize: 13,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _divider() {
    return Divider(
        height: 1,
        thickness: 0.5,
        indent: 16,
        endIndent: 16,
        color: Colors.grey.withOpacity(0.3));
  }

  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        throw 'Could not launch $url';
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal membuka link: $e")),
        );
      }
    }
  }

  void _showRingtoneDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Pilih Nada Dering"),
        content: const Text("Saat ini hanya tersedia nada dering Default."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Tutup", style: TextStyle(color: Colors.orange)),
          ),
        ],
      ),
    );
  }
}
