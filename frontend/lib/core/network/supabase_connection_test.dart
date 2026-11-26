import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConnectionTest {
  static Future<void> testConnection() async {
    try {
      final client = Supabase.instance.client;

      final response = await client
          .from('profiles')
          .select('id')
          .limit(1);

      print('SUPABASE CONNECTION SUCCESSFUL');
      print('Database response: $response');
    } on PostgrestException catch (e) {
      print('SUPABASE DATABASE ERROR: ${e.message}');
      print('Code: ${e.code}');
      print('Details: ${e.details}');
    } catch (e) {
      print('SUPABASE CONNECTION ERROR: $e');
    }
  }
}