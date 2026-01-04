import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:alarm/alarm.dart'; // Import untuk stop alarm saat delete
import '../../models/challenge_model.dart';
import '../../widgets/side_menu_drawer.dart';
import 'challenge_detail_page.dart';
import 'create_challenge_page.dart';

class ChallengePage extends StatefulWidget {
  const ChallengePage({super.key});

  @override
  State<ChallengePage> createState() => _ChallengePageState();
}

// Custom scroll behavior agar bisa geser pakai mouse di web/desktop
class MyCustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      };
}

class _ChallengePageState extends State<ChallengePage> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  late Box<ChallengeModel> box;
  late PageController _pageController;
  double _currentPage = 0.0;

  @override
  void initState() {
    super.initState();
    box = Hive.box<ChallengeModel>('challenge_box');

    // Seed default challenge jika kosong (opsional, bisa dihapus jika ingin kosong)
    _seedDefaultChallenges();

    _pageController = PageController(viewportFraction: 0.90, initialPage: 0);
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page!;
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Isi data awal jika baru install
  void _seedDefaultChallenges() {
    if (box.isEmpty) {
      box.add(ChallengeModel(
        title: "Happy Morning",
        description: "Bangun pagi dan produktif!",
        durationDays: 7,
        colorCode: 0xFF5C6BC0,
        dailyTasks: ["Minum air", "Meditasi 5 menit", "Rapikan kasur"],
        isJoined: false,
        todayTaskStatus: [false, false, false],
      ));
      box.add(ChallengeModel(
        title: "Detox Sosmed",
        description: "Kurangi layar, perbanyak hidup.",
        durationDays: 14,
        colorCode: 0xFF263238,
        dailyTasks: [
          "Matikan notifikasi",
          "Baca buku 10 hal",
          "Hp mati jam 9 malam"
        ],
        isJoined: false,
        todayTaskStatus: [false, false, false],
      ));
    }
  }

  // --- LOGIKA JOIN ---
  void _joinChallenge(ChallengeModel challenge) {
    challenge.isJoined = true;
    challenge.startDate = DateTime.now(); // Set tanggal mulai hari ini
    challenge.progressDay = 1; // Hari pertama
    challenge.save(); // Update Hive

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Berhasil bergabung: ${challenge.title}!")),
    );
  }

  // --- LOGIKA HAPUS (DELETE) ---
  Future<void> _deleteChallenge(ChallengeModel challenge) async {
    // 1. Konfirmasi User
    final bool? confirm = await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Hapus Challenge?"),
        content:
            const Text("Challenge dan alarm terkait akan dihapus permanen."),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text("Batal")),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text("Hapus", style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      // 2. Matikan Alarm jika ada
      if (challenge.alarmId != null) {
        await Alarm.stop(challenge.alarmId!);
      }

      // 3. Hapus dari Database
      await challenge.delete();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Challenge dihapus.")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    final textColor = isDark ? Colors.white : Colors.black87;

    return ScrollConfiguration(
      behavior: MyCustomScrollBehavior(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: bgColor,
        drawer: const SideMenuDrawer(),

        // APP BAR CUSTOM
        appBar: AppBar(
          backgroundColor: const Color(0xFFFFA726),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => scaffoldKey.currentState?.openDrawer(),
          ),
          title: const Text("Challenges",
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          centerTitle: true,
        ),

        // FAB UNTUK TAMBAH BARU
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const CreateChallengePage()));
          },
          backgroundColor: const Color(0xFFFFA726),
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text("Buat Baru",
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        ),

        // BODY LISTVIEW
        body: ValueListenableBuilder(
          valueListenable: box.listenable(),
          builder: (context, Box<ChallengeModel> box, _) {
            final allChallenges = box.values.toList();
            final myChallenges =
                allChallenges.where((c) => c.isJoined).toList();
            final discoverChallenges =
                allChallenges.where((c) => !c.isJoined).toList();

            return ListView(
              padding: const EdgeInsets.only(top: 20, bottom: 100),
              children: [
                // --- SECTION 1: ACTIVE CHALLENGES (SLIDER) ---
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Row(
                    children: [
                      Icon(Icons.local_fire_department_rounded,
                          color: Colors.orange, size: 24),
                      const SizedBox(width: 8),
                      Text("Sedang Berjalan",
                          style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 18,
                              color: textColor)),
                    ],
                  ),
                ),

                if (myChallenges.isEmpty)
                  _emptyState(isDark,
                      "Belum ada challenge aktif.\nAyo pilih satu di bawah!")
                else
                  SizedBox(
                    height: 220, // Tinggi kartu
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: myChallenges.length,
                      padEnds: false,
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (context, index) {
                        // Efek Scale Animasi
                        double scale = 1.0;
                        if (_currentPage >= index - 1 &&
                            _currentPage <= index + 1) {
                          scale = 1.0 - ((_currentPage - index).abs() * 0.05);
                        } else {
                          scale = 0.95;
                        }

                        return Transform.scale(
                          scale: scale,
                          child: Padding(
                            padding: const EdgeInsets.only(
                                left: 20, right: 5), // Spasi antar kartu
                            child: _activeChallengeCard(
                                context, myChallenges[index]),
                          ),
                        );
                      },
                    ),
                  ),

                const SizedBox(height: 30),

                // --- SECTION 2: DISCOVER (VERTICAL LIST) ---
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Row(
                    children: [
                      Icon(Icons.explore_rounded,
                          color: Colors.blueAccent, size: 24),
                      const SizedBox(width: 8),
                      Text("Temukan Challenge",
                          style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 18,
                              color: textColor)),
                    ],
                  ),
                ),

                if (discoverChallenges.isEmpty)
                  _emptyState(isDark,
                      "Semua challenge sudah diambil!\nBuat challenge baru yuk.")
                else
                  ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: discoverChallenges.length,
                    itemBuilder: (context, index) {
                      return _recommendationCard(
                          context, discoverChallenges[index], isDark);
                    },
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  // --- WIDGET KARTU AKTIF (SLIDER) ---
  Widget _activeChallengeCard(BuildContext context, ChallengeModel c) {
    // [FIX] RUMUS BARU: Menyamakan dengan Logic di Detail Page
    // 1. Hari yang sudah lewat
    int pastDays = (c.progressDay - 1).clamp(0, c.durationDays);

    // 2. Kontribusi tugas hari ini
    int tasksDoneToday = c.todayTaskStatus.where((done) => done).length;
    int totalTasks = c.dailyTasks.length;
    double todayContribution =
        totalTasks == 0 ? 0 : (tasksDoneToday / totalTasks);

    // 3. Gabungkan
    double progressPercent = (pastDays + todayContribution) / c.durationDays;

    // Clamp agar tidak lebih dari 1.0 (100%)
    progressPercent = progressPercent.clamp(0.0, 1.0);

    return GestureDetector(
      onTap: () {
        // Navigasi ke Detail Page (Tahap 4)
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => ChallengeDetailPage(challenge: c)));
      },
      child: Container(
        decoration: BoxDecoration(
          color: Color(c.colorCode),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Color(c.colorCode).withOpacity(0.4),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Hiasan Background (Lingkaran Transparan)
            Positioned(
              right: -20,
              top: -20,
              child: CircleAvatar(
                radius: 60,
                backgroundColor: Colors.white.withOpacity(0.1),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Header Kartu (Judul & Tombol Hapus)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          c.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              height: 1.2),
                        ),
                      ),
                      // Tombol Hapus Kecil
                      GestureDetector(
                        onTap: () => _deleteChallenge(c),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.delete_outline,
                              color: Colors.white70, size: 20),
                        ),
                      ),
                    ],
                  ),

                  // Info Progress
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Day ${c.progressDay} of ${c.durationDays}",
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600)),
                          Text("${(progressPercent * 100).toInt()}%",
                              style: const TextStyle(color: Colors.white70)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Progress Bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: progressPercent,
                          minHeight: 6,
                          backgroundColor: Colors.black.withOpacity(0.2),
                          valueColor:
                              const AlwaysStoppedAnimation(Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET KARTU REKOMENDASI (LIST VERTIKAL) ---
  Widget _recommendationCard(
      BuildContext context, ChallengeModel c, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2C3E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border:
            Border.all(color: isDark ? Colors.white10 : Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          // Ikon Warna Kiri
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Color(c.colorCode).withOpacity(0.15),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(Icons.emoji_events_rounded,
                color: Color(c.colorCode), size: 28),
          ),

          const SizedBox(width: 16),

          // Teks Tengah
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  c.title,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isDark ? Colors.white : Colors.black87),
                ),
                const SizedBox(height: 4),
                Text(
                  "${c.durationDays} hari • ${c.dailyTasks.length} tugas/hari",
                  style: TextStyle(
                      color: isDark ? Colors.white54 : Colors.grey,
                      fontSize: 12),
                ),
              ],
            ),
          ),

          // Tombol Aksi (Join & Delete)
          Row(
            children: [
              // Tombol Hapus (Kecil)
              IconButton(
                onPressed: () => _deleteChallenge(c),
                icon: Icon(Icons.delete_outline,
                    color: Colors.grey.shade400, size: 20),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 12),
              // Tombol Join
              ElevatedButton(
                onPressed: () => _joinChallenge(c),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isDark ? Colors.white10 : const Color(0xFFFFF3E0),
                  foregroundColor: Colors.orange,
                  elevation: 0,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("GABUNG",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _emptyState(bool isDark, String message) {
    return Container(
      padding: const EdgeInsets.all(30),
      alignment: Alignment.center,
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: TextStyle(color: isDark ? Colors.white38 : Colors.grey),
      ),
    );
  }
}
