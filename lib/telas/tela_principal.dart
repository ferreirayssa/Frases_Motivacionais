import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:translator/translator.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_frases/model/Frase.dart';
import 'package:app_frases/telas/tela_favoritos.dart';

class TelaPrincipal extends StatefulWidget {
  const TelaPrincipal({super.key});

  @override
  State<TelaPrincipal> createState() => _TelaPrincipalState();
}

class _TelaPrincipalState extends State<TelaPrincipal> {
  Frase? fraseDoDia;
  bool carregando = true;
  final tradutor = GoogleTranslator();

  @override
  void initState() {
    super.initState();
    buscarFraseDaAPI();
  }

  Future<void> buscarFraseDaAPI() async {
    setState(() => carregando = true);
    try {
      final url = Uri.parse('https://dummyjson.com/quotes/random');
      final resposta = await http.get(url);

      if (resposta.statusCode == 200) {
        final jsonDecodificado = jsonDecode(resposta.body);
        Frase fraseEmIngles = Frase.fromJson(jsonDecodificado);
        var traducao = await tradutor.translate(
          fraseEmIngles.texto,
          from: 'en',
          to: 'pt',
        );

        setState(() {
          fraseDoDia = Frase(
            id: fraseEmIngles.id,
            texto: traducao.text,
            autor: fraseEmIngles.autor,
          );
          carregando = false;
        });
      }
    } catch (erro) {
      setState(() => carregando = false);
    }
  }

Future<void> favoritarFrase() async {
    if (fraseDoDia == null) return;

    final prefs = await SharedPreferences.getInstance();
    List<String> listaFavoritos = prefs.getStringList('meus_favoritos') ?? [];

    String fraseParaSalvar = "${fraseDoDia!.texto.trim()} | Autor: ${fraseDoDia!.autor.trim()}";

    bool jaExiste = listaFavoritos.any((fraseSalva) => 
        fraseSalva.toLowerCase() == fraseParaSalvar.toLowerCase()
    );

    if (jaExiste) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Você já favoritou essa frase! 😉"),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 2),
          ),
        );
      }
      return;
    }

    listaFavoritos.add(fraseParaSalvar);
    await prefs.setStringList('meus_favoritos', listaFavoritos);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Frase salva nos favoritos! ❤️"),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.network(
              'https://images.unsplash.com/photo-1495107334309-fcf20504a5ab?q=80&w=1000',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(color: Colors.black.withValues(alpha: 0.4)),
          ),
          Positioned(
            top: 50,
            right: 20,
            child: IconButton(
              icon: const Icon(
                Icons.format_list_bulleted,
                color: Colors.white,
                size: 32,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TelaFavoritos(),
                  ),
                );
              },
            ),
          ),
          SafeArea(
            child: carregando
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32.0),
                        child: Text(
                          '"${fraseDoDia!.texto}"',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        "- ${fraseDoDia!.autor}",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.white70,
                        ),
                      ),
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 40.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            IconButton(
                              iconSize: 32,
                              color: Colors.white,
                              icon: const Icon(Icons.favorite),
                              onPressed: favoritarFrase,
                            ),
                            IconButton(
                              iconSize: 40,
                              color: Colors.white,
                              icon: const Icon(Icons.refresh),
                              onPressed: buscarFraseDaAPI,
                            ),
                            IconButton(
                              iconSize: 32,
                              color: Colors.white,
                              icon: const Icon(Icons.share),
                              onPressed: () {
                                if (fraseDoDia != null) {
                                  Share.share(
                                    '"${fraseDoDia!.texto}"\n- ${fraseDoDia!.autor}\n\nCompartilhado do meu App!',
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}