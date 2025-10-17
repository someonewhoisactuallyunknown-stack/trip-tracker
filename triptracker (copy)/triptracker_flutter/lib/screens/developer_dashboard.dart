import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/code_service.dart';
import 'generate_codes_screen.dart';
import 'developer_map_screen.dart';

class DeveloperDashboard extends StatefulWidget {
  const DeveloperDashboard({super.key});

  @override
  State<DeveloperDashboard> createState() => _DeveloperDashboardState();
}

class _DeveloperDashboardState extends State<DeveloperDashboard> {
  int _selectedTab = 0;

  Future<void> _generateTeacher(BuildContext context) async {
    final service = Provider.of<CodeService>(context, listen: false);
    final code = service.generateTeacherCode(group: 'Group ${DateTime.now().millisecondsSinceEpoch}');
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Teacher code: $code')));
  }

  Future<void> _generateStudents(BuildContext context) async {
    final service = Provider.of<CodeService>(context, listen: false);
    final groupCtrl = TextEditingController(text: 'TripGroupA');
    final countCtrl = TextEditingController(text: '5');

    final res = await showDialog<List<String>>(context: context, builder: (ctx) {
      return AlertDialog(
        title: const Text('Generate Student Codes'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: groupCtrl, decoration: const InputDecoration(labelText: 'Group name')),
            const SizedBox(height: 8),
            TextField(controller: countCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Count')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final cnt = int.tryParse(countCtrl.text) ?? 1;
              final group = groupCtrl.text.trim().isEmpty ? 'default' : groupCtrl.text.trim();
              final list = service.generateStudentCodes(cnt, group: group);
              Navigator.pop(ctx, list);
            },
            child: const Text('Generate'),
          )
        ],
      );
    });

    if (res != null && res.isNotEmpty) {
      setState(() {});
      await showDialog(context: context, builder: (ctx) {
        return AlertDialog(
          title: const Text('Generated Student Codes'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView(
              shrinkWrap: true,
              children: res.map((c) => ListTile(title: Text(c), trailing: IconButton(icon: const Icon(Icons.copy), onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Copied $c')));
              }))).toList(),
            ),
          ),
          actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close'))],
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = const Color(0xFF0459ae);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.grey[900];

    final service = Provider.of<CodeService>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: isDark ? Colors.black : Colors.white,
        elevation: 1,
        title: Text('Developer Dashboard', style: GoogleFonts.workSans(color: textColor, fontWeight: FontWeight.w700)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.grey),
            onPressed: () {},
          )
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const SizedBox(height: 8),
                _ActionButton(
                  emoji: '🎓',
                  label: 'Generate Codes for Students',
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const GenerateCodesScreen())),
                  primary: primary,
                ),
                const SizedBox(height: 12),
                _ActionButton(
                  emoji: '👩‍🏫',
                  label: 'Generate Codes for Teachers',
                  onTap: () => _generateTeacher(context),
                  primary: primary,
                ),
                const SizedBox(height: 12),
                _ActionButton(
                  emoji: '🗺️',
                  label: 'See Location of Everyone',
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const DeveloperMapScreen())),
                  primary: primary,
                ),
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 12),
                Align(alignment: Alignment.centerLeft, child: Text('Existing Teachers', style: GoogleFonts.workSans(fontWeight: FontWeight.w700))),
                const SizedBox(height: 8),
                ...service.teachers.entries.map((e) => ListTile(
                      title: Text(e.value['name']),
                      subtitle: Text('Code: ${e.key}  Group: ${e.value['group']}'),
                      trailing: IconButton(icon: const Icon(Icons.delete), onPressed: () {
                        service.deleteTeacherCode(e.key);
                        setState(() {});
                      }),
                    )),
                const SizedBox(height: 8),
                Align(alignment: Alignment.centerLeft, child: Text('Existing Students', style: GoogleFonts.workSans(fontWeight: FontWeight.w700))),
                const SizedBox(height: 8),
                ...service.students.entries.map((e) => ListTile(
                      title: Text(e.value['name']),
                      subtitle: Text('Code: ${e.key}  Group: ${e.value['group']}'),
                      trailing: IconButton(icon: const Icon(Icons.delete), onPressed: () {
                        service.deleteStudentCode(e.key);
                        setState(() {});
                      }),
                    )),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedTab,
        onTap: (i) => setState(() => _selectedTab = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Map'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String emoji;
  final String label;
  final VoidCallback onTap;
  final Color primary;

  const _ActionButton({required this.emoji, required this.label, required this.onTap, required this.primary});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              Expanded(child: Text(label, style: GoogleFonts.workSans(fontSize: 16, fontWeight: FontWeight.w600))),
            ],
          ),
        ),
      ),
    );
  }
}
