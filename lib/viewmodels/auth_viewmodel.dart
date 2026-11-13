import 'package:flutter/foundation.dart';
import '../models/services/banco_local_service.dart';
import '../models/services/preferences_service.dart';
import '../models/usuario.dart';
import '../utils/validadores.dart';

class AuthViewModel extends ChangeNotifier {
  AuthViewModel({
    required BancoLocalService banco,
    required PreferencesService preferences,
  }) : _banco = banco,
       _preferences = preferences;

  final BancoLocalService _banco;
  final PreferencesService _preferences;

  Usuario? _usuarioAtual;
  bool _carregandoLogin = false;
  bool _salvandoCadastro = false;
  String? _erro;
  String _tema = 'claro';
  double _tamanhoFonte = 16;
  String _temaCadastro = 'claro';
  double _fonteCadastro = 16;
  bool _descartado = false;

  Usuario? get usuarioAtual => _usuarioAtual;
  bool get carregandoLogin => _carregandoLogin;
  bool get salvandoCadastro => _salvandoCadastro;
  String? get erro => _erro;
  String get tema => _tema;
  bool get temaEscuro => _tema == 'escuro';
  double get tamanhoFonte => _tamanhoFonte;
  String get temaCadastro => _temaCadastro;
  double get fonteCadastro => _fonteCadastro;

  Future<void> inicializar() => recarregarPreferencias();

  Future<void> recarregarPreferencias() async {
    final preferencias = await _preferences.carregar();
    if (_descartado) return;

    _tema = _normalizarTema(preferencias.tema);
    _tamanhoFonte = _normalizarFonte(preferencias.tamanhoFonte);
    _notificar();
  }

  void prepararCadastro() {
    if (_salvandoCadastro) return;
    _temaCadastro = 'claro';
    _fonteCadastro = 16;
    _erro = null;
    _notificar();
  }

  void definirTemaCadastro(String valor) {
    if (_salvandoCadastro) return;
    final tema = _normalizarTema(valor);
    if (_temaCadastro == tema) return;
    _temaCadastro = tema;
    _notificar();
  }

  void definirFonteCadastro(double valor) {
    if (_salvandoCadastro) return;
    final fonte = _normalizarFonte(valor);
    if (_fonteCadastro == fonte) return;
    _fonteCadastro = fonte;
    _notificar();
  }

  Future<bool> login({
    required String email,
    required String senha,
  }) async {
    if (_carregandoLogin || _descartado) return false;

    _erro = validarEmail(email) ?? validarSenha(senha);
    if (_erro != null) {
      _notificar();
      return false;
    }

    _carregandoLogin = true;
    _notificar();

    try {
      final usuario = await _banco.buscarPorEmail(email.trim().toLowerCase());
      if (_descartado) return false;

      if (usuario == null) {
        _erro = 'E-mail não cadastrado. Toque em "Cadastre-se".';
        return false;
      }

      if (usuario.senha != senha) {
        _erro = 'Senha incorreta.';
        return false;
      }

      _usuarioAtual = usuario;
      return true;
    } catch (_) {
      _erro = 'Não foi possível entrar. Tente novamente.';
      return false;
    } finally {
      _carregandoLogin = false;
      _notificar();
    }
  }

  Future<bool> cadastrar({
    required String nome,
    required String email,
    required String senha,
  }) async {
    if (_salvandoCadastro || _descartado) return false;

    _erro = validarNome(nome) ?? validarEmail(email) ?? validarSenha(senha);
    if (_erro != null) {
      _notificar();
      return false;
    }

    final temaEscolhido = _temaCadastro;
    final fonteEscolhida = _fonteCadastro;
    final usuario = Usuario(
      nome: nome.trim(),
      email: email.trim().toLowerCase(),
      senha: senha,
    );

    _salvandoCadastro = true;
    _notificar();

    try {
      final inseriu = await _banco.inserirUsuario(usuario);
      if (_descartado) return false;

      if (!inseriu) {
        _erro = 'Este e-mail já está cadastrado.';
        return false;
      }

      await _preferences.salvar(
        tema: temaEscolhido,
        tamanhoFonte: fonteEscolhida,
      );
      if (_descartado) return false;

      _tema = temaEscolhido;
      _tamanhoFonte = fonteEscolhida;
      return true;
    } catch (_) {
      _erro = 'Não foi possível cadastrar. Tente novamente.';
      return false;
    } finally {
      _salvandoCadastro = false;
      _notificar();
    }
  }

  Future<void> definirTema(String valor) async {
    _tema = _normalizarTema(valor);
    _notificar();
    await salvarPreferencias();
  }

  Future<void> definirFonte(double valor, {bool persistir = true}) async {
    _tamanhoFonte = _normalizarFonte(valor);
    _notificar();
    if (persistir) await salvarPreferencias();
  }

  Future<void> salvarPreferencias() async {
    try {
      await _preferences.salvar(tema: _tema, tamanhoFonte: _tamanhoFonte);
    } catch (_) {
      _erro = 'Não foi possível salvar as preferências.';
      _notificar();
    }
  }

  Future<List<Usuario>> listarUsuarios() => _banco.listarUsuarios();

  void sair() {
    _usuarioAtual = null;
    _erro = null;
    _notificar();
  }

  static String _normalizarTema(String valor) =>
      valor == 'escuro' ? 'escuro' : 'claro';

  static double _normalizarFonte(double valor) =>
      valor.isFinite ? valor.clamp(12.0, 24.0).toDouble() : 16.0;

  void _notificar() {
    if (!_descartado) notifyListeners();
  }

  @override
  void dispose() {
    _descartado = true;
    super.dispose();
  }
}
