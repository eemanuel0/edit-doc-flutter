import '../usuario.dart';

class BancoLocalService {
  final List<Usuario> _usuarios = [];

  Future<bool> inserirUsuario(Usuario usuario) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    final email = usuario.email.trim().toLowerCase();

    if (_usuarios.any((item) => item.email.trim().toLowerCase() == email)) {
      return false;
    }

    _usuarios.add(usuario);
    return true;
  }

  Future<List<Usuario>> listarUsuarios() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return List<Usuario>.unmodifiable(_usuarios);
  }

  Future<Usuario?> buscarPorEmail(String email) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final normalizado = email.trim().toLowerCase();

    for (final usuario in _usuarios) {
      if (usuario.email.trim().toLowerCase() == normalizado) return usuario;
    }

    return null;
  }
}
