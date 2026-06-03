import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_frases/telas/tela_adicionar_frase.dart';

class TelaFavoritos extends StatefulWidget {
  const TelaFavoritos({super.key});

  @override
  State<TelaFavoritos> createState() => _TelaFavoritosState();
}

class _TelaFavoritosState extends State<TelaFavoritos> {
  List<String> meusFavoritos = [];

  @override
  void initState() {
    super.initState();
    carregarFavoritos();
  }

  Future<void> carregarFavoritos() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      meusFavoritos = prefs.getStringList('meus_favoritos') ?? [];
    });
  }

  Future<void> removerFavorito(int index) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      meusFavoritos.removeAt(index);
      prefs.setStringList('meus_favoritos', meusFavoritos);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Meus Favoritos",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blueGrey[900],
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: meusFavoritos.isEmpty
          ? const Center(
              child: Text(
                "Nenhuma frase salva ainda. 💔",
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : ListView.builder(
              itemCount: meusFavoritos.length,
              itemBuilder: (context, index) {
                List<String> partes = meusFavoritos[index].split(" | Autor: ");
                String textoFrase = partes[0];
                String autor = partes.length > 1 ? partes[1] : "Desconhecido";

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.format_quote, color: Colors.blue),
                    title: Text(
                      textoFrase,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(autor),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => removerFavorito(index),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueGrey[900],
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
        onPressed: () async {
          final resultado = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TelaAdicionarFrase()),
          );

          if (resultado == true) {
            carregarFavoritos();
          }
        },
      ),
    );
  }
}