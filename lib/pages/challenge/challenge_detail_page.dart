import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart'; // [WAJIB] Import untuk Scroll Behavior
import 'package:intl/intl.dart';
import '../../models/challenge_model.dart';

// [FIX 1] Tambahkan Class Behavior ini agar bisa discroll pakai Mouse/Touch lancar
// (Sama persis seperti di challenge_page.dart)
class MyCustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      };
}

class ChallengeDetailPage extends StatefulWidget {
  final ChallengeModel challenge;

  const ChallengeDetailPage({super.key, required this.challenge});

  @override
  State<ChallengeDetailPage> createState() => _ChallengeDetailPageState();
}

class _ChallengeDetailPageState extends State<ChallengeDetailPage> {
  late ChallengeModel c;
  // Controller untuk auto-scroll ke hari aktif
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    c = widget.challenge;
    _checkAndResetDaily();

    // [FIX 2] Auto-scroll ke hari ini setelah tampilan dirender
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToCurrentDay();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose(); // Jangan lupa dispose controller
    super.dispose();
  }

  void _scrollToCurrentDay() {
    if (_scrollController.hasClients) {
      // Lebar item (60) + Separator (10) = 70.0 pixel per hari
      // Kita scroll ke (Hari ini - 2) agar posisi hari aktif ada di tengah/kiri, bukan mepet ujung
      double targetOffset = (c.progressDay - 2) * 70.0;

      // Pastikan tidak minus
      if (targetOffset < 0) targetOffset = 0;

      // Pastikan tidak melebihi batas kanan (maxScrollExtent)
      if (targetOffset > _scrollController.position.maxScrollExtent) {
        targetOffset = _scrollController.position.maxScrollExtent;
      }

      _scrollController.animateTo(
        targetOffset,
        duration:
            const Duration(milliseconds: 800), // Durasi agak lambat biar smooth
        curve: Curves.easeOutQuart,
      );
    }
  }

  // --- LOGIKA CEK HARI ---
  void _checkAndResetDaily() {
    final now = DateTime.now();

    if (c.startDate == null) {
      c.startDate = now;
      c.progressDay = 1;
    }

    final difference = now.difference(c.startDate!).inDays;
    final currentDaySequence = difference + 1;

    // Update hari jika berbeda
    if (c.progressDay != currentDaySequence) {
      c.progressDay = currentDaySequence;
    }

    // Reset checklist jika ganti hari
    if (c.lastUpdated == null || !_isSameDay(c.lastUpdated!, now)) {
      c.todayTaskStatus = List.filled(c.dailyTasks.length, false);
      c.lastUpdated = now;
      c.save();
    }

    // Safety check array length
    if (c.todayTaskStatus.length != c.dailyTasks.length) {
      c.todayTaskStatus = List.filled(c.dailyTasks.length, false);
      c.save();
    }
  }

  bool _isSameDay(DateTime d1, DateTime d2) {
    return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
  }

  void _toggleTask(int index) {
    setState(() {
      c.todayTaskStatus[index] = !c.todayTaskStatus[index];
      c.save();
    });
  }

  // --- WIDGET KALENDER HORIZONTAL (FIXED UI) ---
  Widget _buildScrollableCalendar(bool isDark) {
    return SizedBox(
      height: 90,
      // ListView ini sekarang bisa digeser mouse berkat ScrollConfiguration di bawah
      child: ListView.separated(
        controller: _scrollController, // Pasang controller disini
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: c.durationDays,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final int dayNumber = index + 1; // Hari ke-1, 2, 3...
          final DateTime dateOfBox = c.startDate!.add(Duration(days: index));

          final bool isPast = dayNumber < c.progressDay;
          final bool isToday = dayNumber == c.progressDay;

          // Warna Kotak
          Color boxColor;
          Color textColor;
          Color borderColor;

          if (isToday) {
            boxColor = const Color(0xFFFFA726); // Orange aktif
            textColor = Colors.white;
            borderColor = Colors.orangeAccent;
          } else if (isPast) {
            boxColor = isDark ? Colors.white10 : Colors.green.withOpacity(0.1);
            textColor = isDark ? Colors.white38 : Colors.grey;
            borderColor = Colors.transparent;
          } else {
            // Masa depan
            boxColor = isDark ? const Color(0xFF2C2C3E) : Colors.white;
            textColor = isDark ? Colors.white : Colors.black87;
            borderColor = isDark ? Colors.transparent : Colors.grey.shade200;
          }

          return Container(
            width: 60,
            decoration: BoxDecoration(
              color: boxColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor, width: isToday ? 0 : 1),
              boxShadow: isToday
                  ? [
                      BoxShadow(
                          color: Colors.orange.withOpacity(0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 4))
                    ]
                  : [],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Label "HARI"
                Text(
                  "HARI",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: textColor.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 2),
                // Angka Besar (1, 2, 3...)
                Text(
                  "$dayNumber",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 4),
                // Indikator Bawah (Tanggal / Centang)
                if (isPast)
                  const Icon(Icons.check_circle, size: 14, color: Colors.green)
                else
                  Text(
                    DateFormat('d MMM').format(dateOfBox), // Tgl kecil (4 Jan)
                    style: TextStyle(
                        fontSize: 9, color: textColor.withOpacity(0.8)),
                  )
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = Theme.of(context).scaffoldBackgroundColor;

    // --- LOGIKA PERSENTASE BARU (REAL-TIME) ---
    int pastDays = (c.progressDay - 1).clamp(0, c.durationDays);

    int tasksDoneToday = c.todayTaskStatus.where((done) => done).length;
    int totalTasks = c.dailyTasks.length;
    double todayContribution =
        totalTasks == 0 ? 0 : (tasksDoneToday / totalTasks);

    double overallProgress = (pastDays + todayContribution) / c.durationDays;
    overallProgress = overallProgress.clamp(0.0, 1.0);

    // [FIX 3] Bungkus Scaffold dengan ScrollConfiguration
    // Ini yang bikin scroll lancar kayak di challenge_page.dart
    return ScrollConfiguration(
      behavior: MyCustomScrollBehavior(),
      child: Scaffold(
        backgroundColor: bgColor,
        body: SingleChildScrollView(
          child: Column(
            children: [
              // --- HEADER ---
              Container(
                padding: const EdgeInsets.fromLTRB(20, 50, 20, 30),
                decoration: BoxDecoration(
                  color: Color(c.colorCode),
                  borderRadius:
                      const BorderRadius.vertical(bottom: Radius.circular(32)),
                  boxShadow: [
                    BoxShadow(
                      color: Color(c.colorCode).withOpacity(0.4),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    )
                  ],
                ),
                child: Column(
                  children: [
                    // Nav Bar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon:
                              const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_month,
                                  size: 14, color: Colors.white),
                              const SizedBox(width: 6),
                              Text(
                                "Hari ${c.progressDay} / ${c.durationDays}",
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Judul & Lingkaran Progress
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                c.title,
                                style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    height: 1.2),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                c.description,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    color: Colors.white70, fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),

                        // Lingkaran Persentase (REAL TIME)
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 80,
                              height: 80,
                              child: CircularProgressIndicator(
                                value: overallProgress,
                                strokeWidth: 8,
                                backgroundColor: Colors.black12,
                                valueColor:
                                    const AlwaysStoppedAnimation(Colors.white),
                              ),
                            ),
                            Text(
                              "${(overallProgress * 100).toInt()}%",
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // --- KALENDER HORIZONTAL (HARI KE-1, 2, 3...) ---
              _buildScrollableCalendar(isDark),

              const SizedBox(height: 25),

              // --- DAFTAR TUGAS ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "TARGET HARI INI",
                          style: TextStyle(
                              color: isDark ? Colors.white70 : Colors.grey[700],
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                              fontSize: 13),
                        ),
                        Text(
                          "$tasksDoneToday/$totalTasks Selesai",
                          style: const TextStyle(
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
                              fontSize: 13),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // Linear Progress Bar (Harian)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: todayContribution,
                        minHeight: 8,
                        backgroundColor:
                            isDark ? Colors.white10 : Colors.grey[200],
                        valueColor: const AlwaysStoppedAnimation(Colors.orange),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // List Checkbox
                    ...List.generate(c.dailyTasks.length, (index) {
                      return _buildTaskItem(index, c.dailyTasks[index], isDark);
                    }),

                    const SizedBox(height: 50),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTaskItem(int index, String title, bool isDark) {
    bool isDone = c.todayTaskStatus[index];

    return GestureDetector(
      onTap: () => _toggleTask(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: isDone
              ? (isDark
                  ? const Color(0xFF2C2C3E).withOpacity(0.5)
                  : Colors.grey[100])
              : (isDark ? const Color(0xFF2C2C3E) : Colors.white),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDone
                ? Colors.green.withOpacity(0.3)
                : (isDark ? Colors.white10 : Colors.grey[200]!),
          ),
          boxShadow: isDone
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ],
        ),
        child: Row(
          children: [
            // Checkbox Kustom (Lingkaran)
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: isDone ? Colors.green : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                    color: isDone ? Colors.green : Colors.grey.shade400,
                    width: 2),
              ),
              child: isDone
                  ? const Icon(Icons.check, size: 18, color: Colors.white)
                  : null,
            ),

            const SizedBox(width: 16),

            // Teks Tugas
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isDone ? FontWeight.normal : FontWeight.w600,
                  color: isDone
                      ? (isDark ? Colors.white38 : Colors.grey)
                      : (isDark ? Colors.white : Colors.black87),
                  decoration: isDone ? TextDecoration.lineThrough : null,
                  decorationColor: isDark ? Colors.orange : Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
