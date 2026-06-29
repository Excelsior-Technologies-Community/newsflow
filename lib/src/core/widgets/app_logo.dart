import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final Color? color;

  const AppLogo({
    super.key,
    this.size = 100,
    this.showText = true,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            // Outer geometric shape (The "Flow" part)
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF475AD7), Color(0xFF6E7EF2)],
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(size * 0.4),
                  bottomRight: Radius.circular(size * 0.4),
                  topRight: Radius.circular(size * 0.1),
                  bottomLeft: Radius.circular(size * 0.1),
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF475AD7).withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
            ),
            // Inner Icon (The "News" part)
            Icon(
              Icons.auto_awesome_motion_rounded,
              size: size * 0.5,
              color: Colors.white,
            ),
          ],
        ),
        if (showText) ...[
          SizedBox(height: size * 0.2),
          Text(
            'NewsFlow',
            style: GoogleFonts.poppins(
              fontSize: size * 0.3,
              fontWeight: FontWeight.bold,
              color: color ?? (Theme.of(context).brightness == Brightness.dark 
                  ? Colors.white 
                  : Colors.black87),
              letterSpacing: 1.2,
            ),
          ),
        ],
      ],
    );
  }
}

class AppLogoPreview extends StatelessWidget {
  const AppLogoPreview({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: AppLogo(size: 512, showText: false),
        ),
      ),
    );
  }
}
