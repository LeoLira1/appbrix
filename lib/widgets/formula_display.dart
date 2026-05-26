import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FormulaDisplay extends StatelessWidget {
  final String formula;

  const FormulaDisplay({super.key, required this.formula});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF003819).withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
            color: const Color(0xFF003819).withOpacity(0.15)),
      ),
      child: Text(
        formula,
        style: GoogleFonts.outfit(
          fontSize: 13,
          color: Colors.grey[700],
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }
}
