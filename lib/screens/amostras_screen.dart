import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import '../models/amostra.dart';
import '../models/produtor.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../services/sync_service.dart';
import '../services/calc_service.dart';

class AmostrasScreen extends StatefulWidget {
  const AmostrasScreen({super.key});

  @override
  State<AmostrasScreen> createState() => _AmostrasScreenState();
}

class _AmostrasScreenState extends State<AmostrasScreen> {
  List<Amostra> _amostras = [];
  List<Produtor> _produtores = [];
  String? _produtorSelecionado;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    final uid = AuthService.instance.usuarioId;
    final produtores = await DatabaseService.instance.getProdutores(uid);
    final amostras = await DatabaseService.instance.getAmostras(uid);
    if (mounted) {
      setState(() {
        _produtores = produtores;
        _amostras = amostras;
        _loading = false;
      });
    }
  }

  List<Amostra> get _filtradas {
    if (_produtorSelecionado == null) return _amostras;
    return _amostras.where((a) => a.produtorId == _produtorSelecionado).toList();
  }

  Future<void> _adicionarAmostra() async {
    final uid = AuthService.instance.usuarioId;
    final numero = _amostras.isNotEmpty
        ? _amostras.map((a) => a.numero).reduce((a, b) => a > b ? a : b) + 1
        : 1;
    final nova = Amostra(
      id: const Uuid().v4(),
      usuarioId: uid,
      produtorId: _produtorSelecionado,
      numero: numero,
      brix: 0,
      brixPonta: 0,
      brixBase: 0,
      dataHora: DateTime.now().toIso8601String(),
    );
    await SyncService.instance.salvarAmostra(nova);
    await _carregar();
  }

  Future<void> _deletar(Amostra a) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: Text('Remover amostra Nº ${a.numero}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Remover', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (ok == true) {
      await DatabaseService.instance.deletarAmostra(a.id);
      await _carregar();
    }
  }

  Future<void> _limparTudo() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Limpar tudo'),
        content: const Text('Remover todas as amostras listadas?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Limpar', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (ok == true) {
      for (final a in _filtradas) {
        await DatabaseService.instance.deletarAmostra(a.id);
      }
      await _carregar();
    }
  }

  void _exportarCSV() {
    final rows = _filtradas;
    if (rows.isEmpty) return;
    final buffer = StringBuffer();
    buffer.writeln('Nº,Brix,Brix Ponta,Brix Base,Data/Hora');
    for (final a in rows) {
      buffer.writeln(
          '${a.numero},${a.brix.toStringAsFixed(2)},${a.brixPonta.toStringAsFixed(2)},${a.brixBase.toStringAsFixed(2)},${a.dataHora}');
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('CSV gerado:\n${buffer.toString().substring(0, buffer.length > 200 ? 200 : buffer.length)}...')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtradas = _filtradas;
    final mediaBrix = filtradas.isEmpty
        ? 0.0
        : filtradas.map((a) => a.brix).reduce((a, b) => a + b) / filtradas.length;
    final mediaPonta = filtradas.isEmpty
        ? 0.0
        : filtradas.map((a) => a.brixPonta).reduce((a, b) => a + b) / filtradas.length;
    final mediaBase = filtradas.isEmpty
        ? 0.0
        : filtradas.map((a) => a.brixBase).reduce((a, b) => a + b) / filtradas.length;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFf7fbf3), Color(0xFFe9f3df)],
        ),
      ),
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      if (_produtores.isNotEmpty)
                        DropdownButtonFormField<String?>(
                          value: _produtorSelecionado,
                          decoration: InputDecoration(
                            labelText: 'Filtrar por produtor',
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          items: [
                            const DropdownMenuItem(value: null, child: Text('Todos')),
                            ..._produtores.map((p) =>
                                DropdownMenuItem(value: p.id, child: Text(p.nome))),
                          ],
                          onChanged: (v) => setState(() => _produtorSelecionado = v),
                        ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: _adicionarAmostra,
                            icon: const Icon(Icons.add),
                            label: const Text('Nova'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF003819),
                              foregroundColor: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            onPressed: _limparTudo,
                            icon: const Icon(Icons.clear_all),
                            label: const Text('Limpar'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            onPressed: _exportarCSV,
                            icon: const Icon(Icons.download),
                            label: const Text('CSV'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF8ac53a),
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: filtradas.isEmpty
                      ? Center(
                          child: Text('Nenhuma amostra',
                              style: GoogleFonts.outfit(color: Colors.grey)))
                      : SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            headingRowColor:
                                MaterialStateProperty.all(const Color(0xFF003819).withOpacity(0.1)),
                            columns: const [
                              DataColumn(label: Text('Nº')),
                              DataColumn(label: Text('Brix')),
                              DataColumn(label: Text('Ponta')),
                              DataColumn(label: Text('Base')),
                              DataColumn(label: Text('Sync')),
                              DataColumn(label: Text('')),
                            ],
                            rows: [
                              ...filtradas.map((a) => DataRow(cells: [
                                    DataCell(Text('${a.numero}')),
                                    DataCell(Text(CalcService.formatBR(a.brix))),
                                    DataCell(Text(CalcService.formatBR(a.brixPonta))),
                                    DataCell(Text(CalcService.formatBR(a.brixBase))),
                                    DataCell(Icon(
                                      a.sincronizado ? Icons.cloud_done : Icons.cloud_off,
                                      size: 16,
                                      color: a.sincronizado ? Colors.green : Colors.orange,
                                    )),
                                    DataCell(IconButton(
                                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                                      onPressed: () => _deletar(a),
                                    )),
                                  ])),
                              if (filtradas.isNotEmpty)
                                DataRow(cells: [
                                  DataCell(Text('Média',
                                      style: const TextStyle(fontWeight: FontWeight.bold))),
                                  DataCell(Text(CalcService.formatBR(mediaBrix),
                                      style: const TextStyle(fontWeight: FontWeight.bold))),
                                  DataCell(Text(CalcService.formatBR(mediaPonta),
                                      style: const TextStyle(fontWeight: FontWeight.bold))),
                                  DataCell(Text(CalcService.formatBR(mediaBase),
                                      style: const TextStyle(fontWeight: FontWeight.bold))),
                                  const DataCell(SizedBox()),
                                  const DataCell(SizedBox()),
                                ]),
                            ],
                          ),
                        ),
                ),
              ],
            ),
    );
  }
}
