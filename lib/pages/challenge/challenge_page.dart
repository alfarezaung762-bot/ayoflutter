import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../models/challenge_model.dart';
import '../../widgets/side_menu_drawer.dart';
import 'challenge_detail_page.dart';
import 'create_challenge_page.dart';

class ChallengePage extends StatefulWidget {
  const ChallengePage({super.key});

  @override
  State<ChallengePage> createState() => _ChallengePageState();
}

// Custom scroll behavior agar bisa geser pakai mouse di web
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

    // ViewportFraction 0.85 agar kartu sebelah "mengintip"
    _pageController = PageController(viewportFraction: 0.85, initialPage: 0);
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
        title: "Happy Morning Challenge",
        description: "Wake up early and be productive!",
        durationDays: 7,
        colorCode: 0xFF5C6BC0,
        dailyTasks: ["Drink water", "Meditate for 5 mins", "Make the bed"],
        isJoined: false, // Default belum join
      ));
      box.add(ChallengeModel(
        title: "Social Media Detox",
        description: "Less screen time, more life time.",
        durationDays: 14,
        colorCode: 0xFF263238,
        dailyTasks: [
          "Turn off notifications",
          "Read book",
          "No phone before bed"
        ],
        isJoined: false, // Default belum join
      ));
    }
  }

  void _joinChallenge(ChallengeModel challenge) {
    challenge.isJoined = true;
    challenge.progressDay = 1;
    challenge.save();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Joined: ${challenge.title}!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: MyCustomScrollBehavior(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: const Color(0xFFF7F7F7), // Light Mode
        drawer: const SideMenuDrawer(),
        appBar: AppBar(
          backgroundColor: const Color(0xFFFFA726), // Tema Orange
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => scaffoldKey.currentState?.openDrawer(),
          ),
          title: const Text("Challenges",
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const CreateChallengePage()));
          },
          backgroundColor: const Color(0xFFFFA726),
          icon: const Icon(Icons.add),
          label: const Text("Buat Sendiri",
              style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        body: ValueListenableBuilder(
          valueListenable: box.listenable(),
          builder: (context, box, _) {
            final allChallenges = box.values.toList();
            // Filter: Tantangan yang sudah di-join masuk ke slider atas
            final myChallenges =
                allChallenges.where((c) => c.isJoined).toList();
            // Filter: Tantangan yang belum di-join (termasuk yang baru dibuat) masuk ke daftar bawah
            final discoverChallenges =
                allChallenges.where((c) => !c.isJoined).toList();

            return ListView(
              padding: const EdgeInsets.only(top: 16, bottom: 80),
              children: [
                // --- SECTION 1: YOUR CHALLENGES (SLIDER HORIZONTAL) ---
                if (myChallenges.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text("YOUR CHALLENGES",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black54,
                            letterSpacing: 1.2)),
                  ),
                  const SizedBox(height: 15),
                  SizedBox(
                    height: 200,
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: myChallenges.length,
                      padEnds: false,
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (context, index) {
                        // Efek skala agar kartu aktif terlihat lebih menonjol
                        double scale = 1.0;
                        if (_currentPage >= index - 1 &&
                            _currentPage <= index + 1) {
                          scale = 1.0 - ((_currentPage - index).abs() * 0.1);
                        } else {
                          scale = 0.9;
                        }

                        return Transform.scale(
                          scale: scale,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: _activeChallengeCard(
                                context, myChallenges[index]),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 25),
                ],

                // --- SECTION 2: ALL CHALLENGES (DAFTAR VERTIKAL) ---
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text("ALL CHALLENGES",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black54,
                          letterSpacing: 1.2)),
                ),
                const SizedBox(height: 15),
                if (discoverChallenges.isEmpty)
                  const Center(
                      child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Text("Belum ada tantangan baru",
                        style: TextStyle(color: Colors.grey)),
                  ))
                else
                  ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: discoverChallenges.length,
                    itemBuilder: (context, index) {
                      return _recommendationCard(discoverChallenges[index]);
                    },
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  // --- KARTU SLIDER (YOUR CHALLENGE) ---
  Widget _activeChallengeCard(BuildContext context, ChallengeModel c) {
    return GestureDetector(
      onTap: () {
        // Navigasi ke halaman DETAIL berbeda
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => ChallengeDetailPage(challenge: c)));
      },
      child: Container(
        decoration: BoxDecoration(
          color: Color(c.colorCode),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Color(c.colorCode).withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Dekorasi Ikon Matahari Transparan
            Positioned(
              right: -10,
              bottom: -10,
              child: Opacity(
                opacity: 0.15,
                child:
                    const Icon(Icons.wb_sunny, size: 140, color: Colors.white),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    c.title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                            color: Colors.white24, shape: BoxShape.circle),
                        child: const Icon(Icons.flash_on,
                            color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 10),
                      const Text("Active Progress",
                          style: TextStyle(color: Colors.white, fontSize: 15)),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- KARTU DAFTAR (ALL CHALLENGE) ---
  Widget _recommendationCard(ChallengeModel c) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(c.title,
                    style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 17,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text("${c.durationDays} days challenge",
                    style: const TextStyle(color: Colors.black54)),
                const SizedBox(height: 12),

                // TOMBOL JOIN UNTUK PINDAH KE ATAS
                ElevatedButton(
                  onPressed: () => _joinChallenge(c),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFF3E0),
                    foregroundColor: Colors.orange,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("JOIN CHALLENGE",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                )
              ],
            ),
          ),
          // Ikon pemanis
          Icon(Icons.emoji_events_outlined,
              size: 50, color: Color(c.colorCode).withOpacity(0.5)),
        ],
      ),
    );
  }
}
