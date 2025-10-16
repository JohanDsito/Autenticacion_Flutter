import 'package:flutter/material.dart';
import '../screens/audio_player_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';

class AudioCard extends StatelessWidget {
  final Map<String, dynamic> audio;
  final VoidCallback? onDeleted;

  const AudioCard({
    super.key,
    required this.audio,
    this.onDeleted,
  });

  Future<void> _delete(BuildContext context) async {
    try {
      final supabase = SupabaseService.client();

      await supabase.from('audios').delete().eq('id', audio['id']);

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Audio eliminado')),
      );

      if (onDeleted != null) onDeleted!();
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = audio['title'] ?? 'Sin título';
    final tags = audio['tags'] ?? '';
    final url = audio['file_url'] ?? '';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.indigo.shade50, Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.indigo.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          leading: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.indigo.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.audiotrack_rounded,
              color: Colors.indigo,
              size: 28,
            ),
          ),
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              tags.isNotEmpty ? tags : 'Sin etiquetas',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          trailing: PopupMenuButton<String>(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            color: Colors.white,
            elevation: 4,
            icon: const Icon(Icons.more_vert, color: Colors.indigo),
            onSelected: (value) {
              if (value == 'play') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AudioPlayerScreen(url: url, title: title),
                  ),
                );
              } else if (value == 'delete') {
                _delete(context);
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: 'play',
                child: Row(
                  children: [
                    Icon(Icons.play_arrow, color: Colors.indigo),
                    SizedBox(width: 10),
                    Text('Reproducir'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.redAccent),
                    SizedBox(width: 10),
                    Text('Eliminar'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
