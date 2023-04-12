import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
import 'next.dart';

final pokemonProvider = FutureProvider((ref) async {
  var url =
      Uri.parse('https://pokeapi.co/api/v2/pokemon?limit=100000&offset=0');
  var response = await http.get(url);
  var jsonObj = convert.jsonDecode(response.body);
  List<dynamic> pokeList = jsonObj['results'];
  List<List<String>> cards = []; // ③ 通信が成功したのでカードリストを初期化
  for (Map<String, dynamic> poke in pokeList) {
    var name = poke['name'];
    var url = poke["url"];
    cards.add([name, url]);
  }
  return cards;
});

class TopPage extends ConsumerStatefulWidget {
  const TopPage({
    Key? key,
  }) : super(key: key);

  @override
  _TopPageState createState() => _TopPageState();
}

class _TopPageState extends ConsumerState<TopPage> {
  @override
  Widget build(BuildContext context) {
    final config = ref.watch(pokemonProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text("ポケモン一覧"),
      ),
      body: config.when(
          loading: () => const CircularProgressIndicator(),
          error: (error, stack) => Text('Error: $error'),
          data: (config) {
            List<Widget> cards = [];
            for (var poke in config) {
              cards.add(
                Card(
                  child: InkWell(
                    child: Text(poke[0]),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                PokePage(name: poke[0], url: poke[1]),
                          ));
                    },
                  ),
                ),
              );
            }
            return Center(
              child: ListView.builder(
                itemCount: cards.length,
                itemBuilder: (BuildContext context, int index) {
                  return cards[index];
                },
              ),
            );
          }),
    );
  }
}
