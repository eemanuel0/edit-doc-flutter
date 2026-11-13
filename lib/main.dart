// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'models/services/banco_local_service.dart';
import 'models/services/preferences_service.dart';
import 'utils/app_theme.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/documentos_viewmodel.dart';
import 'views/cadastro_view.dart';
import 'views/home_view.dart';
import 'views/login_view.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final auth = AuthViewModel(
    banco: BancoLocalService(),
    preferences: PreferencesService(),
  );
  await auth.inicializar();
  runApp(MeuApp(auth: auth, documentos: DocumentosViewModel()));
}

class MeuApp extends StatefulWidget {
  const MeuApp({super.key, required this.auth, required this.documentos});

  final AuthViewModel auth;
  final DocumentosViewModel documentos;

  @override
  State<MeuApp> createState() => _MeuAppState();
}

class _MeuAppState extends State<MeuApp> {
  @override
  void initState() {
    super.initState();
    widget.auth.addListener(_sincronizarSessao);
    _sincronizarSessao();
  }

  void _sincronizarSessao() {
    widget.documentos.conectarUsuario(widget.auth.usuarioAtual);
  }

  @override
  void dispose() {
    widget.auth.removeListener(_sincronizarSessao);
    widget.documentos.dispose();
    widget.auth.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.auth,
      builder: (context, _) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Biblioteca de Documentos',
        theme: criarTemaClaro(),
        darkTheme: criarTemaEscuro(),
        themeMode: widget.auth.temaEscuro ? ThemeMode.dark : ThemeMode.light,
        initialRoute: '/',
        routes: {
          '/': (context) => LoginView(auth: widget.auth),
          '/cadastro': (context) => CadastroView(auth: widget.auth),
          '/home': (context) => widget.auth.usuarioAtual == null
              ? LoginView(auth: widget.auth)
              : HomeView(auth: widget.auth, documentos: widget.documentos),
        },
      ),
    );
  }
}
