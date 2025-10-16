// screens/home_screen.dart
import 'package:flutter/material.dart';
import 'upload_audio_screen.dart';
import '../services/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/audio_card.dart';
import '../services/supabase_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _auth = AuthService();
  final SupabaseClient _supabase = SupabaseService.client();

  List<Map<String, dynamic>> audios = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadAudios();
  }

  Future<void> _loadAudios() async {
    setState(() => loading = true);

    final user = _auth.currentUser;
    if (user == null) {
      setState(() => loading = false);
      return;
    }

    try {
      final data = await _supabase
          .from('audios')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      setState(() {
        audios = List<Map<String, dynamic>>.from(data);
      });
    } catch (e) {
      debugPrint('Error al cargar audios: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al cargar los audios')),
      );
    }

    if (!mounted) return;
    setState(() => loading = false);
  }

  Future<void> _goToUpload() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const UploadAudioScreen()),
    );

    if (!mounted) return;
    _loadAudios();
  }

  Future<void> _signOut() async {
    await _auth.signOut();

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreenPlaceholder()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AudioVault AI'),
        actions: [
          IconButton(
            onPressed: _goToUpload,
            icon: const Icon(Icons.upload_file),
            tooltip: 'Subir nuevo audio',
          ),
          IconButton(
            onPressed: _signOut,
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : audios.isEmpty
              ? const Center(
                  child: Text(
                    'No hay audios. Sube uno usando el botón superior.',
                    textAlign: TextAlign.center,
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: audios.length,
                  itemBuilder: (context, i) {
                    final audio = audios[i];
                    return AudioCard(
                      audio: audio,
                      onDeleted: _loadAudios,
                    );
                  },
                ),
    );
  }
}

class LoginScreenPlaceholder extends StatelessWidget {
  const LoginScreenPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'Sesión cerrada.\nVuelve a iniciar sesión desde la pantalla principal.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
