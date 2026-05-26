import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import '../models/produtor.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../services/sync_service.dart';

class ProdutoresScreen extends StatefulWidget {
  const ProdutoresScreen({super.key});

  @override
  State<ProdutoresScreen> createState() => _ProdutoresScreenState();
}

class _ProdutoresScreenState extends State<ProdutoresScreen> {
  List<Produtor> _produtores = [];
  String _busca = '';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    final uid = AuthService.instance.usuarioId;
    final lista = await DatabaseService.instance.getProdutores(uid);
    if (mounted) setState(() { _produtores = lista; _loading = false; });
  }

  List<Produtor> get _filtrados => _produtores
      .where((p) => p.nome.toLowerCase().contains(_busca.toLowerCase()))
      .toList();

  Future<void> _deletar(Produtor p) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: Text('Remover produtor "${p.nome}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(context, true),
              child: const Text('Remover', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (ok == true) {
      await DatabaseService.instance.deletarProdutor(p.id);
      await _carregar();
    }
  }

  void _abrirForm({Produtor? produtor}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _ProdutorSheet(
        produtor: produtor,
        onSaved: () async { Navigator.pop(context); await _carregar(); },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtrados = _filtrados;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
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
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Buscar produtor...',
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        isDense: true,
                      ),
                      onChanged: (v) => setState(() => _busca = v),
                    ),
                  ),
                  Expanded(
                    child: filtrados.isEmpty
                        ? Center(child: Text('Nenhum produtor', style: GoogleFonts.outfit(color: Colors.grey)))
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            itemCount: filtrados.length,
                            itemBuilder: (_, i) {
                              final p = filtrados[i];
                              return Card(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                margin: const EdgeInsets.only(bottom: 8),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: const Color(0xFF003819),
                                    child: Text(p.nome[0].toUpperCase(),
                                        style: const TextStyle(color: Colors.white)),
                                  ),
                                  title: Text(p.nome, style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                                  subtitle: Text([
                                    if (p.fazenda != null) p.fazenda!,
                                    if (p.municipio != null) p.municipio!,
                                    if (p.telefone != null) p.telefone!,
                                  ].join(' • ')),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit_outlined, color: Color(0xFF003819)),
                                        onPressed: () => _abrirForm(produtor: p),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                                        onPressed: () => _deletar(p),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _abrirForm(),
        backgroundColor: const Color(0xFF003819),
        child: const Icon(Icons.add, color: Color(0xFF8ac53a)),
      ),
    );
  }
}

class _ProdutorSheet extends StatefulWidget {
  final Produtor? produtor;
  final VoidCallback onSaved;

  const _ProdutorSheet({this.produtor, required this.onSaved});

  @override
  State<_ProdutorSheet> createState() => _ProdutorSheetState();
}

class _ProdutorSheetState extends State<_ProdutorSheet> {
  late final TextEditingController _nomeCtrl;
  late final TextEditingController _fazendaCtrl;
  late final TextEditingController _municipioCtrl;
  late final TextEditingController _telefoneCtrl;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nomeCtrl = TextEditingController(text: widget.produtor?.nome ?? '');
    _fazendaCtrl = TextEditingController(text: widget.produtor?.fazenda ?? '');
    _municipioCtrl = TextEditingController(text: widget.produtor?.municipio ?? '');
    _telefoneCtrl = TextEditingController(text: widget.produtor?.telefone ?? '');
  }

  Future<void> _salvar() async {
    if (_nomeCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Informe o nome do produtor')));
      return;
    }
    setState(() => _saving = true);
    final uid = AuthService.instance.usuarioId;
    final p = Produtor(
      id: widget.produtor?.id ?? const Uuid().v4(),
      usuarioId: uid,
      nome: _nomeCtrl.text.trim(),
      fazenda: _fazendaCtrl.text.trim().isEmpty ? null : _fazendaCtrl.text.trim(),
      municipio: _municipioCtrl.text.trim().isEmpty ? null : _municipioCtrl.text.trim(),
      telefone: _telefoneCtrl.text.trim().isEmpty ? null : _telefoneCtrl.text.trim(),
      dataCriacao: widget.produtor?.dataCriacao ?? DateTime.now().toIso8601String(),
    );
    await SyncService.instance.salvarProdutor(p);
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
          Text(widget.produtor == null ? 'Novo Produtor' : 'Editar Produtor',
              style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF003819))),
          const SizedBox(height: 12),
          _field(_nomeCtrl, 'Nome completo *'),
          const SizedBox(height: 10),
          _field(_fazendaCtrl, 'Fazenda'),
          const SizedBox(height: 10),
          _field(_municipioCtrl, 'Município'),
          const SizedBox(height: 10),
          _field(_telefoneCtrl, 'Telefone', type: TextInputType.phone),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saving ? null : _salvar,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF003819),
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

  Widget _field(TextEditingController c, String label, {TextInputType? type}) => TextField(
    controller: c,
    keyboardType: type,
    decoration: InputDecoration(
      labelText: label,
      filled: true, fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF003819), width: 2)),
      isDense: true,
    ),
  );
}
