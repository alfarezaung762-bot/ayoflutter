import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class VideoPlayerPage extends StatefulWidget {
  final String videoUrl;

  const VideoPlayerPage({super.key, required this.videoUrl});

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();

    // 1. Ambil ID Video dari URL
    final videoId = YoutubePlayer.convertUrlToId(widget.videoUrl);

    // 2. Inisialisasi Controller
    _controller = YoutubePlayerController(
      initialVideoId: videoId ?? "", // ID Video
      flags: const YoutubePlayerFlags(
        autoPlay: true, // Langsung putar
        mute: false, // Jangan di-mute
        enableCaption: true, // Ada subtitle (jika tersedia)
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose(); // Matikan player saat keluar halaman
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayerBuilder(
      player: YoutubePlayer(
        controller: _controller,
        showVideoProgressIndicator: true,
        progressIndicatorColor: Colors.orange,
        progressColors: const ProgressBarColors(
          playedColor: Colors.orange,
          handleColor: Colors.orangeAccent,
        ),
      ),
      builder: (context, player) {
        return Scaffold(
          backgroundColor: Colors.black, // Background hitam ala bioskop
          appBar: AppBar(
            backgroundColor: Colors.transparent, // Transparan biar keren
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          // Pusatkan Video di tengah layar
          body: Center(child: player),
        );
      },
    );
  }
}
