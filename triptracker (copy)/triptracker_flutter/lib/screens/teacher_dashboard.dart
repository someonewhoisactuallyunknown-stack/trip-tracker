import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/code_service.dart';

class TeacherDashboard extends StatefulWidget {
  final String code;
  final Map<String, dynamic> info;
  const TeacherDashboard({super.key, required this.code, required this.info});

  @override
  State<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard> {
  bool _online = true;
  final Random _rng = Random();

  void _alertAll() {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Alert sent to all students')));
  }

  void _markSafe() {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Marked group as safe')));
  }

  int _batteryFor(String code) {
    // deterministic pseudo-random battery based on code hash for display
    final hash = code.codeUnits.fold<int>(0, (p, e) => p + e);
    return 40 + (hash % 60); // between 40 and 99
  }

  @override
  Widget build(BuildContext context) {
    final service = Provider.of<CodeService>(context);
    final groupName = widget.info['group'] ?? 'Class 10A';
    final students = service.students.entries.where((e) => (e.value['group'] ?? '').toString() == groupName).toList();
    // if no students in CodeService for this group, show a few mock entries
    final showMock = students.isEmpty;

    final primary = const Color(0xFF0459ae);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // battery alert banner (placeholder)
                Container(
                  width: double.infinity,
                  color: Colors.orange[400],
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.battery_alert, color: Colors.white, size: 18),
                      const SizedBox(width: 8),
                      const Flexible(child: Text('Your device battery is low. Please charge it.', style: TextStyle(color: Colors.white))),
                    ],
                  ),
                ),
                // header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: isDark ? Colors.black.withOpacity(0.02) : Colors.white),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Teacher Dashboard', style: GoogleFonts.workSans(fontSize: 20, fontWeight: FontWeight.w700, color: isDark ? Colors.white : Colors.grey[900])),
                          Row(
                            children: [
                              IconButton(onPressed: () {}, icon: Icon(Icons.notifications, color: isDark ? Colors.white70 : Colors.grey[700])),
                              IconButton(onPressed: () {}, icon: Icon(Icons.settings, color: isDark ? Colors.white70 : Colors.grey[700])),
                            ],
                          )
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Group: $groupName', style: GoogleFonts.workSans(fontSize: 16, fontWeight: FontWeight.w600, color: isDark ? Colors.white70 : Colors.grey[800])),
                          Row(
                            children: [
                              ElevatedButton.icon(onPressed: _alertAll, icon: const Icon(Icons.campaign, color: Colors.red), label: const Text('Alert All'), style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade50, foregroundColor: Colors.red)),
                              const SizedBox(width: 8),
                              ElevatedButton.icon(onPressed: _markSafe, icon: const Icon(Icons.check_circle, color: Colors.green), label: const Text('Mark Safe'), style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade50, foregroundColor: Colors.green)),
                            ],
                          )
                        ],
                      ),
                      const SizedBox(height: 12),
                      // online/offline toggle
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(color: isDark ? Colors.grey[850] : Colors.grey[200], borderRadius: BorderRadius.circular(999)),
                        child: Row(children: [
                          Expanded(child: GestureDetector(onTap: () => setState(() => _online = true), child: Container(padding: const EdgeInsets.symmetric(vertical: 10), decoration: BoxDecoration(color: _online ? primary : Colors.transparent, borderRadius: BorderRadius.circular(999)), child: Center(child: Text('Online', style: GoogleFonts.workSans(color: _online ? Colors.white : Colors.grey[700], fontWeight: FontWeight.w600)))))),
                          Expanded(child: GestureDetector(onTap: () => setState(() => _online = false), child: Container(padding: const EdgeInsets.symmetric(vertical: 10), decoration: BoxDecoration(color: !_online ? (isDark ? Colors.grey[700] : Colors.transparent) : Colors.transparent, borderRadius: BorderRadius.circular(999)), child: Center(child: Text('Offline', style: GoogleFonts.workSans(color: !_online ? Colors.grey[700] : Colors.grey[500], fontWeight: FontWeight.w600)))))),
                        ]),
                      )
                    ],
                  ),
                ),
                // students list
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: ListView(
                      children: (showMock ? _mockStudents() : students.map((e) => MapEntry(e.key, e.value)).toList()).map((entry) {
                        final code = showMock ? entry['code'] as String : (entry as MapEntry).key;
                        final data = showMock ? entry : (entry as MapEntry).value;
                        final name = showMock ? entry['name'] as String : (data['name'] ?? 'Student');
                        final battery = showMock ? (entry['battery'] as int) : _batteryFor(code as String);
                        final online = battery > 30;
                        return _StudentCard(name: name, battery: battery, online: online, primary: primary);
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
            // floating map button
            Positioned(
              bottom: 16,
              right: 16,
              child: FloatingActionButton(
                onPressed: () {},
                backgroundColor: primary,
                child: const Icon(Icons.map),
              ),
            )
          ],
        ),
      ),
    );
  }

  List<Map<String, Object>> _mockStudents() {
    return [
      {'name': 'Ethan Carter', 'code': 'S1001', 'battery': 85},
      {'name': 'Olivia Bennett', 'code': 'S1002', 'battery': 60},
      {'name': 'Noah Thompson', 'code': 'S1003', 'battery': 92},
      {'name': 'Ava Martinez', 'code': 'S1004', 'battery': 78},
      {'name': 'Liam Anderson', 'code': 'S1005', 'battery': 55},
    ];
  }
}

class _StudentCard extends StatelessWidget {
  final String name;
  final int battery;
  final bool online;
  final Color primary;

  const _StudentCard({required this.name, required this.battery, required this.online, required this.primary});

  @override
  Widget build(BuildContext context) {
    final batteryColor = battery >= 80 ? Colors.green : (battery >= 50 ? Colors.orange : Colors.red);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: const Offset(0, 2))]),
      child: Column(
        children: [
          Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(radius: 26, backgroundColor: Colors.grey[300], child: Text(name.split(' ').map((s) => s[0]).take(2).join(), style: GoogleFonts.workSans(fontWeight: FontWeight.w700))),
                  Positioned(bottom: 0, right: 0, child: Container(width: 12, height: 12, decoration: BoxDecoration(color: online ? Colors.green : Colors.grey[400], shape: BoxShape.circle, border: Border.all(color: Theme.of(context).scaffoldBackgroundColor, width: 2))))
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(name, style: GoogleFonts.workSans(fontWeight: FontWeight.w700)), const SizedBox(height: 4), Row(children: [Icon(Icons.battery_full, color: batteryColor, size: 16), const SizedBox(width: 6), Text('$battery%', style: GoogleFonts.workSans(color: Colors.grey[700]))])]),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            IconButton(onPressed: () {}, icon: Icon(Icons.location_on, color: primary)),
            IconButton(onPressed: () {}, icon: Icon(Icons.info_outline, color: primary)),
            IconButton(onPressed: () {}, icon: Icon(Icons.photo_camera, color: primary)),
          ])
        ],
      ),
    );
  }
}
