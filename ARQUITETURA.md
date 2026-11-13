# Relatório de migração arquitetural — Fase 1

Aluno: Emanuel Amaral Nascimento.

## 1. Mapeamento de classes, widgets e funções

| Código do DartPad | Destino e responsabilidade |
| --- | --- |
| Documento | models/documento.dart: título e conteúdo. O ícone fixo Icons.description fica na View, eliminando a dependência de IconData no modelo. |
| Usuario | models/usuario.dart: nome, e-mail, senha e documentos por usuário. |
| PreferenciasUsuario e ServicoPreferencias | models/services/preferences_service.dart: objeto de preferências e PreferencesService, com carregar/salvar em memória. |
| BancoDadosLocal e sua tabela | models/services/banco_local_service.dart: BancoLocalService; insert vira inserirUsuario, query vira listarUsuarios; mantém buscarPorEmail. |
| validarNome, validarEmail, validarSenha | utils/validadores.dart: regras compartilhadas pelos formulários e pelo AuthViewModel. |
| nomeDesenvolvedor, cores, corPapelDe e ThemeData | utils/app_theme.dart: identificação e aparência dos temas claro/escuro. |
| main, MeuApp e suas rotas | main.dart: composição das dependências, tema reativo e navegação nomeada. |
| usuarioLogado e temaNotifier globais | AuthViewModel: usuarioAtual, tema e tamanhoFonte substituem os globais. |
| TelaLogin e _TelaLoginState | views/login_view.dart: LoginView, formulário e apresentação. Autenticação e _carregando passam ao AuthViewModel. |
| TelaCadastro e _TelaCadastroState | views/cadastro_view.dart: CadastroView. Cadastro, _salvando e escolhas de tema/fonte passam ao AuthViewModel. |
| TelaHome e _TelaHomeState | views/home_view.dart: HomeView, lista e editor embutido. Documentos, seleção, rascunho e modo de leitura passam ao DocumentosViewModel. |
| _fazerLogin, _cadastrar, _sair | Regras em AuthViewModel.login/cadastrar/sair; navegação e mensagens permanecem nas Views. |
| _guardarTextoAtual, _selecionar, _novoDocumento, _salvar e regra de _renomear | DocumentosViewModel: guardar rascunho, selecionar, novoDocumento, salvar e renomear. |
| _mostrarPreferencias, _mostrarUsuarios e _abrirConfiguracoes | Home apresenta diálogos/modais; consultas e mudanças são feitas através do AuthViewModel. |
| _exportarPdf | DocumentosViewModel prepara o texto; Home mantém a mensagem de simulação. |
| _mensagem, _renomear, _cartaoInterativo, _cartaoPreferencias, _cartaoUsuarios, _cabecalhoEditor, _areaEditor, _barraAcoes, _painelEditor, _barraLateral e _layoutEstreito | Permanecem na Home como mecanismos de interface; renomear delega a regra ao ViewModel. Mensagens também permanecem nas outras Views. |

## 2. Estrutura, imports, construtores e rotas

Cada biblioteca importa explicitamente seus modelos, serviços, validadores ou ViewModels. Os modelos não dependem das telas. Campos com prefixo _ continuam privados e são acessados por getters e métodos públicos.

main.dart cria BancoLocalService, PreferencesService, AuthViewModel e DocumentosViewModel. As três Views recebem as mesmas instâncias por construtor: Login/Cadastro recebem auth; Home recebe auth e documentos. A raiz escuta a autenticação e sincroniza documentos quando o usuário muda. Os ViewModels são descartados pela raiz; controllers são descartados pelas Views.

As rotas /, /cadastro e /home permanecem nomeadas. O nome segue nos arguments do login, com reserva no usuário autenticado. Sem sessão, /home mostra o login. A quarta tela /editor pertence à Fase 2. As configurações existentes do devcontainer e F5 permanecem válidas.

O import flutter/material.dart mantém compatibilidade com Flutter 3.35+. No Flutter 3.50, seu aviso de migração é suprimido apenas nesse import; os demais diagnósticos continuam ativos.

## 3. Gerenciamento de estado

AuthViewModel assume carregandoLogin, salvandoCadastro, usuarioAtual, tema/tamanhoFonte globais e temaCadastro/fonteCadastro. DocumentosViewModel assume documentos, selecionado, textoAtual e modoLeitura. Foram removidos os setState de carregamento, seleção de preferências, atualização da fonte, criação/troca/salvamento/renomeação e alternância de leitura; o modal não usa mais StatefulBuilder.

O fluxo é View → método do ViewModel → serviço/estado → notifyListeners → ListenableBuilder. A raiz observa auth para atualizar MaterialApp.themeMode; Home observa ambos os ViewModels. Controllers, FormKeys, diálogos, Navigator e SnackBars ficam nas Views. Os ViewModels não dependem de BuildContext. O controller do editor sincroniza mudanças de documento sem deslocar o cursor durante a digitação.

Esta fase preserva dados simulados em memória e o PDF simulado. Persistência JSON, exclusão, sessão permanente e a quarta tela serão feitos somente após entregar a Fase 1.

A migração foi validada com análise sem problemas, 11 testes e build web aprovado. Confira também a execução pelo F5 no seu Codespace.
