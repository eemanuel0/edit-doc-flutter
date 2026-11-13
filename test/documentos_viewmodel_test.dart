import 'package:flutter_test/flutter_test.dart';
import 'package:edit_doc_flutter/models/usuario.dart';
import 'package:edit_doc_flutter/viewmodels/documentos_viewmodel.dart';

void main() {
  late DocumentosViewModel documentos;
  late Usuario primeiro;
  late Usuario segundo;

  setUp(() {
    documentos = DocumentosViewModel();
    primeiro = Usuario(
      nome: 'Primeiro',
      email: 'um@exemplo.com',
      senha: '123456',
    );
    segundo = Usuario(
      nome: 'Segundo',
      email: 'dois@exemplo.com',
      senha: 'abcdef',
    );
  });

  tearDown(() => documentos.dispose());

  test('troca de seleção preserva os textos digitados', () {
    documentos.conectarUsuario(primeiro);
    documentos.atualizarTexto('Texto da primeira nota');
    documentos.novoDocumento();

    expect(documentos.documentos.length, 2);
    expect(documentos.selecionado, 1);
    expect(documentos.textoAtual, isEmpty);
    expect(documentos.documentos.first.conteudo, 'Texto da primeira nota');

    documentos.atualizarTexto('Texto da segunda nota');
    documentos.salvar();
    documentos.selecionar(0);
    expect(documentos.textoAtual, 'Texto da primeira nota');

    documentos.selecionar(1);
    expect(documentos.textoAtual, 'Texto da segunda nota');
  });

  test('cada usuário mantém suas próprias notas e rascunhos', () {
    documentos.conectarUsuario(primeiro);
    documentos.atualizarTexto('Nota privada do primeiro');

    documentos.conectarUsuario(segundo);
    expect(documentos.documentos.length, 1);
    expect(documentos.textoAtual, isEmpty);

    documentos.atualizarTexto('Nota privada do segundo');
    documentos.conectarUsuario(null);
    expect(documentos.documentos, isEmpty);
    expect(documentos.documentoAtual, isNull);

    documentos.conectarUsuario(primeiro);
    expect(documentos.textoAtual, 'Nota privada do primeiro');

    documentos.conectarUsuario(segundo);
    expect(documentos.textoAtual, 'Nota privada do segundo');
  });

  test('renomear valida o nome e leitura impede edição', () {
    documentos.conectarUsuario(primeiro);

    expect(documentos.renomear('   '), isFalse);
    expect(documentos.renomear('  Trabalho.txt  '), isTrue);
    expect(documentos.documentoAtual?.titulo, 'Trabalho.txt');

    documentos.atualizarTexto('Texto preservado');
    documentos.definirModoLeitura(true);
    documentos.atualizarTexto('Tentativa de edição');
    expect(documentos.textoAtual, 'Texto preservado');

    documentos.novoDocumento();
    expect(documentos.modoLeitura, isFalse);
  });

  test('ações sem sessão e índices inválidos são seguros', () {
    documentos.novoDocumento();
    documentos.salvar();
    documentos.selecionar(-1);

    expect(documentos.renomear('Nome.txt'), isFalse);
    expect(documentos.documentos, isEmpty);

    documentos.conectarUsuario(primeiro);
    documentos.atualizarTexto('Rascunho');
    documentos.selecionar(99);

    expect(documentos.selecionado, 0);
    expect(documentos.textoAtual, 'Rascunho');
    expect(() => documentos.documentos.clear(), throwsUnsupportedError);
  });
}
