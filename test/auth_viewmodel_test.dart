import 'package:flutter_test/flutter_test.dart';
import 'package:edit_doc_flutter/models/services/banco_local_service.dart';
import 'package:edit_doc_flutter/models/services/preferences_service.dart';
import 'package:edit_doc_flutter/viewmodels/auth_viewmodel.dart';

void main() {
  late BancoLocalService banco;
  late PreferencesService preferences;
  late AuthViewModel auth;

  setUp(() {
    banco = BancoLocalService();
    preferences = PreferencesService();
    auth = AuthViewModel(banco: banco, preferences: preferences);
  });

  tearDown(() => auth.dispose());

  test('cadastro salva escolhas, normaliza e-mail e exige login separado', () async {
    auth.prepararCadastro();
    auth.definirTemaCadastro('escuro');
    auth.definirFonteCadastro(20);

    expect(
      await auth.cadastrar(
        nome: '  Emanuel Nascimento  ',
        email: '  EMANUEL@EXEMPLO.COM  ',
        senha: '123456',
      ),
      isTrue,
    );

    expect(auth.usuarioAtual, isNull);
    expect(auth.temaEscuro, isTrue);
    expect(auth.tamanhoFonte, 20);
    expect(auth.salvandoCadastro, isFalse);

    final usuarios = await auth.listarUsuarios();
    expect(usuarios.single.nome, 'Emanuel Nascimento');
    expect(usuarios.single.email, 'emanuel@exemplo.com');

    expect(
      await auth.login(
        email: ' EMANUEL@EXEMPLO.COM ',
        senha: '123456',
      ),
      isTrue,
    );

    expect(auth.usuarioAtual, same(usuarios.single));
    expect(auth.erro, isNull);

    auth.sair();
    expect(auth.usuarioAtual, isNull);
    expect(auth.temaEscuro, isTrue);
  });

  test('cadastro rejeita e-mail duplicado com diferença de caixa', () async {
    expect(
      await auth.cadastrar(
        nome: 'Primeiro Usuário',
        email: 'conta@exemplo.com',
        senha: '123456',
      ),
      isTrue,
    );

    expect(
      await auth.cadastrar(
        nome: 'Outro Usuário',
        email: ' CONTA@EXEMPLO.COM ',
        senha: 'abcdef',
      ),
      isFalse,
    );

    expect(auth.erro, 'Este e-mail já está cadastrado.');
    expect((await banco.listarUsuarios()).length, 1);
    expect(auth.salvandoCadastro, isFalse);
  });

  test('falhas de autenticação encerram o loading e mantêm sessão vazia', () async {
    final estados = <bool>[];
    auth.addListener(() => estados.add(auth.carregandoLogin));

    expect(
      await auth.login(
        email: 'ausente@exemplo.com',
        senha: '123456',
      ),
      isFalse,
    );

    expect(auth.usuarioAtual, isNull);
    expect(auth.erro, contains('não cadastrado'));
    expect(estados, containsAllInOrder([true, false]));

    await auth.cadastrar(
      nome: 'Pessoa Teste',
      email: 'pessoa@exemplo.com',
      senha: '123456',
    );

    expect(
      await auth.login(
        email: 'pessoa@exemplo.com',
        senha: 'errada',
      ),
      isFalse,
    );

    expect(auth.erro, 'Senha incorreta.');
    expect(auth.usuarioAtual, isNull);
    expect(auth.carregandoLogin, isFalse);
  });

  test('entrada inválida não cria usuário nem inicia sessão', () async {
    expect(
      await auth.cadastrar(
        nome: 'A',
        email: 'sem-arroba.com',
        senha: '1',
      ),
      isFalse,
    );

    expect(await banco.listarUsuarios(), isEmpty);
    expect(auth.erro, isNotNull);
    expect(auth.usuarioAtual, isNull);
    expect(auth.salvandoCadastro, isFalse);
  });

  test('preferências podem ser recarregadas e fonte respeita limites', () async {
    await auth.definirTema('escuro');
    await auth.definirFonte(22);

    final outraInstancia = AuthViewModel(
      banco: banco,
      preferences: preferences,
    );
    addTearDown(outraInstancia.dispose);

    await outraInstancia.inicializar();
    expect(outraInstancia.tema, 'escuro');
    expect(outraInstancia.tamanhoFonte, 22);

    await auth.definirFonte(100);
    expect(auth.tamanhoFonte, 24);

    await auth.definirFonte(1);
    expect(auth.tamanhoFonte, 12);

    await auth.definirFonte(double.nan);
    expect(auth.tamanhoFonte, 16);

    auth.definirTemaCadastro('escuro');
    auth.definirFonteCadastro(24);
    auth.prepararCadastro();

    expect(auth.temaCadastro, 'claro');
    expect(auth.fonteCadastro, 16);
  });
}
