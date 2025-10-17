import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/code_service.dart';

class GenerateCodesScreen extends StatefulWidget {
  const GenerateCodesScreen({super.key});

  @override
  State<GenerateCodesScreen> createState() => _GenerateCodesScreenState();
}

class _GenerateCodesScreenState extends State<GenerateCodesScreen> {
  String _role = 'students';
  final _groupController = TextEditingController();
  final _countController = TextEditingController(text: '5');

  @override
  Widget build(BuildContext context) {
    final service = Provider.of<CodeService>(context);
    final primary = const Color(0xFF0459ae);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
        title: Text('Generate Codes', style: GoogleFonts.workSans(fontWeight: FontWeight.w700)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[800] : Colors.grey[200], borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _role = 'students'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(color: _role == 'students' ? Theme.of(context).cardColor : Colors.transparent, borderRadius: BorderRadius.circular(8)),
                        child: Center(child: Text('Students', style: GoogleFonts.workSans(fontWeight: FontWeight.w600, color: _role == 'students' ? primary : null))),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _role = 'teachers'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(color: _role == 'teachers' ? Theme.of(context).cardColor : Colors.transparent, borderRadius: BorderRadius.circular(8)),
                        child: Center(child: Text('Teachers', style: GoogleFonts.workSans(fontWeight: FontWeight.w600, color: _role == 'teachers' ? primary : null))),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _groupController,
              decoration: InputDecoration(hintText: 'Enter Group Name / Teacher Name', filled: true, fillColor: Theme.of(context).brightness == Brightness.dark ? Colors.grey[900] : Colors.grey[100], border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
            ),
            const SizedBox(height: 12),
            if (_role == 'students')
              TextField(controller: _countController, keyboardType: TextInputType.number, decoration: InputDecoration(hintText: 'Count', filled: true, fillColor: Theme.of(context).brightness == Brightness.dark ? Colors.grey[900] : Colors.grey[100], border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none))),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final group = _groupController.text.trim().isEmpty ? 'default' : _groupController.text.trim();
                  if (_role == 'teachers') {
                    final code = service.generateTeacherCode(group: group);
                    setState(() {});
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Teacher code: $code')));
                    return;
                  }
                  final cnt = int.tryParse(_countController.text) ?? 1;
                  final list = service.generateStudentCodes(cnt, group: group);
                  setState(() {});
                  showDialog(context: context, builder: (_) => AlertDialog(title: const Text('Generated'), content: SizedBox(width: double.maxFinite, child: ListView(shrinkWrap: true, children: list.map((c) => ListTile(title: Text(c), trailing: IconButton(icon: const Icon(Icons.copy), onPressed: () { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Copied $c'))); }))).toList())), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))]));
                },
                style: ElevatedButton.styleFrom(backgroundColor: primary, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: Text('Generate Codes', style: GoogleFonts.workSans(fontWeight: FontWeight.w700)),
              ),
            ),
            const SizedBox(height: 20),
            Align(alignment: Alignment.centerLeft, child: Text('Generated Codes', style: GoogleFonts.workSans(fontWeight: FontWeight.w700, fontSize: 16))),
            const SizedBox(height: 8),
            Expanded(
              child: ListView(
                children: service.students.entries.map((e) => _CodeCard(title: e.value['group'] ?? 'Group', code: e.key, onDelete: () { service.deleteStudentCode(e.key); setState(() {}); }, onCopy: () { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Copied ${e.key}'))); })).toList()
                  ..addAll(service.teachers.entries.map((e) => _CodeCard(title: e.value['group'] ?? 'Group', code: e.key, onDelete: () { service.deleteTeacherCode(e.key); setState(() {}); }, onCopy: () { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Copied ${e.key}'))); }))),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _CodeCard extends StatelessWidget {
  final String title;
  final String code;
  final VoidCallback onDelete;
  final VoidCallback onCopy;

  const _CodeCard({required this.title, required this.code, required this.onDelete, required this.onCopy});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))]),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: GoogleFonts.workSans(fontWeight: FontWeight.w700)), const SizedBox(height: 4), Text('Code: $code', style: GoogleFonts.workSans(color: Colors.grey))]),
          Row(children: [IconButton(icon: const Icon(Icons.copy, color: Colors.blue), onPressed: onCopy), IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: onDelete)])
        ],
      ),
    );
  }
}
