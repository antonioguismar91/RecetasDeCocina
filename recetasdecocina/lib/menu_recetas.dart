import 'package:english_words/english_words.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'Receta.dart';
import 'Add_receta.dart';

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
  var favorites = <Receta>[];

  void toggleFavorite(Receta receta) {
    if (favorites.contains(receta)) {
      favorites.remove(receta);
    } else {
      favorites.add(receta);
    }
    notifyListeners();
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedindex = 0;

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedindex) {
      case 0:
        page = SearchRecetaPage();
        break;
      case 1:
        page = FavoritesPage();
        break;
      case 2:
        page = AddReceta();
        break;
      default:
        throw UnimplementedError('No widget for $selectedindex');
    }

    return Scaffold(
      body: Row(
        children: [
          SafeArea(
            child: NavigationRail(
              extended: MediaQuery.of(context).size.width >= 600,
              destinations: const [
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
              onDestinationSelected: (value) {
                setState(() => selectedindex = value);
              },
            ),
          ),
          Expanded(
            child: page,
          ),
        ],
      ),
    );
  }
}

class SearchRecetaPage extends StatefulWidget {
  @override
  _SearchRecetaPageState createState() => _SearchRecetaPageState();
}

class _SearchRecetaPageState extends State<SearchRecetaPage> {
  List<Receta> _recetas = [];
  final TextEditingController searchController = TextEditingController();
  String seleccion = "Todas";

  @override
  void initState() {
    super.initState();
    recuperarRecetas();
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
    var appState = context.watch<MyAppState>();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: searchController,
                  decoration: const InputDecoration(
                    labelText: 'Buscar receta',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
              ),
              SizedBox(width: 16),
              DropdownButton<String>(
                value: seleccion,
                onChanged: (String? newValue) {
                  setState(() {
                    seleccion = newValue!;
                  });
                },
                items: ['Todas', 'Economicas', 'Gourmet', 'Saludables', 'Rapidas']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _recetas.length,
            itemBuilder: (context, index) {
              final receta = _recetas[index];

              if (seleccion != "Todas" && receta.categoria != seleccion) {
                return SizedBox.shrink();
              }

              return Card(
                margin: EdgeInsets.all(8.0),
                child: ListTile(
                  leading: Icon(Icons.food_bank),
                  title: Text(receta.nombre),
                  subtitle: Container(
                    height: 50,
                    width: 150,
                    child: ListView(
                      children: [
                        Text(
                          'Categoria: ${receta.categoria}\n'
                              'Ingredientes: ${receta.ingredientes}\n'
                              'Preparacion: ${receta.preparacion}',
                        )
                      ],
                    ),
                  ),

                  trailing: IconButton(
                    icon: Icon(
                      appState.favorites.contains(receta)
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: Colors.red,
                    ),
                    onPressed: () {
                      appState.toggleFavorite(receta);
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    if (appState.favorites.isEmpty) {
      return Center(child: Text('No hay favoritos.'));
    }

    return ListView.builder(
      itemCount: appState.favorites.length,
      itemBuilder: (context, index) {
        final receta = appState.favorites[index];
        return ListTile(
          leading: Icon(Icons.favorite, color: Colors.red),
          title: Text(receta.nombre),
          subtitle: Text('Categoría: ${receta.categoria}'),

        );
      },
    );
  }
}