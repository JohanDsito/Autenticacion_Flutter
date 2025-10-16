// screens/upload_audio_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';
import '../services/gemini_service.dart';

class UploadAudioScreen extends StatefulWidget {
  const UploadAudioScreen({super.key});

  @override
  State<UploadAudioScreen> createState() => _UploadAudioScreenState();
}

class _UploadAudioScreenState extends State<UploadAudioScreen> {
  final SupabaseClient _supabase = Supabase.instance.client;
  final AuthService _auth = AuthService();

  bool loading = false;
  File? audioFile;

  Future<void> _pickAudio() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3', 'wav', 'm4a'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        audioFile = File(result.files.single.path!);
      });
    }
  }

  Future<void> _uploadAudio() async {
    if (audioFile == null) return;

    setState(() {
      loading = true;
    });

    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${audioFile!.path.split('/').last}';
      final filePath = 'audios/${user.id}/$fileName';

      await _supabase.storage.from('audios').upload(filePath, audioFile!);
      final publicUrl = _supabase.storage.from('audios').getPublicUrl(filePath);

      final aiData =
          await GeminiService.generateTitleAndTagsFromFilename(fileName);
      final aiTitle = aiData['title'] ?? 'Audio sin título';
      final aiTags = aiData['tags'] ?? 'sin etiquetas';

      await _supabase.from('audios').insert({
        'user_id': user.id,
        'file_name': fileName,
        'file_url': publicUrl,
        'title': aiTitle,
        'tags': aiTags,
        'created_at': DateTime.now().toIso8601String(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green.shade600,
          content: Text('✅ Audio subido con éxito: $aiTitle'),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red.shade600,
          content: Text('❌ Error al subir audio: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo.shade50,
      appBar: AppBar(
        title: const Text('Subir Audio'),
        centerTitle: true,
        backgroundColor: Colors.indigo.shade600,
        elevation: 5,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          padding: const EdgeInsets.all(24),
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.cloud_upload_rounded,
                  size: 90, color: Colors.indigo.shade400),
              const SizedBox(height: 20),
              Text(
                audioFile != null
                    ? 'Archivo seleccionado:\n${audioFile!.path.split('/').last}'
                    : 'Selecciona un archivo de audio para subir',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: loading ? null : _pickAudio,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo.shade400,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                ),
                icon: const Icon(Icons.audiotrack),
                label: const Text(
                  'Seleccionar Audio',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: loading ? null : _uploadAudio,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade500,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                ),
                icon: const Icon(Icons.cloud_done),
                label: loading
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Text(
                        'Subir Audio',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
