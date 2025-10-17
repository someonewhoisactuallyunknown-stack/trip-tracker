import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseService {
  static SupabaseService? _instance;
  static SupabaseClient? _client;

  SupabaseService._();

  static Future<SupabaseService> getInstance() async {
    if (_instance == null) {
      _instance = SupabaseService._();
      await _instance!._initialize();
    }
    return _instance!;
  }

  Future<void> _initialize() async {
    if (_client != null) return;

    await dotenv.load(fileName: ".env");

    final supabaseUrl = dotenv.env['SUPABASE_URL'] ?? '';
    final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';

    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );

    _client = Supabase.instance.client;
  }

  SupabaseClient get client {
    if (_client == null) {
      throw Exception('Supabase not initialized');
    }
    return _client!;
  }

  Future<Map<String, dynamic>?> loginWithCode(String code) async {
    try {
      final response = await client
          .from('users')
          .select()
          .eq('access_code', code)
          .maybeSingle();

      if (response != null) {
        await client
            .from('users')
            .update({
              'is_online': true,
              'last_active': DateTime.now().toIso8601String(),
            })
            .eq('id', response['id']);
      }

      return response;
    } catch (e) {
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> generateStudentCodes(
    int count,
    String groupId,
  ) async {
    final List<Map<String, dynamic>> students = [];

    for (int i = 0; i < count; i++) {
      final code = _generateCode();
      final student = await client.from('users').insert({
        'access_code': code,
        'role': 'student',
        'name': 'Student $code',
        'group_id': groupId,
      }).select().single();

      students.add(student);
    }

    return students;
  }

  Future<Map<String, dynamic>> generateTeacherCode(String groupName) async {
    final code = _generateCode();

    final teacher = await client.from('users').insert({
      'access_code': code,
      'role': 'teacher',
      'name': 'Teacher $code',
    }).select().single();

    final group = await client.from('groups').insert({
      'name': groupName,
      'teacher_id': teacher['id'],
    }).select().single();

    await client.from('users').update({
      'group_id': group['id'],
    }).eq('id', teacher['id']);

    return {
      ...teacher,
      'group': group,
    };
  }

  String _generateCode() {
    final random = DateTime.now().millisecondsSinceEpoch % 900000 + 100000;
    return random.toString();
  }

  Future<void> updateLocation(
    String userId,
    double latitude,
    double longitude,
    double accuracy,
    double heading,
    bool isOfflineMode,
  ) async {
    await client.from('locations').insert({
      'user_id': userId,
      'latitude': latitude,
      'longitude': longitude,
      'accuracy': accuracy,
      'heading': heading,
      'is_offline_mode': isOfflineMode,
      'timestamp': DateTime.now().toIso8601String(),
    });

    await client.from('users').update({
      'last_active': DateTime.now().toIso8601String(),
    }).eq('id', userId);
  }

  Future<void> updateBattery(String userId, int batteryLevel) async {
    await client.from('users').update({
      'battery_level': batteryLevel,
    }).eq('id', userId);

    if (batteryLevel < 15) {
      final user = await client
          .from('users')
          .select('group_id')
          .eq('id', userId)
          .single();

      if (user['group_id'] != null) {
        final teacher = await client
            .from('users')
            .select('id')
            .eq('group_id', user['group_id'])
            .eq('role', 'teacher')
            .maybeSingle();

        if (teacher != null) {
          await sendAlert(
            userId,
            teacher['id'],
            'low_battery',
            'Battery level is low ($batteryLevel%)',
            null,
            null,
            batteryLevel,
          );
        }
      }
    }
  }

  Future<void> sendAlert(
    String fromUserId,
    String? toUserId,
    String alertType,
    String message,
    double? latitude,
    double? longitude,
    int? batteryLevel,
  ) async {
    await client.from('alerts').insert({
      'from_user_id': fromUserId,
      'to_user_id': toUserId,
      'alert_type': alertType,
      'message': message,
      'latitude': latitude,
      'longitude': longitude,
      'battery_level': batteryLevel,
    });
  }

  Future<List<Map<String, dynamic>>> getGroupStudents(String groupId) async {
    final students = await client
        .from('users')
        .select()
        .eq('group_id', groupId)
        .eq('role', 'student')
        .order('name');

    return List<Map<String, dynamic>>.from(students);
  }

  Future<Map<String, dynamic>?> getLatestLocation(String userId) async {
    final location = await client
        .from('locations')
        .select()
        .eq('user_id', userId)
        .order('timestamp', ascending: false)
        .limit(1)
        .maybeSingle();

    return location;
  }

  Future<List<Map<String, dynamic>>> getAlerts(String userId) async {
    final alerts = await client
        .from('alerts')
        .select('*, from_user:from_user_id(name), to_user:to_user_id(name)')
        .or('to_user_id.eq.$userId,to_user_id.is.null')
        .eq('is_read', false)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(alerts);
  }

  Future<void> markAlertAsRead(String alertId) async {
    await client.from('alerts').update({
      'is_read': true,
    }).eq('id', alertId);
  }

  Stream<List<Map<String, dynamic>>> watchGroupStudents(String groupId) {
    return client
        .from('users')
        .stream(primaryKey: ['id'])
        .eq('group_id', groupId)
        .eq('role', 'student')
        .order('name')
        .map((data) => List<Map<String, dynamic>>.from(data));
  }

  Stream<List<Map<String, dynamic>>> watchLocations(List<String> userIds) {
    return client
        .from('locations')
        .stream(primaryKey: ['id'])
        .inFilter('user_id', userIds)
        .order('timestamp', ascending: false)
        .map((data) => List<Map<String, dynamic>>.from(data));
  }

  Stream<List<Map<String, dynamic>>> watchAlerts(String userId) {
    return client
        .from('alerts')
        .stream(primaryKey: ['id'])
        .or('to_user_id.eq.$userId,to_user_id.is.null')
        .eq('is_read', false)
        .order('created_at', ascending: false)
        .map((data) => List<Map<String, dynamic>>.from(data));
  }

  Future<List<Map<String, dynamic>>> getAllUsers() async {
    final users = await client
        .from('users')
        .select()
        .order('role')
        .order('name');

    return List<Map<String, dynamic>>.from(users);
  }

  Future<Map<String, dynamic>?> getGroup(String groupId) async {
    final group = await client
        .from('groups')
        .select('*, teacher:teacher_id(*)')
        .eq('id', groupId)
        .maybeSingle();

    return group;
  }

  Future<void> deleteUser(String userId) async {
    await client.from('users').delete().eq('id', userId);
  }
}
