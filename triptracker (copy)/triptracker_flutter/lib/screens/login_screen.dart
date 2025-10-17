import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/code_service.dart';
import 'developer_dashboard.dart';
import 'teacher_dashboard.dart';
import 'student_dashboard.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _controller = TextEditingController();
  String _error = '';

  Future<void> _login() async {
    final code = _controller.text.trim();
    if (code.isEmpty) {
      setState(() {
        _error = 'Please enter an access code';
      });
      return;
    }

    setState(() {
      _error = '';
    });

    final service = Provider.of<CodeService>(context, listen: false);

    if (service.isDeveloperCode(code)) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const DeveloperDashboard()),
      );
      return;
    }

    final user = await service.verifyCode(code);
    if (user != null) {
      if (user['role'] == 'teacher') {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => TeacherDashboard(userData: user)),
        );
      } else if (user['role'] == 'student') {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => StudentDashboard(userData: user)),
        );
      }
    } else {
      setState(() {
        _error = 'Invalid code. Ask the developer/teacher for a valid code.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = const Color(0xFF0459ae);
    final bgLight = const Color(0xFFF5F7F8);
    final bgDark = const Color(0xFF0F1923);
    final textLight = const Color(0xFF111827);
    final textDark = const Color(0xFFF3F4F6);
    final subtleLight = const Color(0xFF6B7280);
    final subtleDark = const Color(0xFF9CA3AF);
    final inputBgLight = const Color(0xFFFFFFFF);
    final inputBgDark = const Color(0xFF1F2937);
    final inputBorderLight = const Color(0xFFD1D5DB);
    final inputBorderDark = const Color(0xFF4B5563);

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? bgDark : bgLight,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(bottom: 20),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              'https://lh3.googleusercontent.com/aida-public/AB6AXuDbjsZysG6r4Y8PH7bkDkcliTcUkDrtjSnC2tqkXa3TMwvX2Ltz8AlDx_X0sqzbOu9JQbLi7ZR7VXnf1WZl1wls9VoNSO20l5EXjmJTayKjuCs1NgN6PDbHnD84Ase1fbCh7C6r4v_My7LZ5T2bonkzqo88HPJIi-wYvFg9dClhNucYEN8jsvmJOHwzWIHm0HxO9ZiRJYqjq1in2w6m5UIGK3bPCf-o622K2Zb2ZCb69wh6OE__fE_iucXgkOwhnvRgKw2edSfuuhI',
                              height: 96,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        Text(
                          'Enter Access Code',
                          style: GoogleFonts.workSans(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: isDark ? textDark : textLight,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Login using your assigned code',
                          style: GoogleFonts.workSans(
                            fontSize: 14,
                            color: isDark ? subtleDark : subtleLight,
                          ),
                        ),
                        const SizedBox(height: 24),
                        TextField(
                          controller: _controller,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: 'Access Code',
                            filled: true,
                            fillColor: isDark ? inputBgDark : inputBgLight,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: isDark ? inputBorderDark : inputBorderLight),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: isDark ? inputBorderDark : inputBorderLight),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: primary),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primary,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              textStyle: GoogleFonts.workSans(fontWeight: FontWeight.w700),
                            ),
                            child: const Text('Login'),
                          ),
                        ),
                        if (_error.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Text(_error, style: const TextStyle(color: Colors.red)),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                'Developed for IRSHAD HIGH SCHOOL, CHANGALEERI, MANNARKKAD',
                textAlign: TextAlign.center,
                style: GoogleFonts.workSans(fontSize: 12, color: isDark ? subtleDark : subtleLight),
              ),
            )
          ],
        ),
      ),
    );
  }
}
