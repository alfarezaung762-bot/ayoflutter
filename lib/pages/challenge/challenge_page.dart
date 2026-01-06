import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:alarm/alarm.dart';
import '../../models/challenge_model.dart';
import '../../widgets/side_menu_drawer.dart';
import 'challenge_detail_page.dart';
import 'create_challenge_page.dart';

class ChallengePage extends StatefulWidget {
  const ChallengePage({super.key});

  @override
  State<ChallengePage> createState() => _ChallengePageState();
}

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
        reminderTime: "06:00",
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
        reminderTime: "21:00",
      ));
    }
  }

  // --- LOGIKA JOIN & START ALARM (PERBAIKAN UTAMA) ---
  Future<void> _joinChallenge(ChallengeModel challenge) async {
    // 1. SET ALARM (Hanya jika ada reminderTime)
    if (challenge.reminderTime != null && challenge.reminderTime!.isNotEmpty) {
      try {
        // Parse jam dari string "HH:mm"
        final parts = challenge.reminderTime!.split(':');
        final int hour = int.parse(parts[0]);
        final int minute = int.parse(parts[1]);

        final now = DateTime.now();
        // Buat jadwal untuk hari ini dulu
        DateTime scheduleTime =
            DateTime(now.year, now.month, now.day, hour, minute);

        // LOGIKA PINTAR: Jika jam sudah lewat hari ini, mulai alarm BESOK
        if (scheduleTime.isBefore(now)) {
          scheduleTime = scheduleTime.add(const Duration(days: 1));
        }

        // Pastikan punya ID Alarm (buat baru jika null)
        final int alarmId =
            challenge.alarmId ?? DateTime.now().millisecondsSinceEpoch % 100000;
        challenge.alarmId =
            alarmId; // Simpan ID ke model agar bisa dihapus nanti

        // Setting Alarm
        final alarmSettings = AlarmSettings(
          id: alarmId,
          dateTime: scheduleTime,
          assetAudioPath: 'assets/alarm.mp3',
          loopAudio: true,
          vibrate: true,
          volumeSettings:
              VolumeSettings.fixed(volume: null, volumeEnforced: true),
          notificationSettings: NotificationSettings(
            title: "Challenge: ${challenge.title}",
            body: "Waktunya mengerjakan tugas harianmu!",
            stopButton: null,
            icon: 'notification_icon',
          ),
          payload: 'challenge', // Payload agar sistem tahu ini alarm challenge
        );

        await Alarm.set(alarmSettings: alarmSettings);
        debugPrint("Alarm Challenge dimulai untuk: $scheduleTime");
      } catch (e) {
        debugPrint("Gagal set alarm challenge: $e");
      }
    }

    // 2. UPDATE STATUS JOIN DI DATABASE
    challenge.isJoined = true;
    challenge.startDate = DateTime.now();
    challenge.progressDay = 1;
    challenge.save();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Berhasil bergabung: ${challenge.title}!")),
      );
    }
  }

  Future<void> _deleteChallenge(ChallengeModel challenge) async {
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
      if (challenge.alarmId != null) {
        await Alarm.stop(challenge.alarmId!);
      }
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
                // --- SECTION 1: ACTIVE ---
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
                    height: 220,
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: myChallenges.length,
                      padEnds: false,
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (context, index) {
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
                            padding: const EdgeInsets.only(left: 20, right: 5),
                            child: _activeChallengeCard(
                                context, myChallenges[index]),
                          ),
                        );
                      },
                    ),
                  ),

                const SizedBox(height: 30),

                // --- SECTION 2: DISCOVER ---
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

  // --- KARTU AKTIF ---
  Widget _activeChallengeCard(BuildContext context, ChallengeModel c) {
    int pastDays = (c.progressDay - 1).clamp(0, c.durationDays);
    int tasksDoneToday = c.todayTaskStatus.where((done) => done).length;
    int totalTasks = c.dailyTasks.length;
    double todayContribution =
        totalTasks == 0 ? 0 : (tasksDoneToday / totalTasks);
    double progressPercent = (pastDays + todayContribution) / c.durationDays;
    progressPercent = progressPercent.clamp(0.0, 1.0);

    return GestureDetector(
      onTap: () {
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
            Positioned(
              right: -20,
              top: -20,
              child: CircleAvatar(
                  radius: 60, backgroundColor: Colors.white.withOpacity(0.1)),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
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
                      GestureDetector(
                        onTap: () => _deleteChallenge(c),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.2),
                              shape: BoxShape.circle),
                          child: const Icon(Icons.delete_outline,
                              color: Colors.white70, size: 20),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (c.reminderTime != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Row(
                            children: [
                              const Icon(Icons.alarm,
                                  size: 14, color: Colors.white70),
                              const SizedBox(width: 4),
                              Text(
                                "Reminder: ${c.reminderTime}",
                                style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
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

  // --- KARTU REKOMENDASI (FIX OVERFLOW) ---
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

          // [FIX] Menggunakan Expanded + Wrap agar teks tidak overflow
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
                // Gunakan Wrap di sini
                Wrap(
                  spacing: 6, // Jarak horizontal
                  runSpacing: 2, // Jarak vertikal jika turun baris
                  children: [
                    Text(
                      "${c.durationDays} hari",
                      style: TextStyle(
                          color: isDark ? Colors.white54 : Colors.grey,
                          fontSize: 12),
                    ),
                    Text(
                      "• ${c.dailyTasks.length} tugas",
                      style: TextStyle(
                          color: isDark ? Colors.white54 : Colors.grey,
                          fontSize: 12),
                    ),
                    if (c.reminderTime != null)
                      Text("• ⏰ ${c.reminderTime}",
                          style: TextStyle(
                              color: isDark ? Colors.white54 : Colors.grey,
                              fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Tombol Aksi
          Row(
            children: [
              IconButton(
                onPressed: () => _deleteChallenge(c),
                icon: Icon(Icons.delete_outline,
                    color: Colors.grey.shade400, size: 20),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => _joinChallenge(c),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isDark ? Colors.white10 : const Color(0xFFFFF3E0),
                  foregroundColor: Colors.orange,
                  elevation: 0,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("GABUNG",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
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
