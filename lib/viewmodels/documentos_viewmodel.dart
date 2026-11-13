import 'package:flutter/foundation.dart';
import '../models/documento.dart';
import '../models/usuario.dart';

class DocumentosViewModel extends ChangeNotifier {
  Usuario? _usuario;
  List<Documento> _documentos = [];
  int _selecionado = 0;
  String _textoAtual = '';
  bool _modoLeitura = false;

  Usuario? get usuario => _usuario;
  List<Documento> get documentos => List.unmodifiable(_documentos);
  int get selecionado => _selecionado;
  String get textoAtual => _textoAtual;
  bool get modoLeitura => _modoLeitura;

  Documento? get documentoAtual =>
      _documentos.isEmpty ? null : _documentos[_selecionado];

  void conectarUsuario(Usuario? usuario) {
    if (identical(_usuario, usuario)) return;
    _guardarTextoAtual();

    _usuario = usuario;
    _documentos = usuario?.documentos ?? [];

    if (usuario != null && _documentos.isEmpty) {
      _documentos.add(Documento(titulo: 'Nova Anotação 1.txt'));
    }

    _selecionado = 0;
    _textoAtual = documentoAtual?.conteudo ?? '';
    _modoLeitura = false;
    notifyListeners();
  }

  void atualizarTexto(String texto) {
    if (documentoAtual == null || _modoLeitura || texto == _textoAtual) return;
    _textoAtual = texto;
    notifyListeners();
  }

  void selecionar(int indice) {
    if (indice < 0 ||
        indice >= _documentos.length ||
        indice == _selecionado) {
      return;
    }

    _guardarTextoAtual();
    _selecionado = indice;
    _textoAtual = _documentos[indice].conteudo;
    notifyListeners();
  }

  void novoDocumento() {
    if (_usuario == null) return;
    _guardarTextoAtual();

    _documentos.add(
      Documento(titulo: 'Nova Anotação ${_documentos.length + 1}.txt'),
    );
    _selecionado = _documentos.length - 1;
    _textoAtual = '';
    _modoLeitura = false;
    notifyListeners();
  }

  void salvar() {
    if (documentoAtual == null) return;
    _guardarTextoAtual();
    notifyListeners();
  }

  bool renomear(String novoNome) {
    final nome = novoNome.trim();
    final documento = documentoAtual;
    if (documento == null || nome.isEmpty) return false;

    documento.titulo = nome;
    notifyListeners();
    return true;
  }

  void definirModoLeitura(bool valor) {
    if (documentoAtual == null || _modoLeitura == valor) return;
    _modoLeitura = valor;
    notifyListeners();
  }

  void _guardarTextoAtual() {
    documentoAtual?.conteudo = _textoAtual;
  }
}
