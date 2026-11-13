import 'documento.dart';

class Usuario {
  Usuario({required this.nome, required this.email, required this.senha})
      : documentos = [Documento(titulo: 'Nova Anotação 1.txt')];

  final String nome;
  final String email;
  final String senha;
  final List<Documento> documentos;
}
