import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nomeCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _senhaCtrl = TextEditingController();
  final _confirmarCtrl = TextEditingController();
  final _cooperativaCtrl = TextEditingController();
  bool _loading = false;
  bool _showSenha = false;
  String? _erro;

  Future<void> _cadastrar() async {
    if (_senhaCtrl.text != _confirmarCtrl.text) {
      setState(() => _erro = 'As senhas não conferem.');
      return;
    }
    setState(() { _loading = true; _erro = null; });
    try {
      await AuthService.instance.cadastrar(
        _nomeCtrl.text.trim(),
        _emailCtrl.text.trim(),
        _senhaCtrl.text,
        _cooperativaCtrl.text.trim(),
      );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() => _erro = 'Erro ao cadastrar. Verifique os dados.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFf7fbf3), Color(0xFFe9f3df)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Text('Criar Conta',
                      style: GoogleFonts.outfit(
                          fontSize: 22, fontWeight: FontWeight.bold, color: const Color(0xFF003819))),
                  const SizedBox(height: 24),
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          _field(_nomeCtrl, 'Nome completo', Icons.person_outline),
                          const SizedBox(height: 12),
                          _field(_emailCtrl, 'E-mail', Icons.email_outlined,
                              type: TextInputType.emailAddress),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _senhaCtrl,
                            obscureText: !_showSenha,
                            decoration: _dec('Senha', Icons.lock_outline).copyWith(
                              suffixIcon: IconButton(
                                icon: Icon(_showSenha ? Icons.visibility_off : Icons.visibility),
                                onPressed: () => setState(() => _showSenha = !_showSenha),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          _field(_confirmarCtrl, 'Confirmar senha', Icons.lock_outline,
                              obscure: true),
                          const SizedBox(height: 12),
                          _field(_cooperativaCtrl, 'Cooperativa/Empresa (opcional)',
                              Icons.business_outlined),
                          if (_erro != null) ...[
                            const SizedBox(height: 12),
                            Text(_erro!, style: const TextStyle(color: Colors.red, fontSize: 13)),
                          ],
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _loading ? null : _cadastrar,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF003819),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              child: _loading
                                  ? const SizedBox(height: 20, width: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                  : Text('Cadastrar',
                                      style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold)),
                            ),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text('Já tenho conta',
                                style: GoogleFonts.outfit(color: const Color(0xFF003819))),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(TextEditingController c, String label, IconData icon,
      {TextInputType? type, bool obscure = false}) =>
      TextField(
        controller: c,
        obscureText: obscure,
        keyboardType: type,
        decoration: _dec(label, icon),
      );

  InputDecoration _dec(String label, IconData icon) => InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF003819)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF003819), width: 2)),
        filled: true,
        fillColor: Colors.white,
      );
}
