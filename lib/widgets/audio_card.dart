// widgets/audio_card.dart
import 'package:flutter/material.dart';
import '../screens/audio_player_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';

class AudioCard extends StatelessWidget {
  final Map<String, dynamic> audio;
  final VoidCallback? onDeleted;

  const AudioCard({super.key, required this.audio, this.onDeleted});

  Future<void> _delete(BuildContext context) async {
    try {
      final supabase = SupabaseService.client();

      // 🔹 CORRECCIÓN 1: Elimina el uso de `.execute()`
      await supabase.from('audios').delete().eq('id', audio['id']);

      // 🔹 CORRECCIÓN 2: Verifica que el widget siga montado antes de usar context
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
    final tags = audio['ai_tags'] ?? '';
    final url = audio['file_url'] ?? '';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(title),
        subtitle: Text(tags),
        trailing: PopupMenuButton<String>(
          onSelected: (v) {
            if (v == 'play') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AudioPlayerScreen(url: url, title: title),
                ),
              );
            } else if (v == 'delete') {
              _delete(context);
            }
          },
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'play', child: Text('Reproducir')),
            PopupMenuItem(value: 'delete', child: Text('Eliminar')),
          ],
        ),
      ),
    );
  }
}
