//USANDO POO

class Frase {
  final int id;
  final String texto;
  final String autor;

  Frase({required this.id, required this.texto, required this.autor});

  factory Frase.fromJson(Map<String, dynamic> json) {
    return Frase(id: json['id'], texto: json['quote'], autor: json['author']);
  }
}