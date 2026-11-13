// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:edit_doc_flutter/main.dart';
import 'package:edit_doc_flutter/models/services/banco_local_service.dart';
import 'package:edit_doc_flutter/models/services/preferences_service.dart';
import 'package:edit_doc_flutter/viewmodels/auth_viewmodel.dart';
import 'package:edit_doc_flutter/viewmodels/documentos_viewmodel.dart';

void main() {
  testWidgets('fluxo das três telas, edição, tema e logout', (tester) async {
    tester.view.physicalSize = const Size(1200, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final auth = AuthViewModel(
      banco: BancoLocalService(),
      preferences: PreferencesService(),
    );
    final documentos = DocumentosViewModel();

    await tester.pumpWidget(
      MeuApp(auth: auth, documentos: documentos),
    );
    await tester.pumpAndSettle();

    expect(find.text('Login'), findsOneWidget);

    await tester.tap(find.text('Entrar'));
    await tester.pumpAndSettle();

    expect(find.text('Informe o e-mail'), findsOneWidget);
    expect(
      find.text('A senha deve ter pelo menos 6 caracteres'),
      findsOneWidget,
    );

    await tester.tap(find.text('Não tem uma conta? Cadastre-se'));
    await tester.pumpAndSettle();

    expect(find.text('Cadastro de Usuário'), findsOneWidget);

    await tester.enterText(
      find.byType(TextFormField).at(0),
      'Emanuel Nascimento',
    );
    await tester.enterText(
      find.byType(TextFormField).at(1),
      'emanuel@exemplo.com',
    );
    await tester.enterText(
      find.byType(TextFormField).at(2),
      '123456',
    );

    await tester.tap(find.text('Tema Escuro'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Cadastrar'));
    await tester.tap(find.text('Cadastrar'));
    await tester.pumpAndSettle();

    expect(find.text('Login'), findsOneWidget);
    expect(auth.usuarioAtual, isNull);
    expect(
      tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
      ThemeMode.dark,
    );

    await tester.enterText(
      find.byType(TextFormField).at(0),
      'emanuel@exemplo.com',
    );
    await tester.enterText(
      find.byType(TextFormField).at(1),
      '123456',
    );
    await tester.tap(find.text('Entrar'));
    await tester.pumpAndSettle();

    expect(find.text('Anotações de Emanuel'), findsOneWidget);
    expect(documentos.usuario, same(auth.usuarioAtual));

    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byType(TextFormField),
      'Texto preservado na migração',
    );
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();

    expect(
      documentos.documentoAtual?.conteudo,
      'Texto preservado na migração',
    );
    expect(find.text('Documento salvo!'), findsOneWidget);

    await tester.tap(find.byTooltip('Renomear'));
    await tester.pumpAndSettle();

    final campoNome = find.descendant(
      of: find.byType(AlertDialog),
      matching: find.byType(TextField),
    );
    await tester.enterText(campoNome, 'Trabalho.txt');

    await tester.tap(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text('Salvar'),
      ),
    );
    await tester.pumpAndSettle();

    expect(documentos.documentoAtual?.titulo, 'Trabalho.txt');

    await tester.tap(find.text('Novo'));
    await tester.pumpAndSettle();

    expect(documentos.documentos.length, 2);

    await tester.tap(find.text('Trabalho.txt'));
    await tester.pumpAndSettle();
    expect(documentos.textoAtual, 'Texto preservado na migração');

    await tester.tap(find.text('Ler'));
    await tester.pumpAndSettle();

    expect(find.byType(TextFormField), findsNothing);
    expect(find.text('Texto preservado na migração'), findsOneWidget);

    await tester.tap(find.text('Editar'));
    await tester.pumpAndSettle();
    expect(find.byType(TextFormField), findsOneWidget);

    await tester.tap(find.byTooltip('Configurações'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Tema Claro'));
    await tester.pumpAndSettle();

    expect(
      tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
      ThemeMode.light,
    );

    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();

    tester.view.physicalSize = const Size(360, 360);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    await tester.tap(find.byTooltip('Sair'));
    await tester.pumpAndSettle();

    expect(find.text('Login'), findsOneWidget);
    expect(auth.usuarioAtual, isNull);
    expect(documentos.documentos, isEmpty);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
