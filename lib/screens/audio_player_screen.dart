import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class AudioPlayerScreen extends StatefulWidget {
  final String url;
  final String title;

  const AudioPlayerScreen({
    super.key,
    required this.url,
    required this.title,
  });

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
      player.positionStream.listen((p) {
        setState(() {
          pos = p;
        });
      });
    } catch (e) {
      debugPrint('Error loading audio: $e');
    } finally {
      setState(() {
        loading = false;
      });
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
      backgroundColor: Colors.indigo.shade50,
      appBar: AppBar(
        title: Text(widget.title, style: const TextStyle(fontWeight: FontWeight.w600)),
        centerTitle: true,
        backgroundColor: Colors.indigo.shade600,
        elevation: 5,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(24.0),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.white, Colors.indigo.shade100],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.indigo.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(30),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.audiotrack_rounded,
                        size: 100, color: Colors.indigo.shade400),
                    const SizedBox(height: 30),
                    Text(
                      widget.title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 40),
                    StreamBuilder<PlayerState>(
                      stream: player.playerStateStream,
                      builder: (context, snapshot) {
                        final state = snapshot.data;
                        final playing = state?.playing ?? false;
                        return GestureDetector(
                          onTap: () async {
                            if (player.playing) {
                              await player.pause();
                            } else {
                              await player.play();
                            }
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            height: 90,
                            width: 90,
                            decoration: BoxDecoration(
                              color: playing
                                  ? Colors.indigo.shade300
                                  : Colors.green.shade400,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                )
                              ],
                            ),
                            child: Icon(
                              playing
                                  ? Icons.pause_rounded
                                  : Icons.play_arrow_rounded,
                              color: Colors.white,
                              size: 60,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 40),
                    Column(
                      children: [
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTrackColor: Colors.indigo.shade400,
                            inactiveTrackColor: Colors.indigo.shade100,
                            thumbColor: Colors.indigo.shade600,
                            trackHeight: 4.0,
                          ),
                          child: Slider(
                            value: pos.inMilliseconds
                                .toDouble()
                                .clamp(0, dur.inMilliseconds.toDouble()),
                            max: dur.inMilliseconds.toDouble(),
                            onChanged: (v) {
                              player.seek(Duration(milliseconds: v.toInt()));
                            },
                          ),
                        ),
                        Text(
                          '${_format(pos)} / ${_format(dur)}',
                          style: TextStyle(
                            color: Colors.indigo.shade600,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
