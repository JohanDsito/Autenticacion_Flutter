// screens/audio_player_screen.dart
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class AudioPlayerScreen extends StatefulWidget {
  final String url;
  final String title;
  const AudioPlayerScreen({super.key, required this.url, required this.title});

  @override
  State<AudioPlayerScreen> createState() => _AudioPlayerScreenState();
}

class _AudioPlayerScreenState extends State<AudioPlayerScreen> {
  final player = AudioPlayer();
  bool loading = true;
  Duration pos = Duration.zero;
  Duration dur = Duration.zero;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      await player.setUrl(widget.url);
      dur = player.duration ?? Duration.zero;
      player.positionStream.listen((p) => setState(() { pos = p; }));
    } catch (e) {
      // error
    } finally {
      setState(() { loading = false; });
    }
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  String _format(Duration d) {
    final mm = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final ss = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '${d.inHours > 0 ? '${d.inHours}:' : ''}$mm:$ss';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: loading
        ? const Center(child: CircularProgressIndicator())
        : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              iconSize: 64,
              icon: StreamBuilder<PlayerState>(
                stream: player.playerStateStream,
                builder: (context, snapshot) {
                  final state = snapshot.data;
                  final playing = state?.playing ?? false;
                  if (playing) return const Icon(Icons.pause_circle_filled);
                  return const Icon(Icons.play_circle_filled);
                },
              ),
              onPressed: () async {
                if (player.playing) await player.pause();
                else await player.play();
              },
            ),
            Slider(
              value: pos.inMilliseconds.toDouble().clamp(0, dur.inMilliseconds.toDouble()),
              max: dur.inMilliseconds.toDouble(),
              onChanged: (v) {
                player.seek(Duration(milliseconds: v.toInt()));
              },
            ),
            Text('${_format(pos)} / ${_format(dur)}'),
          ],
        ),
    );
  }
}
