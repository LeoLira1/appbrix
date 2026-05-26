import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ResultCard extends StatelessWidget {
  final String label;
  final String value;
  final String? interpretation;
  final Color? interpretationColor;

  const ResultCard({
    super.key,
    required this.label,
    required this.value,
    this.interpretation,
    this.interpretationColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: GoogleFonts.outfit(
                    fontSize: 14, color: Colors.grey[600])),
            const SizedBox(height: 4),
            Text(value,
                style: GoogleFonts.outfit(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF003819),
                )),
            if (interpretation != null) ...[
              const SizedBox(height: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: (interpretationColor ?? const Color(0xFF8ac53a))
                      .withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  interpretation!,
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    color: interpretationColor ?? const Color(0xFF003819),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
