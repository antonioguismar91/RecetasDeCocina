import 'package:english_words/english_words.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recetasdecocina/Add_receta.dart';

import 'Receta.dart';

void main() {
  runApp(menu_recetas());
}

class menu_recetas extends StatelessWidget {
  const menu_recetas({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'CocinApp',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.greenAccent),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var favorites = <WordPair>[];
  var current = WordPair.random();

  void getNext() {
    current = WordPair.random();
    notifyListeners();
  }

  void toggleFavorite() {
    if (favorites.contains(current)) {
      favorites.remove(current);
    } else {
      favorites.add(current);
    }
    notifyListeners();
  }
}

// ...

// ...

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedindex = 0;
  var words = [];
  List<Receta> listarecetas = [];

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedindex) {
      case 0:
        page = SearchRecetaPage();
        break;
      case 1:
        page =
            FavoritesPage(); // te pone una cruz mientras no haya nada en esa pantalla a la que cambias
        break;
      case 2:
        page = AddReceta();
      // aqui va añadir recetas
      default:
        throw UnimplementedError('no widget for $selectedindex');
    }
    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        body: Row(
          children: [
            SafeArea(
              child: NavigationRail(
                extended: constraints.maxWidth >= 600,
                destinations: [
                  NavigationRailDestination(
                    icon: Icon(Icons.home),
                    label: Text('Inicio'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.favorite),
                    label: Text('Favoritos'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.add),
                    label: Text('Añadir Recetas'),
                  ),
                ],
                selectedIndex: selectedindex,
                //la segunda que aparece es la variable declarada (pa que no te rayes)
                onDestinationSelected: (value) {
                  // está utilizando un lambda creo.
                  // print('selected: $value');
                  setState(() {
                    selectedindex = value;
                  });
                },
              ),
            ),
            Expanded(
              child: Container(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: page,
              ),
            ),
          ],
        ),
      );
    });
  }
}

// ...

class FavoritesPage extends StatefulWidget {
  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    if (appState.favorites.isEmpty) {
      return Center(
        child: Text('No hay favoritos.'),
      );
    }

    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text('You have '
              '${appState.favorites.length} favorites:'),
        ),
        for (var pair in appState.favorites)
          ListTile(
            leading: Icon(Icons.favorite),
            title: Text(pair.asLowerCase),
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                setState(() {
                  appState.favorites.remove(pair);
                });
              },
            ),
          ),
      ],
    );
  }
}

class SearchRecetaPage extends StatefulWidget {

  @override
  _SearchRecetaPageState createState() => _SearchRecetaPageState();
}

class _SearchRecetaPageState extends State<SearchRecetaPage> {
  List<Receta> _recetas = [];
  final TextEditingController search_controller = TextEditingController();


  @override
  void initState() {
    super.initState();
    recuperarRecetas(); // Recuperar recetas al iniciar la pantalla
  }

  void recuperarRecetas() async {
    try {
      final DatabaseReference databaseRef = FirebaseDatabase.instance.ref();
      DataSnapshot snapshot = await databaseRef.child("recetas").get();

      if (snapshot.exists) {
        Map<dynamic, dynamic> recetas = snapshot.value as Map<dynamic, dynamic>;

        List<Receta> listaRecetas = [];
        recetas.forEach((key, value) {
          Receta receta = Receta.fromMap(value);
          listaRecetas.add(receta);
        });

        setState(() {
          _recetas = listaRecetas;
        });
      } else {
        print("No hay recetas disponibles.");
      }
    } catch (e) {
      print("Error al recuperar recetas: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Text("CocinApp"),
          Container(
            width: 600,
            child: TextField(
              controller: search_controller,
              decoration: const InputDecoration(
                labelText: 'Buscar receta',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search), // Añadido el icono de lupa
              ),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width * 0.5,  // 80% del ancho
            height: MediaQuery.of(context).size.height * 0.2, // 50% del alto
            child: DropdownCategoria(),

          ),
          Expanded(
            child: ListView.builder(
              itemCount: _recetas.length,
              itemBuilder: (context, index) {
                final receta = _recetas[index];
                return ListTile(
                  title: Text(receta.nombre),
                    trailing: IconButton(
                icon: Icon(Icons.favorite), // Ícono del botón
                color: Colors.red,
                onPressed: () {
                print("Añadir a favoritos");
                }),
                  subtitle: Text('Categoría: ${receta.categoria}'),

                );
              },
            ),
          ),
        ],
      ),
    );
  }
}


// ...

class DropdownCategoria extends StatefulWidget {
  @override
  _DropdownCategoriaState createState() => _DropdownCategoriaState();
}

class _DropdownCategoriaState extends State<DropdownCategoria> {
  String seleccion = "Economicas"; // Se inicializa con una opción válida

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Buscar Categoría",
        ),
        backgroundColor: Colors.transparent,
        centerTitle: true,
      ),
      backgroundColor: Colors.transparent,
      body: Center(
        child: DropdownButton<String>(
          value: seleccion, // Usamos la variable declarada
          onChanged: (String? newValue) {
            setState(() {
              seleccion = newValue!; // Actualizamos la selección
            });
          },

          items: <String>[
            'Economicas',
            'Gourmet',
            'Tradicionales',
            'Saludables',
            'Niños',
            'Rapidas'
          ].map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
      ),
    );
  }
}

// ...
