import 'package:flutter/material.dart';

class StudentDashboard extends StatelessWidget {
  final String code;
  final Map<String, dynamic> info;
  const StudentDashboard({super.key, required this.code, required this.info});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Student Dashboard')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text('Welcome ${info['name']}', style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 8),
          Text('Group: ${info['group']}', style: const TextStyle(color: Colors.black54)),
          const SizedBox(height: 12),
          const Text('Location: (stub) 10.000, 76.000'),
          const SizedBox(height: 8),
          const Text('Battery: 🔋 85%'),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: () {}, style: ElevatedButton.styleFrom(backgroundColor: Colors.red), child: const Text('Emergency Help'))
        ]),
      ),
    );
  }
}
