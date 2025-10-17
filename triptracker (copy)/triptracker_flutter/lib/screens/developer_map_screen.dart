import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DeveloperMapScreen extends StatelessWidget {
  const DeveloperMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bgImage = 'https://lh3.googleusercontent.com/aida-public/AB6AXuB5WWGFHkDD3fxFkJEmO515OoZDU3yXfRNH7Nu0ZH_5bwPDYxDbMqkj-1T_UQKjc0Fnp2LtsdCd_uw8AOGVjGBNgS6EK0h30BTQ6k4niTe5Cl5UqcJ7OdrQVVuKZIBg_kZSI-N2D7OmOWz_59dPh-LSwX2i32vZtWve_bZJqYMi3aPdCXU2xmu926QtHer0fS5ZMv6ESf11tKF8RMLzKCPa4j4CCeHDhmypJwsDcA_Jtq3fiCWkqmbHQBjn28cxaw8aKjeCPr-aoBk';

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.network(bgImage, fit: BoxFit.cover),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.filter_list, color: Colors.black87),
                      label: Text('Filter', style: GoogleFonts.workSans(color: Colors.black87)),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.white.withOpacity(0.9), elevation: 6, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
                    ),
                  ),
                  Expanded(child: Container()),
                  // bottom info sheet
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor, borderRadius: const BorderRadius.vertical(top: Radius.circular(20)), boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 12, offset: Offset(0, -6))]),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 12),
                        Container(width: 40, height: 6, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(12))),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              CircleAvatar(radius: 36, backgroundImage: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuBdHo09UselF59zZQPQjqTQjLpeEroSs__LUMb77WGwHkm6qJy51Dq7xFsaFKIyH56CRYRpvRO3wI8eMHREbW0qwajbBMipDPjvtMX9Njs-QWAPthTcUttSs-6RwnnvkwpbaUxx5Io6c-mkeQkrxtbR2R953Zst8mVg6sjL4BSVrQempQGOEdUzadKRM67htQxrTQYIwY-RAAfp5omDWEw2ifaKmOjaVJsiMS7jyuWBAnFQQzSU8CuQEK6_YvoOBfFyFjeXYQWReOA')),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Ethan Carter', style: GoogleFonts.workSans(fontSize: 18, fontWeight: FontWeight.w700)), const SizedBox(height: 4), Text('Teacher, Group A', style: GoogleFonts.workSans(color: Colors.grey)), const SizedBox(height: 4), Text('85% Battery · Last seen: 2 min ago', style: GoogleFonts.workSans(color: Colors.grey[600]))]),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
          // floating controls
          Positioned(bottom: 140, right: 16, child: Column(children: [
            FloatingActionButton(onPressed: () {}, mini: true, backgroundColor: Theme.of(context).scaffoldBackgroundColor, child: const Icon(Icons.refresh, color: Colors.black87)),
            const SizedBox(height: 8),
            FloatingActionButton(onPressed: () {}, mini: true, backgroundColor: Theme.of(context).scaffoldBackgroundColor, child: const Icon(Icons.my_location, color: Colors.black87)),
          ]))
        ],
      ),
    );
  }
}
