import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static const String SUPABASE_URL = 'https://zdlrtovomnpueoopiadg.supabase.co';
  static const String SUPABASE_ANON_KEY ='eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpkbHJ0b3ZvbW5wdWVvb3BpYWRnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjA1NTQ5MzUsImV4cCI6MjA3NjEzMDkzNX0.ufhX5ydwxltxSVKWiP-CFPnIFs6RsNXaCzocWtfOXKw';

  static SupabaseClient client() => Supabase.instance.client;

  static Future<void> init() async {
    await Supabase.initialize(
      url: SUPABASE_URL,
      anonKey: SUPABASE_ANON_KEY,
    );
  }
}
