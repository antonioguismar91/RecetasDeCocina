import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
        title: 'Namer App',
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
  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedindex) {
      case 0:
        page = GeneratorPage();
        break;
      case 1:
        page = FavoritesPage();// te pone una cruz mientras no haya nada en esa pantalla a la que cambias
        break;
      case 2:
        // aqui va añadir recetas
      default:
        throw UnimplementedError('no widget for $selectedindex');
    }
    return LayoutBuilder(
        builder: (context,constraints) {
          return Scaffold(
            body: Row(
              children: [
                SafeArea(
                  child: NavigationRail(
                    extended: constraints.maxWidth>= 600,
                    destinations: [
                      NavigationRailDestination(
                        icon: Icon(Icons.home),
                        label: Text('Home'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.favorite),
                        label: Text('Favorites'),
                      ),
                    ],
                    selectedIndex: selectedindex,//la segunda que aparece es la variable declarada (pa que no te rayes)
                    onDestinationSelected: (value) {// está utilizando un lambda creo.
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
        }
    );
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
        child: Text('No favorites yet.'),
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
              onPressed: (){
                setState((){
                  appState.favorites.remove(pair);
                });
              },
            ),
          ),

      ],
    );
  }
}

class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;
    TextEditingController _controller = TextEditingController();
    String inputText = '';

    IconData icon;
    IconData buscaricon;
    buscaricon = Icons.search;
    if (appState.favorites.contains(pair)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }

    String seleccion='opcion 1';
    return Center(

      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              SizedBox(width: 250),

              Expanded( // esto hace que el TextField ocupe todo el espacio disponible
                child:
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Buscar nombre receta',
                    border: OutlineInputBorder(),
                  ),
                ),

              ),

              SizedBox(width: 8), // Espaciado entre el campo de texto y el botón
              ElevatedButton(
                onPressed: () {
                  appState.toggleFavorite();
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.all(12), // Ajusta el padding del botón
                  minimumSize: Size(50, 50), // Tamaño mínimo del botón
                ),
                child: Icon(Icons.search), // Ícono de búsqueda
              ),
              SizedBox(width:250),
            ],

          ),
          SizedBox(
            width: 300,
            height: 100,
            child: DropdownExample(),

          ),



          BigCard(pair: pair),
          Container(
            color: Colors.red,
            child: SizedBox(height: 40,
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: TextField(
                //controller: _controller,
                decoration: InputDecoration(
                  labelText: 'Enter your text',
                  border: OutlineInputBorder(),
                )),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  appState.toggleFavorite();
                },
                icon: Icon(icon),
                label: Text('Like'),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  appState.getNext();
                },
                child: Text('Next'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ...

class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.pair,
  });

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,

    );
    return Card(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Text(
          pair.asLowerCase,
          style: style,
          semanticsLabel: "${pair.first} ${pair.second}",
        ),
      ),
      elevation: 29,

    );


  }
}




class DropdownExample extends StatefulWidget {
  @override
  _DropdownExampleState createState() => _DropdownExampleState();
}

class _DropdownExampleState extends State<DropdownExample> {
  String seleccion = "Opción 1"; // Se inicializa con una opción válida

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Buscar Categoría"),
        backgroundColor: Colors.greenAccent,
      ),
      backgroundColor: Colors.greenAccent,

      body: Center(
        child: DropdownButton<String>(
          value: seleccion, // Usamos la variable declarada
          onChanged: (String? newValue) {
            setState(() {
              seleccion = newValue!; // Actualizamos la selección
            });
          },
          items: <String>['Opción 1', 'Opción 2', 'Opción 3']
              .map<DropdownMenuItem<String>>((String value) {
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
