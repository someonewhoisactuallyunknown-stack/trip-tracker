import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat(reverse: false);
    // navigate after a short delay
    Timer(const Duration(milliseconds: 2600), () {
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primary = const Color(0xFF0459ae);
    final bgLight = const Color(0xFFF5F7F8);
    final bgDark = const Color(0xFF0F1923);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [primary.withOpacity(0.2), isDark ? bgDark : bgLight],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox.shrink(),
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          margin: const EdgeInsets.only(bottom: 18),
                          child: Image.network(
                            'https://lh3.googleusercontent.com/aida-public/AB6AXuCUeNCT-aoT6iLClmCUsG7e3LXubc18cSjHwyAxqFuOF2v_Ph39gLeqSaMtiisTIWP9mbEjkNtCSn7YwBwNEj7XUJQajmB-AHalTghmz1AdeB_03jtt3gPmEUQwUpk6IpaMLjd3etfytHcGndHy0FAGJzk-E9efzj4JbF240shbDMwe6dux4n7AtKEY-56P0Xo234oUUkVFo-hzhh05iCF6AKz_wOyetbMAc8gn4RsPqZ0PF8PcC0n6iIyk34auddgG8yBx7lz91oI',
                            fit: BoxFit.contain,
                          ),
                        ),
                        Text(
                          'IRSHAD HIGH SCHOOL',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.workSans(fontSize: 20, fontWeight: FontWeight.w700, color: isDark ? bgLight : bgDark),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'TRIP TRACKER',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.workSans(fontSize: 18, fontWeight: FontWeight.w700, color: isDark ? bgLight : bgDark),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: Container(
                        height: 12,
                        width: double.infinity,
                        color: primary.withOpacity(0.2),
                        child: Stack(
                          children: [
                            AnimatedBuilder(
                              animation: _controller,
                              builder: (context, child) {
                                final anim = _controller.value; // 0..1
                                return Align(
                                  alignment: Alignment(-1.0 + anim * 2.0, 0),
                                  child: Container(
                                    width: MediaQuery.of(context).size.width * 0.5,
                                    height: 12,
                                    decoration: BoxDecoration(color: primary, borderRadius: BorderRadius.circular(999)),
                                  ),
                                );
                              },
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
