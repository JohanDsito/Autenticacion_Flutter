// services/storage_service.dart
import 'dart:io';
import 'dart:convert';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class StorageService {
  final SupabaseClient _supabase = Supabase.instance.client;

  
  final String _geminiApiKey = 'AIzaSyDUe84YZlDVZs-9vAtOLFEks0yZXoFs7ro';


  Future<void> uploadAudioWithAI(File file, String userId) async {
    try {
    
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
      final filePath = 'audios/$userId/$fileName';

      await _supabase.storage.from('audios').upload(filePath, file);
      final publicUrl = _supabase.storage.from('audios').getPublicUrl(filePath);

      
      final model = GenerativeModel(
        model: 'gemini-1.5-flash', 
        apiKey: _geminiApiKey,
      );

      final prompt = '''
Dado el nombre del archivo de audio "$fileName", genera:
- Un título corto de máximo 6 palabras.
- 3 etiquetas separadas por comas relacionadas con el género o el sentimiento.

Devuélvelo en formato JSON así:
{"title": "Título generado", "tags": "etiqueta1, etiqueta2, etiqueta3"}
''';

      final response = await model.generateContent([Content.text(prompt)]);
      final aiText = response.text ?? '';

 
      String title = fileName.split('.').first.replaceAll('_', ' ');
      String tags = 'sin etiquetas';

      try {
        final regex = RegExp(r'\{.*\}');
        final match = regex.firstMatch(aiText);
        if (match != null) {
          final jsonString = match.group(0)!;
          final json = jsonDecode(jsonString); 
          title = json['title'] ?? title;
          tags = json['tags'] ?? tags;
        }
      } catch (_) {
        
      }

  
      await _supabase.from('audios').insert({
        'user_id': userId,
        'file_url': publicUrl,
        'file_path': filePath,
        'title': title,
        'ai_tags': tags,
        'created_at': DateTime.now().toIso8601String(),
      });

    } catch (e) {
      throw Exception('Error al subir el archivo o generar IA: $e');
    }
  }

  /// 🔹 Obtener audios de un usuario
  Future<List<Map<String, dynamic>>> getUserAudios(String userId) async {
    try {
      final data = await _supabase
          .from('audios')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      throw Exception('Error al cargar audios: $e');
    }
  }

  /// 🔹 Eliminar audio del storage y tabla
  Future<void> deleteAudio(String filePath, String audioId) async {
    try {
      await _supabase.storage.from('audios').remove([filePath]);
      await _supabase.from('audios').delete().eq('id', audioId);
    } catch (e) {
      throw Exception('Error al eliminar audio: $e');
    }
  }
}
