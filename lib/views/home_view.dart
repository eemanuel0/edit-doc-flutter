// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/documentos_viewmodel.dart';

class HomeView extends StatefulWidget {
  const HomeView({
    super.key,
    required this.auth,
    required this.documentos,
  });

  final AuthViewModel auth;
  final DocumentosViewModel documentos;

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late final TextEditingController _editorController;
  final _nomeDocController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _editorController = TextEditingController(
      text: widget.documentos.textoAtual,
    );
    widget.documentos.addListener(_sincronizarEditor);
  }

  @override
  void didUpdateWidget(covariant HomeView oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.documentos != widget.documentos) {
      oldWidget.documentos.removeListener(_sincronizarEditor);
      widget.documentos.addListener(_sincronizarEditor);
      _sincronizarEditor();
    }
  }

  void _sincronizarEditor() {
    final texto = widget.documentos.textoAtual;
    if (_editorController.text == texto) return;

    _editorController.value = TextEditingValue(
      text: texto,
      selection: TextSelection.collapsed(offset: texto.length),
    );
  }

  @override
  void dispose() {
    widget.documentos.removeListener(_sincronizarEditor);
    _editorController.dispose();
    _nomeDocController.dispose();
    super.dispose();
  }

  void _mensagem(String texto) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(texto),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _mostrarPreferencias() async {
    await widget.auth.recarregarPreferencias();
    if (!mounted) return;

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Preferências salvas'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tema: ${widget.auth.temaEscuro ? 'Escuro' : 'Claro'}',
            ),
            const SizedBox(height: 8),
            Text(
              'Tamanho da fonte: ${widget.auth.tamanhoFonte.round()}',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  Future<void> _mostrarUsuarios() async {
    final usuarios = await widget.auth.listarUsuarios();
    if (!mounted) return;

    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Usuários no banco local (${usuarios.length})',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: usuarios.length,
                itemBuilder: (_, i) => ListTile(
                  leading: CircleAvatar(child: Text('${i + 1}')),
                  title: Text(usuarios[i].nome),
                  subtitle: Text(usuarios[i].email),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _abrirConfiguracoes() async {
    await widget.auth.recarregarPreferencias();
    if (!mounted) return;

    await showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => ListenableBuilder(
        listenable: widget.auth,
        builder: (context, _) => SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Configurações',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                RadioGroup<String>(
                  groupValue: widget.auth.tema,
                  onChanged: (valor) {
                    if (valor != null) {
                      widget.auth.definirTema(valor);
                    }
                  },
                  child: const Column(
                    children: [
                      RadioListTile<String>(
                        title: Text('Tema Claro'),
                        value: 'claro',
                      ),
                      RadioListTile<String>(
                        title: Text('Tema Escuro'),
                        value: 'escuro',
                      ),
                    ],
                  ),
                ),
                Text(
                  'Tamanho da fonte: ${widget.auth.tamanhoFonte.round()}',
                ),
                Slider(
                  min: 12,
                  max: 24,
                  divisions: 6,
                  value: widget.auth.tamanhoFonte,
                  label: '${widget.auth.tamanhoFonte.round()}',
                  onChanged: (valor) => widget.auth.definirFonte(
                    valor,
                    persistir: false,
                  ),
                  onChangeEnd: (_) => widget.auth.salvarPreferencias(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _renomear() async {
    final documento = widget.documentos.documentoAtual;
    if (documento == null) return;

    _nomeDocController.text = documento.titulo;

    final novoNome = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Renomear documento'),
        content: TextField(
          controller: _nomeDocController,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Novo nome',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(
              dialogContext,
              _nomeDocController.text,
            ),
            child: const Text('Salvar'),
          ),
        ],
      ),
    );

    if (!mounted || novoNome == null) return;

    final renomeado = widget.documentos.renomear(novoNome);
    _mensagem(
      renomeado ? 'Documento renomeado!' : 'O nome não pode ficar vazio.',
    );
  }

  void _salvar() {
    widget.documentos.salvar();
    _mensagem('Documento salvo!');
  }

  void _exportarPdf() {
    widget.documentos.salvar();
    final titulo = widget.documentos.documentoAtual?.titulo ?? 'Documento';
    _mensagem('"$titulo" exportado para PDF (simulação).');
  }

  void _sair() {
    widget.documentos.salvar();
    widget.auth.sair();
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  Widget _cartaoInterativo({
    required IconData icone,
    required String titulo,
    required String subtitulo,
    required VoidCallback onTap,
  }) {
    return Card(
      color: corPapelDe(context),
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              Icon(
                icone,
                size: 30,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Flexible(
                      child: Text(
                        subtitulo,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _cartaoPreferencias() => _cartaoInterativo(
    icone: Icons.settings,
    titulo: 'Preferências',
    subtitulo: 'Tema e tamanho da fonte',
    onTap: _mostrarPreferencias,
  );

  Widget _cartaoUsuarios() => _cartaoInterativo(
    icone: Icons.storage,
    titulo: 'Usuários',
    subtitulo: 'Ver usuários cadastrados',
    onTap: _mostrarUsuarios,
  );

  Widget _cabecalhoEditor({required bool compacto}) {
    final documento = widget.documentos.documentoAtual;

    return Row(
      children: [
        Expanded(
          child: Text(
            documento?.titulo ?? '',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.drive_file_rename_outline),
          tooltip: 'Renomear',
          onPressed: _renomear,
        ),
        SegmentedButton<bool>(
          showSelectedIcon: false,
          style: SegmentedButton.styleFrom(
            visualDensity: VisualDensity.compact,
          ),
          segments: [
            ButtonSegment<bool>(
              value: false,
              icon: const Icon(Icons.edit_note),
              label: compacto ? null : const Text('Editar'),
              tooltip: 'Editar',
            ),
            ButtonSegment<bool>(
              value: true,
              icon: const Icon(Icons.chrome_reader_mode_outlined),
              label: compacto ? null : const Text('Ler'),
              tooltip: 'Modo leitura',
            ),
          ],
          selected: {widget.documentos.modoLeitura},
          onSelectionChanged: (escolha) =>
              widget.documentos.definirModoLeitura(escolha.first),
        ),
      ],
    );
  }

  Widget _areaEditor() {
    final borda = Theme.of(context).colorScheme.outline;

    if (widget.documentos.modoLeitura) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: corPapelDe(context),
          border: Border.all(color: borda),
          borderRadius: BorderRadius.circular(8),
        ),
        child: SingleChildScrollView(
          child: Text(
            widget.documentos.textoAtual.isEmpty
                ? '(documento vazio)'
                : widget.documentos.textoAtual,
            style: TextStyle(
              fontSize: widget.auth.tamanhoFonte,
              height: 1.5,
            ),
          ),
        ),
      );
    }

    return TextFormField(
      controller: _editorController,
      onChanged: widget.documentos.atualizarTexto,
      maxLines: null,
      expands: true,
      textAlignVertical: TextAlignVertical.top,
      style: TextStyle(
        fontSize: widget.auth.tamanhoFonte,
        height: 1.4,
      ),
      decoration: InputDecoration(
        hintText: 'Comece a escrever aqui...',
        filled: true,
        fillColor: corPapelDe(context),
        contentPadding: const EdgeInsets.all(16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _barraAcoes() => Row(
    children: [
      Expanded(
        child: ElevatedButton.icon(
          onPressed: widget.documentos.modoLeitura ? null : _salvar,
          icon: const Icon(Icons.save),
          label: const Text('Salvar'),
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: OutlinedButton.icon(
          onPressed: _exportarPdf,
          icon: const Icon(Icons.picture_as_pdf),
          label: const Text('Exportar PDF'),
        ),
      ),
    ],
  );

  Widget _painelEditor({required bool compacto}) => Padding(
    padding: const EdgeInsets.all(12),
    child: Column(
      children: [
        SizedBox(
          height: 48,
          child: _cabecalhoEditor(compacto: compacto),
        ),
        const SizedBox(height: 8),
        Expanded(child: _areaEditor()),
        const SizedBox(height: 12),
        _barraAcoes(),
      ],
    ),
  );

  Widget _barraLateral() => SizedBox(
    width: 280,
    child: Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 0, 12),
      child: Column(
        children: [
          SizedBox(
            height: 48,
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Documentos',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: widget.documentos.novoDocumento,
                  icon: const Icon(Icons.add),
                  label: const Text('Novo'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Card(
              color: corPapelDe(context),
              margin: EdgeInsets.zero,
              clipBehavior: Clip.antiAlias,
              child: ListView.builder(
                itemCount: widget.documentos.documentos.length,
                itemBuilder: (context, i) => ListTile(
                  dense: true,
                  leading: const Icon(Icons.description),
                  title: Text(
                    widget.documentos.documentos[i].titulo,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  selected: i == widget.documentos.selecionado,
                  selectedTileColor: Theme.of(context)
                      .colorScheme.primary.withAlpha(30),
                  onTap: () => widget.documentos.selecionar(i),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(height: 76, child: _cartaoPreferencias()),
          const SizedBox(height: 8),
          SizedBox(height: 76, child: _cartaoUsuarios()),
        ],
      ),
    ),
  );

  Widget _layoutEstreito() => Column(
    children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
        child: SizedBox(
          height: 80,
          child: Row(
            children: [
              Expanded(child: _cartaoPreferencias()),
              const SizedBox(width: 8),
              Expanded(child: _cartaoUsuarios()),
            ],
          ),
        ),
      ),
      SizedBox(
        height: 56,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
          children: [
            for (int i = 0; i < widget.documentos.documentos.length; i++)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  avatar: const Icon(Icons.description, size: 18),
                  label: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 140),
                    child: Text(
                      widget.documentos.documentos[i].titulo,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  selected: i == widget.documentos.selecionado,
                  onSelected: (_) => widget.documentos.selecionar(i),
                ),
              ),
            ActionChip(
              avatar: const Icon(Icons.add, size: 18),
              label: const Text('Novo'),
              onPressed: widget.documentos.novoDocumento,
            ),
          ],
        ),
      ),
      Expanded(child: _painelEditor(compacto: true)),
    ],
  );

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: Listenable.merge([widget.auth, widget.documentos]),
    builder: (context, _) {
      final usuario = widget.auth.usuarioAtual;

      if (usuario == null || widget.documentos.documentoAtual == null) {
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      }

      final argumento = ModalRoute.of(context)?.settings.arguments;
      final nome = argumento is String ? argumento : usuario.nome;
      final primeiroNome = nome.split(' ').first;

      return Scaffold(
        appBar: AppBar(
          title: Text('Anotações de $primeiroNome'),
          actions: [
            IconButton(
              icon: const Icon(Icons.tune),
              tooltip: 'Configurações',
              onPressed: _abrirConfiguracoes,
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Sair',
              onPressed: _sair,
            ),
          ],
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            final largo = constraints.maxWidth >= 600;
            final conteudo = largo
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _barraLateral(),
                      Expanded(
                        child: _painelEditor(
                          compacto: (constraints.maxWidth - 280) < 480,
                        ),
                      ),
                    ],
                  )
                : _layoutEstreito();

            final alturaMinima = largo ? 360.0 : 420.0;

            if (constraints.maxHeight < alturaMinima) {
              return SingleChildScrollView(
                child: SizedBox(
                  height: alturaMinima,
                  child: conteudo,
                ),
              );
            }

            return conteudo;
          },
        ),
        bottomNavigationBar: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          color: Theme.of(context).brightness == Brightness.dark
              ? corPapelEscuro
              : corAzulEscuro,
          alignment: Alignment.center,
          child: Text(
            'Desenvolvido por $nomeDesenvolvedor',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).brightness == Brightness.dark
                  ? corTextoEscuro
                  : corOffWhite,
            ),
          ),
        ),
      );
    },
  );
}
