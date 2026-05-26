import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/calc_service.dart';
import '../widgets/result_card.dart';
import '../widgets/formula_display.dart';

class ImPoolScreen extends StatefulWidget {
  const ImPoolScreen({super.key});

  @override
  State<ImPoolScreen> createState() => _ImPoolScreenState();
}

class _ImPoolScreenState extends State<ImPoolScreen> {
  final _pontaCtrl = TextEditingController(text: '22,00');
  final _baseCtrl = TextEditingController(text: '18,00');
  final _poolBrixCtrl = TextEditingController(text: '20,00');

  double get _ponta => CalcService.parseBR(_pontaCtrl.text);
  double get _base => CalcService.parseBR(_baseCtrl.text);
  double get _im => CalcService.calcIM(_ponta, _base);
  double get _pool => CalcService.calcPool(CalcService.parseBR(_poolBrixCtrl.text));

  Color _imColor(double im) {
    if (im < 0.85) return Colors.orange;
    if (im <= 1.0) return Colors.green;
    return Colors.red;
  }

  @override
  void initState() {
    super.initState();
    for (final c in [_pontaCtrl, _baseCtrl, _poolBrixCtrl]) {
      c.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    _pontaCtrl.dispose();
    _baseCtrl.dispose();
    _poolBrixCtrl.dispose();
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
            _sectionTitle('Índice de Maturação (IM)'),
            const SizedBox(height: 12),
            _inputField('Brix da ponta do colmo', _pontaCtrl),
            const SizedBox(height: 10),
            _inputField('Brix da base do colmo', _baseCtrl),
            const SizedBox(height: 12),
            ResultCard(
              label: 'IM',
              value: CalcService.formatBR(_im),
              interpretation: CalcService.interpretarIM(_im),
              interpretationColor: _imColor(_im),
            ),
            const SizedBox(height: 8),
            const FormulaDisplay(formula: 'IM = Brix ponta ÷ Brix base'),
            const SizedBox(height: 24),
            _sectionTitle('Pool (%)'),
            const SizedBox(height: 12),
            _inputField('Brix', _poolBrixCtrl),
            const SizedBox(height: 12),
            ResultCard(label: 'Pool (%)', value: CalcService.formatBR(_pool)),
            const SizedBox(height: 8),
            const FormulaDisplay(formula: 'Pool = 1,0179 × Brix − 3,0614'),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String t) => Text(t,
      style: GoogleFonts.outfit(
          fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF003819)));

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
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFF003819), width: 2)),
            ),
          ),
        ],
      );
}
