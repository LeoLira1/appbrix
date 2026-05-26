import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/calc_service.dart';
import '../widgets/result_card.dart';
import '../widgets/formula_display.dart';

class TchScreen extends StatefulWidget {
  const TchScreen({super.key});

  @override
  State<TchScreen> createState() => _TchScreenState();
}

class _TchScreenState extends State<TchScreen> {
  // Direto
  final _cmCtrl = TextEditingController(text: '10,00');
  final _pcCtrl = TextEditingController(text: '1,20');
  final _mlCtrl = TextEditingController(text: '6666');
  // Indireto
  final _dCtrl = TextEditingController(text: '28,0');
  final _cmICtrl = TextEditingController(text: '10,00');
  final _ccCtrl = TextEditingController(text: '2,40');
  final _eCtrl = TextEditingController(text: '1,50');
  // TAH
  final _atrCtrl = TextEditingController(text: '130,00');

  bool _useIndireto = false;

  double get _tchDireto => CalcService.calcTCHDireto(
      CalcService.parseBR(_cmCtrl.text),
      CalcService.parseBR(_pcCtrl.text),
      CalcService.parseBR(_mlCtrl.text));

  double get _tchIndireto => CalcService.calcTCHIndireto(
      CalcService.parseBR(_dCtrl.text),
      CalcService.parseBR(_cmICtrl.text),
      CalcService.parseBR(_ccCtrl.text),
      CalcService.parseBR(_eCtrl.text));

  double get _tch => _useIndireto ? _tchIndireto : _tchDireto;
  double get _tah =>
      CalcService.calcTAH(_tch, CalcService.parseBR(_atrCtrl.text));

  @override
  void initState() {
    super.initState();
    for (final c in [_cmCtrl, _pcCtrl, _mlCtrl, _dCtrl, _cmICtrl, _ccCtrl, _eCtrl, _atrCtrl]) {
      c.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    for (final c in [_cmCtrl, _pcCtrl, _mlCtrl, _dCtrl, _cmICtrl, _ccCtrl, _eCtrl, _atrCtrl]) {
      c.dispose();
    }
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
            Row(
              children: [
                Text('Método:', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: const Color(0xFF003819))),
                const SizedBox(width: 12),
                ChoiceChip(
                  label: const Text('Direto'),
                  selected: !_useIndireto,
                  onSelected: (_) => setState(() => _useIndireto = false),
                  selectedColor: const Color(0xFF8ac53a),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Indireto'),
                  selected: _useIndireto,
                  onSelected: (_) => setState(() => _useIndireto = true),
                  selectedColor: const Color(0xFF8ac53a),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (!_useIndireto) ...[
              _input('Colmos por metro linear (CM)', _cmCtrl),
              const SizedBox(height: 10),
              _input('Peso médio do colmo kg (PC)', _pcCtrl),
              const SizedBox(height: 10),
              _input('Metros lineares por hectare (ML)', _mlCtrl),
              const SizedBox(height: 12),
              ResultCard(label: 'TCH (t/ha)', value: CalcService.formatBR(_tch)),
              const SizedBox(height: 8),
              const FormulaDisplay(formula: 'TCH = (CM × PC × ML) ÷ 1000'),
            ] else ...[
              _input('Diâmetro do colmo mm (d)', _dCtrl),
              const SizedBox(height: 10),
              _input('Colmos por metro linear (CM)', _cmICtrl),
              const SizedBox(height: 10),
              _input('Comprimento do colmo m (CC)', _ccCtrl),
              const SizedBox(height: 10),
              _input('Espaçamento m (E)', _eCtrl),
              const SizedBox(height: 12),
              ResultCard(label: 'TCH (t/ha)', value: CalcService.formatBR(_tch)),
              const SizedBox(height: 8),
              const FormulaDisplay(
                  formula: 'TCH = (0,7854 × (d/100)² × CC × CM × 10000) ÷ E'),
            ],
            const SizedBox(height: 20),
            Text('TAH', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF003819))),
            const SizedBox(height: 10),
            _input('ATR (kg/t)', _atrCtrl),
            const SizedBox(height: 12),
            ResultCard(label: 'TAH (t ATR/ha)', value: CalcService.formatBR(_tah)),
            const SizedBox(height: 8),
            const FormulaDisplay(formula: 'TAH = TCH × (ATR ÷ 1000)'),
          ],
        ),
      ),
    );
  }

  Widget _input(String label, TextEditingController ctrl) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.outfit(fontSize: 13, color: Colors.grey[700])),
          const SizedBox(height: 4),
          TextField(
            controller: ctrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              isDense: true,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFF003819), width: 2)),
            ),
          ),
        ],
      );
}
