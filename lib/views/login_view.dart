// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import '../utils/validadores.dart';
import '../viewmodels/auth_viewmodel.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key, required this.auth});

  final AuthViewModel auth;

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  void _mensagem(String texto) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(texto)));
  }

  Future<void> _fazerLogin() async {
    if (widget.auth.carregandoLogin ||
        _formKey.currentState?.validate() != true) {
      return;
    }

    final sucesso = await widget.auth.login(
      email: _emailController.text,
      senha: _senhaController.text,
    );

    if (!mounted) return;

    final usuario = widget.auth.usuarioAtual;
    if (!sucesso || usuario == null) {
      _mensagem(widget.auth.erro ?? 'Não foi possível entrar.');
      return;
    }

    Navigator.pushReplacementNamed(
      context,
      '/home',
      arguments: usuario.nome,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.auth,
      builder: (context, _) {
        final carregando = widget.auth.carregandoLogin;

        return Scaffold(
          appBar: AppBar(title: const Text('Login')),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    Icon(
                      Icons.menu_book,
                      size: 80,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const Text(
                      'Biblioteca de Documentos',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'E-mail',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: validarEmail,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _senhaController,
                      decoration: const InputDecoration(
                        labelText: 'Senha',
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                      validator: validarSenha,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: carregando ? null : _fazerLogin,
                      child: carregando
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Text('Entrar'),
                    ),
                    TextButton(
                      onPressed: carregando
                          ? null
                          : () {
                              widget.auth.prepararCadastro();
                              Navigator.pushNamed(context, '/cadastro');
                            },
                      child: const Text(
                        'Não tem uma conta? Cadastre-se',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
