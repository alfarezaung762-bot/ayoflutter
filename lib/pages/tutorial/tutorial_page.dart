import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/tutorial_model.dart';
import '../../widgets/side_menu_drawer.dart';
import 'create_tutorial_page.dart';
import 'video_player_page.dart'; // 1. IMPORT HALAMAN PLAYER

class TutorialPage extends StatefulWidget {
  const TutorialPage({super.key});

  @override
  State<TutorialPage> createState() => _TutorialPageState();
}

class _TutorialPageState extends State<TutorialPage> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  late Box<TutorialModel> box;

  @override
  void initState() {
    super.initState();
    box = Hive.box<TutorialModel>('tutorial_box');
  }

  // --- FUNGSI BUKA YOUTUBE (APP LUAR) ---
  Future<void> _launchYoutube(String url) async {
    final Uri uri = Uri.parse(url);
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        throw Exception('Could not launch $url');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal membuka link: $e")),
        );
      }
    }
  }

  // --- POP UP PILIHAN TONTON ---
  void _showWatchOptions(BuildContext context, String url) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          height: 200,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Mau nonton di mana?",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // Opsi 1: Buka YouTube (Aplikasi Luar)
              ListTile(
                leading: const Icon(Icons.open_in_new, color: Colors.red),
                title: const Text("Buka di Aplikasi YouTube"),
                onTap: () {
                  Navigator.pop(context); // Tutup pop up
                  _launchYoutube(url); // Buka link
                },
              ),

              // Opsi 2: Tonton di sini (IN-APP PLAYER)
              ListTile(
                leading:
                    const Icon(Icons.play_circle_fill, color: Colors.orange),
                title: const Text("Putar di Aplikasi Ini"),
                onTap: () {
                  Navigator.pop(context); // Tutup pop up

                  // 2. NAVIGASI KE VIDEO PLAYER PAGE
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => VideoPlayerPage(videoUrl: url),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Fungsi Thumbnail
  String? getYoutubeThumbnail(String url) {
    RegExp regExp = RegExp(
      r"^.*((youtu.be\/)|(v\/)|(\/u\/\w\/)|(embed\/)|(watch\?))\??v?=?([^#&?]*).*",
      caseSensitive: false,
      multiLine: false,
    );
    final match = regExp.firstMatch(url);
    if (match != null && match.groupCount >= 7) {
      String id = match.group(7) ?? "";
      return "https://img.youtube.com/vi/$id/hqdefault.jpg";
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: const Color(0xFFF7F7F7),
      drawer: const SideMenuDrawer(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => const CreateTutorialPage()));
        },
        backgroundColor: Colors.orange,
        icon: const Icon(Icons.video_call),
        label: const Text("Tambah Video",
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _header(scaffoldKey),
            Expanded(
              child: ValueListenableBuilder(
                valueListenable: box.listenable(),
                builder: (context, box, _) {
                  if (box.isEmpty) {
                    return const Center(
                        child: Text("Belum ada video tutorial"));
                  }

                  final tutorials = box.values.toList();

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: tutorials.length,
                    itemBuilder: (context, index) {
                      final item = tutorials[index];
                      final thumbUrl = getYoutubeThumbnail(item.videoUrl);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 5))
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 1. THUMBNAIL (Bisa diklik juga)
                            GestureDetector(
                              onTap: () =>
                                  _showWatchOptions(context, item.videoUrl),
                              child: ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(16)),
                                child: thumbUrl != null
                                    ? Image.network(
                                        thumbUrl,
                                        width: double.infinity,
                                        height: 180,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error,
                                                stackTrace) =>
                                            Container(
                                                height: 180,
                                                color: Colors.grey.shade300,
                                                child: const Center(
                                                    child: Icon(
                                                        Icons.broken_image))),
                                      )
                                    : Container(
                                        height: 180,
                                        color: Colors.black,
                                        child: const Center(
                                            child: Icon(
                                                Icons.play_circle_outline,
                                                color: Colors.white,
                                                size: 50)),
                                      ),
                              ),
                            ),

                            // 2. INFO VIDEO
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.title,
                                    style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    item.description,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style:
                                        TextStyle(color: Colors.grey.shade600),
                                  ),
                                  const SizedBox(height: 12),

                                  // Tombol Aksi
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      TextButton.icon(
                                        onPressed: () => item.delete(),
                                        icon: const Icon(Icons.delete,
                                            color: Colors.red, size: 18),
                                        label: const Text("Hapus",
                                            style:
                                                TextStyle(color: Colors.red)),
                                      ),
                                      const SizedBox(width: 8),

                                      // TOMBOL TONTON -> MUNCUL POP UP
                                      ElevatedButton.icon(
                                        onPressed: () {
                                          _showWatchOptions(
                                              context, item.videoUrl);
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.orange,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20)),
                                        ),
                                        icon: const Icon(Icons.play_arrow,
                                            size: 18),
                                        label: const Text("Tonton"),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header(GlobalKey<ScaffoldState> key) {
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
              const Text("Video Tutorial",
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
            ],
          ),
          const SizedBox(height: 10),
          const Padding(
            padding: EdgeInsets.only(left: 4),
            child: Text("Pelajari cara produktif",
                style: TextStyle(color: Colors.white70)),
          ),
        ],
      ),
    );
  }
}
