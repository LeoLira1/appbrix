import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  final _client = Supabase.instance.client;

  Future<void> login(String email, String senha) async {
    await _client.auth.signInWithPassword(email: email, password: senha);
  }

  Future<void> cadastrar(
      String nome, String email, String senha, String cooperativa) async {
    final response = await _client.auth.signUp(
      email: email,
      password: senha,
      data: {'nome': nome, 'cooperativa': cooperativa},
    );
    if (response.user == null) {
      throw Exception('Cadastro não concluído.');
    }
  }

  Future<void> logout() async {
    await _client.auth.signOut();
  }

  User? get usuarioAtual => _client.auth.currentUser;

  String get nomeUsuario {
    final user = usuarioAtual;
    if (user == null) return '';
    final meta = user.userMetadata;
    if (meta != null && meta['nome'] != null) return meta['nome'] as String;
    return user.email ?? '';
  }

  String get usuarioId => usuarioAtual?.id ?? '';
}
