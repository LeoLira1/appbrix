import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/amostra.dart';
import '../models/talhao.dart';
import '../models/produtor.dart';

class DatabaseService {
  DatabaseService._();
  static final DatabaseService instance = DatabaseService._();

  Database? _db;

  Future<void> init() async {
    final path = join(await getDatabasesPath(), 'brix.db');
    _db = await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Database get db {
    if (_db == null) throw StateError('DB não inicializado');
    return _db!;
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE amostras (
        id TEXT PRIMARY KEY,
        usuario_id TEXT NOT NULL,
        produtor_id TEXT,
        numero INTEGER,
        brix REAL,
        brix_ponta REAL,
        brix_base REAL,
        data_hora TEXT,
        sincronizado INTEGER DEFAULT 0
      )
    ''');
    await db.execute('''
      CREATE TABLE talhoes (
        id TEXT PRIMARY KEY,
        usuario_id TEXT NOT NULL,
        produtor_id TEXT,
        nome TEXT NOT NULL,
        latitude REAL,
        longitude REAL,
        data_hora TEXT,
        observacoes TEXT,
        amostra_id TEXT,
        sincronizado INTEGER DEFAULT 0
      )
    ''');
    await db.execute('''
      CREATE TABLE produtores (
        id TEXT PRIMARY KEY,
        usuario_id TEXT NOT NULL,
        nome TEXT NOT NULL,
        fazenda TEXT,
        municipio TEXT,
        telefone TEXT,
        data_criacao TEXT,
        sincronizado INTEGER DEFAULT 0
      )
    ''');
  }

  // AMOSTRAS
  Future<void> inserirAmostra(Amostra a) async {
    await db.insert('amostras', a.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Amostra>> getAmostras(String usuarioId) async {
    final rows = await db.query('amostras',
        where: 'usuario_id = ?', whereArgs: [usuarioId]);
    return rows.map(Amostra.fromMap).toList();
  }

  Future<List<Amostra>> getAmostrasProdutor(
      String usuarioId, String produtorId) async {
    final rows = await db.query('amostras',
        where: 'usuario_id = ? AND produtor_id = ?',
        whereArgs: [usuarioId, produtorId]);
    return rows.map(Amostra.fromMap).toList();
  }

  Future<List<Amostra>> getAmostrasPendentes() async {
    final rows = await db
        .query('amostras', where: 'sincronizado = ?', whereArgs: [0]);
    return rows.map(Amostra.fromMap).toList();
  }

  Future<void> deletarAmostra(String id) async {
    await db.delete('amostras', where: 'id = ?', whereArgs: [id]);
  }

  // TALHOES
  Future<void> inserirTalhao(Talhao t) async {
    await db.insert('talhoes', t.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Talhao>> getTalhoes(String usuarioId) async {
    final rows = await db.query('talhoes',
        where: 'usuario_id = ?', whereArgs: [usuarioId]);
    return rows.map(Talhao.fromMap).toList();
  }

  Future<List<Talhao>> getTalhoesPendentes() async {
    final rows = await db
        .query('talhoes', where: 'sincronizado = ?', whereArgs: [0]);
    return rows.map(Talhao.fromMap).toList();
  }

  Future<void> deletarTalhao(String id) async {
    await db.delete('talhoes', where: 'id = ?', whereArgs: [id]);
  }

  // PRODUTORES
  Future<void> inserirProdutor(Produtor p) async {
    await db.insert('produtores', p.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Produtor>> getProdutores(String usuarioId) async {
    final rows = await db.query('produtores',
        where: 'usuario_id = ?', whereArgs: [usuarioId]);
    return rows.map(Produtor.fromMap).toList();
  }

  Future<List<Produtor>> getProdutoresPendentes() async {
    final rows = await db
        .query('produtores', where: 'sincronizado = ?', whereArgs: [0]);
    return rows.map(Produtor.fromMap).toList();
  }

  Future<void> deletarProdutor(String id) async {
    await db.delete('produtores', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> marcarSincronizado(String tabela, String id) async {
    await db.update(tabela, {'sincronizado': 1},
        where: 'id = ?', whereArgs: [id]);
  }
}
