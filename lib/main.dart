import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: PokemonList(),
    );
  }
}

class PokemonList extends StatefulWidget {
  const PokemonList({Key? key}) : super(key: key);
  @override
  PokemonListState createState() => PokemonListState();
}

class PokemonListState extends State<PokemonList> {
  List<dynamic> pokemonList = [];
  final logger = Logger();
  @override
  void initState() {
    super.initState();
    fetchPokemonList();
  }

  Future<void> fetchPokemonList() async {
    final response = await http
        .get(Uri.parse('https://pokeapi.co/api/v2/pokemon/?limit=100'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        pokemonList = data['results'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pokemon List'),
      ),
      body: ListView.builder(
        itemCount: pokemonList.length,
        itemBuilder: (context, index) {
          final pokemon = pokemonList[index];

          // Extract Pokemon number from the URL
          final pokemonNumber = _extractPokemonNumber(pokemon['url']);
          return ListTile(
            title: Text('$pokemonNumber: ${pokemon['name']}'),
            onTap: () {
              fetchAndNavigateToPokemonDetail(context, pokemon['name']);
            },
          );
        },
      ),
    );
  }

  int _extractPokemonNumber(String url) {
    // Extract Pokemon number from the URL
    final regex = RegExp(r'/(\d+)/$');
    final match = regex.firstMatch(url);
    if (match != null) {
      return int.parse(match.group(1)!);
    }
    return 0; // Return 0 if the number is not found (handle error case)
  }

  Future<void> fetchAndNavigateToPokemonDetail(
      BuildContext context, String pokemonName) async {
    final response = await http
        .get(Uri.parse('https://pokeapi.co/api/v2/pokemon/$pokemonName'));

    if (response.statusCode == 200) {
      final pokemonDetail = jsonDecode(response.body);

      // Capture the context in a local variable
      final localContext = context;

      // Use Future.delayed to ensure the context is still valid
      await Future.delayed(Duration.zero, () {
        Navigator.of(localContext).push(MaterialPageRoute(
          builder: (context) =>
              PokemonDetailScreen(pokemonDetail: pokemonDetail),
        ));
      });

      logger.i('Pokemon details fetched successfully: $pokemonDetail');
    } else {
      // Handle error
      logger.e('Error fetching Pokemon details: ${response.statusCode}');
    }
  }
}

class PokemonDetailScreen extends StatelessWidget {
  const PokemonDetailScreen({
    Key? key,
    required this.pokemonDetail,
  }) : super(key: key);

  final dynamic pokemonDetail;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(pokemonDetail['name']),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Height: ${pokemonDetail['height']}'),
            Text('Weight: ${pokemonDetail['weight']}'),
            // Add other information as needed
          ],
        ),
      ),
    );
  }
}
