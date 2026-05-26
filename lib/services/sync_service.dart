import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import '../models/amostra.dart';
import '../models/talhao.dart';
import '../models/produtor.dart';
import 'database_service.dart';

enum SyncStatus { sincronizado, pendente, sincronizando, erro }

class SyncService {
  SyncService._();
  static final SyncService instance = SyncService._();

  final ValueNotifier<SyncStatus> status =
      ValueNotifier(SyncStatus.sincronizado);

  final _db = DatabaseService.instance;
  final _supabase = Supabase.instance.client;

  void iniciarMonitor() {
    Connectivity().onConnectivityChanged.listen((result) {
      if (result != ConnectivityResult.none) {
        sincronizarPendentes();
      }
    });
  }

  Future<bool> temInternet() async {
    final result = await Connectivity().checkConnectivity();
    return result != ConnectivityResult.none;
  }

  Future<void> salvarAmostra(Amostra a) async {
    await _db.inserirAmostra(a);
    if (await temInternet()) {
      try {
        await _supabase.from('amostras').upsert(a.toMap());
        await _db.marcarSincronizado('amostras', a.id);
      } catch (_) {}
    }
    await _atualizarStatus();
  }

  Future<void> salvarTalhao(Talhao t) async {
    await _db.inserirTalhao(t);
    if (await temInternet()) {
      try {
        await _supabase.from('talhoes').upsert(t.toMap());
        await _db.marcarSincronizado('talhoes', t.id);
      } catch (_) {}
    }
    await _atualizarStatus();
  }

  Future<void> salvarProdutor(Produtor p) async {
    await _db.inserirProdutor(p);
    if (await temInternet()) {
      try {
        await _supabase.from('produtores').upsert(p.toMap());
        await _db.marcarSincronizado('produtores', p.id);
      } catch (_) {}
    }
    await _atualizarStatus();
  }

  Future<void> sincronizarPendentes() async {
    status.value = SyncStatus.sincronizando;
    try {
      final amostras = await _db.getAmostrasPendentes();
      final talhoes = await _db.getTalhoesPendentes();
      final produtores = await _db.getProdutoresPendentes();

      for (final item in amostras) {
        await _supabase.from('amostras').upsert(item.toMap());
        await _db.marcarSincronizado('amostras', item.id);
      }
      for (final item in talhoes) {
        await _supabase.from('talhoes').upsert(item.toMap());
        await _db.marcarSincronizado('talhoes', item.id);
      }
      for (final item in produtores) {
        await _supabase.from('produtores').upsert(item.toMap());
        await _db.marcarSincronizado('produtores', item.id);
      }
      status.value = SyncStatus.sincronizado;
    } catch (_) {
      status.value = SyncStatus.erro;
    }
  }

  Future<void> _atualizarStatus() async {
    final amostras = await _db.getAmostrasPendentes();
    final talhoes = await _db.getTalhoesPendentes();
    final produtores = await _db.getProdutoresPendentes();
    final total = amostras.length + talhoes.length + produtores.length;
    status.value = total > 0 ? SyncStatus.pendente : SyncStatus.sincronizado;
  }
}
