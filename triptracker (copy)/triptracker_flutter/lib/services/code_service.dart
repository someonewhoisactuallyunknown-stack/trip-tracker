import 'dart:math';

class CodeService {
  // In-memory maps for now. Later persist using Hive or SQLite.
  final Map<String, Map<String, dynamic>> teachers = {}; // code -> {name, group}
  final Map<String, Map<String, dynamic>> students = {}; // code -> {name, group}
  final Random _rng = Random();

  static const developerCode = '123456';

  bool isDeveloperCode(String code) => code == developerCode;

  String generate6DigitCode() {
    return (_rng.nextInt(900000) + 100000).toString();
  }

  List<String> generateStudentCodes(int count, {String group = 'default'}) {
    final list = <String>[];
    for (var i = 0; i < count; i++) {
      var c = generate6DigitCode();
      while (students.containsKey(c) || teachers.containsKey(c) || c == developerCode) {
        c = generate6DigitCode();
      }
      students[c] = {'name': 'Student $c', 'group': group};
      list.add(c);
    }
    return list;
  }

  String generateTeacherCode({String group = 'Group ${DateTime.now().millisecondsSinceEpoch}'}) {
    var c = generate6DigitCode();
    while (students.containsKey(c) || teachers.containsKey(c) || c == developerCode) {
      c = generate6DigitCode();
    }
    teachers[c] = {'name': 'Teacher $c', 'group': group};
    return c;
  }

  bool isTeacherCode(String code) => teachers.containsKey(code);
  bool isStudentCode(String code) => students.containsKey(code);

  Map<String, dynamic>? getTeacher(String code) => teachers[code];
  Map<String, dynamic>? getStudent(String code) => students[code];

  void deleteStudentCode(String code) => students.remove(code);
  void deleteTeacherCode(String code) => teachers.remove(code);
}
