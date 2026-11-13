String? validarNome(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Informe o nome completo';
  }
  if (value.trim().length < 3) {
    return 'O nome deve ter pelo menos 3 caracteres';
  }
  return null;
}

String? validarEmail(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Informe o e-mail';
  }

  final email = value.trim().toLowerCase();

  if (!email.contains('@')) {
    return 'O e-mail deve conter o caractere @';
  }

  final partes = email.split('@');

  if (partes.length != 2 || partes[0].isEmpty || partes[1].isEmpty) {
    return 'Formato de e-mail inválido';
  }

  final dominio = partes[1];

  if (!dominio.endsWith('.com') && !dominio.endsWith('.com.br')) {
    return 'O domínio deve terminar em .com ou .com.br';
  }

  final regex = RegExp(r'^[\w.\-+]+@[a-z0-9\-]+(\.[a-z0-9\-]+)*\.com(\.br)?$');

  if (!regex.hasMatch(email)) {
    return 'Formato de e-mail inválido (ex.: nome@site.com)';
  }

  return null;
}

String? validarSenha(String? value) {
  if (value == null || value.length < 6) {
    return 'A senha deve ter pelo menos 6 caracteres';
  }
  return null;
}
