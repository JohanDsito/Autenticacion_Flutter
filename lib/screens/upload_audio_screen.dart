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
        SnackBar(content: Text('Audio subido con éxito: $aiTitle')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al subir audio: $e')),
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
      appBar: AppBar(title: const Text('Subir Audio')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (audioFile != null)
              Text('Archivo seleccionado: ${audioFile!.path.split('/').last}')
            else
              const Text('Ningún archivo seleccionado'),

            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: _pickAudio,
              icon: const Icon(Icons.audiotrack),
              label: const Text('Seleccionar Audio'),
            ),

            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: loading ? null : _uploadAudio,
              icon: const Icon(Icons.cloud_upload),
              label: loading
                  ? const CircularProgressIndicator()
                  : const Text('Subir Audio'),
            ),
          ],
        ),
      ),
    );
  }
}
