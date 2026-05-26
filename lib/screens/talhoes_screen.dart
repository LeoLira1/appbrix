import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:uuid/uuid.dart';
import '../models/talhao.dart';
import '../models/produtor.dart';
import '../models/amostra.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../services/sync_service.dart';
import '../services/location_service.dart';

class TalhoesScreen extends StatefulWidget {
  const TalhoesScreen({super.key});

  @override
  State<TalhoesScreen> createState() => _TalhoesScreenState();
}

class _TalhoesScreenState extends State<TalhoesScreen> {
  List<Talhao> _talhoes = [];
  List<Produtor> _produtores = [];
  List<Amostra> _amostras = [];
  String? _filtroProdutor;
  bool _showMapa = false;
  bool _loading = true;

  final _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    final uid = AuthService.instance.usuarioId;
    final t = await DatabaseService.instance.getTalhoes(uid);
    final p = await DatabaseService.instance.getProdutores(uid);
    final a = await DatabaseService.instance.getAmostras(uid);
    if (mounted) setState(() { _talhoes = t; _produtores = p; _amostras = a; _loading = false; });
  }

  List<Talhao> get _filtrados {
    if (_filtroProdutor == null) return _talhoes;
    return _talhoes.where((t) => t.produtorId == _filtroProdutor).toList();
  }

  String _nomeProd(String? id) {
    if (id == null) return '—';
    try { return _produtores.firstWhere((p) => p.id == id).nome; } catch (_) { return '—'; }
  }

  Future<void> _deletar(Talhao t) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: Text('Remover talhão "${t.nome}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(context, true),
              child: const Text('Remover', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (ok == true) {
      await DatabaseService.instance.deletarTalhao(t.id);
      await _carregar();
    }
  }

  void _novoTalhao() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _NovoTalhaoSheet(
        produtores: _produtores,
        amostras: _amostras,
        onSaved: () async { Navigator.pop(context); await _carregar(); },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtrados = _filtrados;
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
                  child: Row(
                    children: [
                      Expanded(
                        child: _produtores.isEmpty
                            ? const SizedBox()
                            : DropdownButtonFormField<String?>(
                                value: _filtroProdutor,
                                decoration: InputDecoration(
                                  labelText: 'Filtrar por produtor',
                                  filled: true,
                                  fillColor: Colors.white,
                                  isDense: true,
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                items: [
                                  const DropdownMenuItem(value: null, child: Text('Todos')),
                                  ..._produtores.map((p) =>
                                      DropdownMenuItem(value: p.id, child: Text(p.nome))),
                                ],
                                onChanged: (v) => setState(() => _filtroProdutor = v),
                              ),
                      ),
                      const SizedBox(width: 8),
                      ToggleButtons(
                        isSelected: [!_showMapa, _showMapa],
                        onPressed: (i) => setState(() => _showMapa = i == 1),
                        borderRadius: BorderRadius.circular(8),
                        selectedColor: Colors.white,
                        fillColor: const Color(0xFF003819),
                        children: const [
                          Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('Lista')),
                          Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('Mapa')),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _showMapa ? _buildMapa(filtrados) : _buildLista(filtrados),
                ),
              ],
            ),
      );
  }

  Widget _buildLista(List<Talhao> lista) {
    if (lista.isEmpty) {
      return Center(child: Text('Nenhum talhão', style: GoogleFonts.outfit(color: Colors.grey)));
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      itemCount: lista.length,
      itemBuilder: (_, i) {
        final t = lista[i];
        return Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: Icon(Icons.grass, color: const Color(0xFF003819)),
            title: Text(t.nome, style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
            subtitle: Text('${_nomeProd(t.produtorId)} • ${t.dataHora.substring(0, 10)}\n'
                'Lat: ${t.latitude.toStringAsFixed(4)} Lon: ${t.longitude.toStringAsFixed(4)}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(t.sincronizado ? Icons.cloud_done : Icons.cloud_off,
                    size: 16, color: t.sincronizado ? Colors.green : Colors.orange),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => _deletar(t),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMapa(List<Talhao> lista) {
    final center = lista.isEmpty
        ? LatLng(-15.0, -50.0)
        : LatLng(lista.first.latitude, lista.first.longitude);
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(initialCenter: center, initialZoom: 13),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.brix.interpretation',
        ),
        MarkerLayer(
          markers: lista.map((t) => Marker(
            point: LatLng(t.latitude, t.longitude),
            width: 40,
            height: 40,
            child: GestureDetector(
              onTap: () => showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: Text(t.nome),
                  content: Text(
                    'Produtor: ${_nomeProd(t.produtorId)}\n'
                    'Lat: ${t.latitude.toStringAsFixed(5)}\n'
                    'Lon: ${t.longitude.toStringAsFixed(5)}\n'
                    '${t.observacoes ?? ''}',
                  ),
                  actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Fechar'))],
                ),
              ),
              child: const Icon(Icons.location_pin, color: Color(0xFF003819), size: 36),
            ),
          )).toList(),
        ),
      ],
    );
  }
}

