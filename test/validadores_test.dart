import 'package:flutter_test/flutter_test.dart';
import 'package:edit_doc_flutter/utils/validadores.dart';

void main() {
  test('validações preservam as regras da atividade', () {
    expect(validarNome('Emanuel Nascimento'), isNull);
    expect(validarNome('  '), isNotNull);
    expect(validarNome('Ab'), isNotNull);
    expect(validarSenha('123456'), isNull);
    expect(validarSenha('12345'), isNotNull);

    for (final email in [
      'nome@site.com',
      ' Nome@Site.com.br ',
      'nome.sobrenome@sub.site.com',
    ]) {
      expect(validarEmail(email), isNull, reason: email);
    }

    for (final email in [
      'nome.site.com',
      'nome@@site.com',
      'nome@.com',
      'nome@site.org',
      'nome@ site.com',
    ]) {
      expect(validarEmail(email), isNotNull, reason: email);
    }
  });
}
