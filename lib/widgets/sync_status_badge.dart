import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/sync_service.dart';

class SyncStatusBadge extends StatelessWidget {
  const SyncStatusBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<SyncStatus>(
      valueListenable: SyncService.instance.status,
      builder: (context, status, _) {
        String emoji;
        String text;
        Color color;

        switch (status) {
          case SyncStatus.sincronizado:
            emoji = '🟢';
            text = 'Sincronizado';
            color = Colors.green;
            break;
          case SyncStatus.pendente:
            emoji = '🟡';
            text = 'Pendente';
            color = Colors.orange;
            break;
          case SyncStatus.sincronizando:
            emoji = '🔄';
            text = 'Sincronizando…';
            color = Colors.blue;
            break;
          case SyncStatus.erro:
            emoji = '🔴';
            text = 'Erro sync';
            color = Colors.red;
            break;
        }

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 12)),
            const SizedBox(width: 4),
            Text(text,
                style: GoogleFonts.outfit(
                    fontSize: 11,
                    color: color,
                    fontWeight: FontWeight.w600)),
          ],
        );
      },
    );
  }
}
