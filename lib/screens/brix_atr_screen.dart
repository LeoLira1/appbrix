import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/calc_service.dart';
import '../widgets/result_card.dart';
import '../widgets/formula_display.dart';

class BrixAtrScreen extends StatefulWidget {
  const BrixAtrScreen({super.key});

  @override
  State<BrixAtrScreen> createState() => _BrixAtrScreenState();
}

class _BrixAtrScreenState extends State<BrixAtrScreen> {
  final _brixCtrl = TextEditingController(text: '20,00');

  double get _brix => CalcService.parseBR(_brixCtrl.text);
  double get _atr => CalcService.calcATR(_brix);

  Color _interpretColor(double atr) {
    if (atr < 100) return Colors.orange;
    if (atr <= 140) return Colors.blue;
    return Colors.green;
  }

  @override
  void initState() {
    super.initState();
    _brixCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _brixCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFf7fbf3), Color(0xFFe9f3df)],
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Cálculo de ATR',
                style: GoogleFonts.outfit(
                    fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF003819))),
            const SizedBox(height: 16),
            _inputField('Brix (graus)', _brixCtrl),
            const SizedBox(height: 16),
            ResultCard(
              label: 'ATR (kg/t)',
              value: CalcService.formatBR(_atr),
              interpretation: CalcService.interpretarATR(_atr),
              interpretationColor: _interpretColor(_atr),
            ),
            const SizedBox(height: 8),
            const FormulaDisplay(formula: 'ATR = 7,6427 × Brix − 10,109'),
          ],
        ),
      ),
    );
  }

  Widget _inputField(String label, TextEditingController ctrl) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.outfit(fontSize: 14, color: Colors.grey[700])),
          const SizedBox(height: 6),
          TextField(
            controller: ctrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFF003819))),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFF003819), width: 2)),
            ),
          ),
        ],
      );
}