class _NovoTalhaoSheet extends StatefulWidget {
  final List<Produtor> produtores;
  final List<Amostra> amostras;
  final VoidCallback onSaved;

  const _NovoTalhaoSheet({required this.produtores, required this.amostras, required this.onSaved});

  @override
  State<_NovoTalhaoSheet> createState() => _NovoTalhaoSheetState();
}

class _NovoTalhaoSheetState extends State<_NovoTalhaoSheet> {
  final _nomeCtrl = TextEditingController();
  final _obsCtrl = TextEditingController();
  String? _produtorId;
  String? _amostraId;
  double? _lat;
  double? _lon;
  bool _gpsLoading = false;
  bool _saving = false;

  Future<void> _capturarGPS() async {
    setState(() => _gpsLoading = true);
    try {
      final pos = await LocationService.getPosicaoAtual();
      setState(() { _lat = pos.latitude; _lon = pos.longitude; });
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _gpsLoading = false);
    }
  }

  Future<void> _salvar() async {
    if (_nomeCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Informe o nome do talhão')));
      return;
    }
    setState(() => _saving = true);
    final t = Talhao(
      id: const Uuid().v4(),
      usuarioId: AuthService.instance.usuarioId,
      produtorId: _produtorId,
      nome: _nomeCtrl.text.trim(),
      latitude: _lat ?? 0,
      longitude: _lon ?? 0,
      dataHora: DateTime.now().toIso8601String(),
      observacoes: _obsCtrl.text.trim().isEmpty ? null : _obsCtrl.text.trim(),
      amostraId: _amostraId,
    );
    await SyncService.instance.salvarTalhao(t);
    widget.onSaved();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.of(context).viewInsets.bottom + 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Novo Talhão', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF003819))),
          const SizedBox(height: 12),
          TextField(
            controller: _nomeCtrl,
            decoration: _dec('Nome/ID do talhão *'),
          ),
          const SizedBox(height: 10),
          if (widget.produtores.isNotEmpty)
            DropdownButtonFormField<String?>(
              value: _produtorId,
              decoration: _dec('Produtor'),
              items: [const DropdownMenuItem(value: null, child: Text('Nenhum')),
                ...widget.produtores.map((p) => DropdownMenuItem(value: p.id, child: Text(p.nome)))],
              onChanged: (v) => setState(() => _produtorId = v),
            ),
          const SizedBox(height: 10),
          if (widget.amostras.isNotEmpty)
            DropdownButtonFormField<String?>(
              value: _amostraId,
              decoration: _dec('Vincular amostra'),
              items: [const DropdownMenuItem(value: null, child: Text('Nenhuma')),
                ...widget.amostras.map((a) => DropdownMenuItem(value: a.id, child: Text('Nº ${a.numero}')))],
              onChanged: (v) => setState(() => _amostraId = v),
            ),
          const SizedBox(height: 10),
          TextField(controller: _obsCtrl, decoration: _dec('Observações')),
          const SizedBox(height: 10),
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: _gpsLoading ? null : _capturarGPS,
                icon: _gpsLoading
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.gps_fixed),
                label: const Text('Capturar GPS'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF003819),
                  foregroundColor: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              if (_lat != null)
                Expanded(child: Text(
                  'Lat: ${_lat!.toStringAsFixed(4)}\nLon: ${_lon!.toStringAsFixed(4)}',
                  style: GoogleFonts.outfit(fontSize: 12),
                )),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saving ? null : _salvar,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8ac53a),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: _saving
                  ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                  : Text('Salvar', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _dec(String label) => InputDecoration(
    labelText: label,
    filled: true, fillColor: Colors.white,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF003819), width: 2)),
    isDense: true,
  );
}
