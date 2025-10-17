import 'supabase_service.dart';

class CodeService {
  final SupabaseService _supabase;

  static const developerCode = '123456';

  CodeService(this._supabase);

  bool isDeveloperCode(String code) => code == developerCode;

  Future<Map<String, dynamic>?> verifyCode(String code) async {
    return await _supabase.loginWithCode(code);
  }

  Future<List<Map<String, dynamic>>> generateStudentCodes(
    int count,
    String groupId,
  ) async {
    return await _supabase.generateStudentCodes(count, groupId);
  }

  Future<Map<String, dynamic>> generateTeacherCode(String groupName) async {
    return await _supabase.generateTeacherCode(groupName);
  }

  Future<void> deleteUser(String userId) async {
    await _supabase.deleteUser(userId);
  }
}
