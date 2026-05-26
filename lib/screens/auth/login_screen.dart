import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/auth_service.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _senhaCtrl = TextEditingController();
  bool _loading = false;
  bool _showSenha = false;
  String? _erro;

  Future<void> _login() async {
    setState(() { _loading = true; _erro = null; });
    try {
      await AuthService.instance.login(_emailCtrl.text.trim(), _senhaCtrl.text);
    } catch (e) {
      setState(() => _erro = 'E-mail ou senha inválidos.');
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
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: const Color(0xFF003819),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(Icons.science, color: Color(0xFF8ac53a), size: 44),
                  ),
                  const SizedBox(height: 16),
                  Text('Interpretação de Brix',
                      style: GoogleFonts.outfit(
                          fontSize: 22, fontWeight: FontWeight.bold, color: const Color(0xFF003819))),
                  const SizedBox(height: 4),
                  Text('Cálculo agrícola de cana-de-açúcar',
                      style: GoogleFonts.outfit(fontSize: 13, color: Colors.grey[600])),
                  const SizedBox(height: 32),
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          TextField(
                            controller: _emailCtrl,
                            keyboardType: TextInputType.emailAddress,
                            decoration: _inputDec('E-mail', Icons.email_outlined),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _senhaCtrl,
                            obscureText: !_showSenha,
                            decoration: _inputDec('Senha', Icons.lock_outline).copyWith(
                              suffixIcon: IconButton(
                                icon: Icon(_showSenha ? Icons.visibility_off : Icons.visibility),
                                onPressed: () => setState(() => _showSenha = !_showSenha),
                              ),
                            ),
                          ),
                          if (_erro != null) ...[
                            const SizedBox(height: 12),
                            Text(_erro!, style: const TextStyle(color: Colors.red, fontSize: 13)),
                          ],
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _loading ? null : _login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF003819),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              child: _loading
                                  ? const SizedBox(height: 20, width: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                  : Text('Entrar', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold)),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextButton(
                            onPressed: () => Navigator.push(context,
                                MaterialPageRoute(builder: (_) => const RegisterScreen())),
                            child: Text('Criar conta',
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

  InputDecoration _inputDec(String label, IconData icon) => InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF003819)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF003819))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF003819), width: 2)),
        filled: true,
        fillColor: Colors.white,
      );
}
