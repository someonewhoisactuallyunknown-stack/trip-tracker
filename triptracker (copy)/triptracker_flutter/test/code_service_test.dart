import 'package:flutter_test/flutter_test.dart';
import 'package:triptracker_flutter/services/code_service.dart';

void main() {
  test('generate teacher and student codes', () {
    final svc = CodeService();
    final t = svc.generateTeacherCode(group: 'G1');
    expect(svc.isTeacherCode(t), true);

    final students = svc.generateStudentCodes(3, group: 'G1');
    expect(students.length, 3);
    for (var s in students) {
      expect(svc.isStudentCode(s), true);
    }
    expect(svc.isDeveloperCode('123456'), true);
  });
}
