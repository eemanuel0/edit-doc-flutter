class PreferenciasUsuario {
  const PreferenciasUsuario({required this.tema, required this.tamanhoFonte});

  final String tema;
  final double tamanhoFonte;
}

class PreferencesService {
  final Map<String, Object> _armazenamento = {};

  Future<void> salvar({
    required String tema,
    required double tamanhoFonte,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    _armazenamento['tema_app'] = tema;
    _armazenamento['tamanho_fonte'] = tamanhoFonte;
  }

  Future<PreferenciasUsuario> carregar() async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    final tema = _armazenamento['tema_app'];
    final valor = _armazenamento['tamanho_fonte'];
    final fonte = valor is num ? valor.toDouble() : 16.0;

    return PreferenciasUsuario(
      tema: tema == 'escuro' ? 'escuro' : 'claro',
      tamanhoFonte: fonte.isFinite
          ? fonte.clamp(12.0, 24.0).toDouble()
          : 16.0,
    );
  }
}
