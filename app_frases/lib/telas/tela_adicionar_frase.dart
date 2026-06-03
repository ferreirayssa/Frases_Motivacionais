import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TelaAdicionarFrase extends StatefulWidget {
  const TelaAdicionarFrase({super.key});

  @override
  State<TelaAdicionarFrase> createState() => _TelaAdicionarFraseState();
}

class _TelaAdicionarFraseState extends State<TelaAdicionarFrase> {
  final _formKey = GlobalKey<FormState>();
  final _textoController = TextEditingController();
  final _autorController = TextEditingController();

  Future<void> salvarNovaFrase() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    List<String> listaFavoritos = prefs.getStringList('meus_favoritos') ?? [];

    String fraseParaSalvar =
        "${_textoController.text} | Autor: ${_autorController.text}";
    listaFavoritos.add(fraseParaSalvar);

    await prefs.setStringList('meus_favoritos', listaFavoritos);

    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Nova Frase", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueGrey[900],
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "Escreva a sua inspiração:",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _textoController,
                decoration: const InputDecoration(
                  labelText: "Frase",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.text_fields),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor, digite a frase.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _autorController,
                decoration: const InputDecoration(
                  labelText: "Autor",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor, digite o nome do autor.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey[900],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                icon: const Icon(Icons.save),
                label: const Text(
                  "Salvar Frase",
                  style: TextStyle(fontSize: 18),
                ),
                onPressed: salvarNovaFrase,
              ),
            ],
          ),
        ),
      ),
    );
  }
}