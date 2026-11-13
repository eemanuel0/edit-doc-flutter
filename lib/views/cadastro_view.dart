// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import '../utils/validadores.dart';
import '../viewmodels/auth_viewmodel.dart';

class CadastroView extends StatefulWidget {
  const CadastroView({super.key, required this.auth});

  final AuthViewModel auth;

  @override
  State<CadastroView> createState() => _CadastroViewState();
}

class _CadastroViewState extends State<CadastroView> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  void _mensagem(String texto) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(texto)));
  }

  Future<void> _cadastrar() async {
    if (widget.auth.salvandoCadastro ||
        _formKey.currentState?.validate() != true) {
      return;
    }

    final sucesso = await widget.auth.cadastrar(
      nome: _nomeController.text,
      email: _emailController.text,
      senha: _senhaController.text,
    );

    if (!mounted) return;

    if (!sucesso) {
      _mensagem(widget.auth.erro ?? 'Não foi possível cadastrar.');
      return;
    }

    _mensagem('Usuário cadastrado com sucesso!');
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.auth,
      builder: (context, _) {
        final auth = widget.auth;
        final salvando = auth.salvandoCadastro;

        return Scaffold(
          appBar: AppBar(title: const Text('Cadastro de Usuário')),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  TextFormField(
                    controller: _nomeController,
                    decoration: const InputDecoration(
                      labelText: 'Nome Completo',
                      border: OutlineInputBorder(),
                    ),
                    validator: validarNome,
                  ),
                  const SizedBox(height: 12),
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
                  const Text(
                    'Tema do app',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  RadioGroup<String>(
                    groupValue: auth.temaCadastro,
                    onChanged: (valor) {
                      if (valor != null && !salvando) {
                        auth.definirTemaCadastro(valor);
                      }
                    },
                    child: Column(
                      children: [
                        RadioListTile<String>(
                          title: const Text('Tema Claro'),
                          value: 'claro',
                          enabled: !salvando,
                        ),
                        RadioListTile<String>(
                          title: const Text('Tema Escuro'),
                          value: 'escuro',
                          enabled: !salvando,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Tamanho da fonte dos documentos: '
                    '${auth.fonteCadastro.round()}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Slider(
                    min: 12,
                    max: 24,
                    divisions: 6,
                    value: auth.fonteCadastro,
                    label: '${auth.fonteCadastro.round()}',
                    onChanged: salvando ? null : auth.definirFonteCadastro,
                  ),
                  Text(
                    'Exemplo de texto neste tamanho.',
                    style: TextStyle(fontSize: auth.fonteCadastro),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: salvando ? null : _cadastrar,
                    child: salvando
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('Cadastrar'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
