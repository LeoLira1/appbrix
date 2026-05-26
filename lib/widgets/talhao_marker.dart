import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/talhao.dart';

class TalhaoMarkerPopup extends StatelessWidget {
  final Talhao talhao;

  const TalhaoMarkerPopup({super.key, required this.talhao});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(talhao.nome,
                style: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: const Color(0xFF003819))),
            const SizedBox(height: 4),
            Text(
              'Lat: ${talhao.latitude.toStringAsFixed(5)}\nLon: ${talhao.longitude.toStringAsFixed(5)}',
              style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey[600]),
            ),
            if (talhao.observacoes != null && talhao.observacoes!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(talhao.observacoes!,
                    style: GoogleFonts.outfit(
                        fontSize: 12, color: Colors.grey[700])),
              ),
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(talhao.dataHora,
                  style:
                      GoogleFonts.outfit(fontSize: 11, color: Colors.grey)),
            ),
          ],
        ),
      ),
    );
  }
}
