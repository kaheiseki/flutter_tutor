import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

final pokeDetailFamily = FutureProvider.family<String, Uri>((ref, url) async {
  var response = await http.get(url);
  String pokeType = "タイプ：";
  if (response.statusCode == 200) {
    var jsonObj = convert.jsonDecode(response.body);
    var types = jsonObj["types"];

    for (var type in types) {
      pokeType += type["type"]["name"];
    }
  } else if (response.statusCode == 500) {
    // エラーハンドリング
    print("server-side error");
  } else {
    // エラーハンドリング
    print("unkwon error");
  }
  return pokeType;
});

class PokePage extends ConsumerStatefulWidget {
  final String name;
  final String url;
  const PokePage({Key? key, required this.name, required this.url});
  @override
  _PokemonPageState createState() => _PokemonPageState(url: url, name: name);
}

class _PokemonPageState extends ConsumerState<PokePage> {
  List<Widget> cards = [];
  final String url;
  final String name;
  _PokemonPageState({Key? key, required this.url, required this.name});

  @override
  Widget build(BuildContext context) {
    final response = ref.watch(pokeDetailFamily(Uri.parse(url)));
    return Scaffold(
        appBar: AppBar(
          title: const Text("ポケモン一覧"),
        ),
        body: response.when(
            loading: () => const CircularProgressIndicator(),
            error: (error, stack) => Text('Error: $error'),
            data: (config) {
              return Center(
                child: Column(
                  children: [Text(name), Text(config)],
                ),
              );
            }));
  }
}
