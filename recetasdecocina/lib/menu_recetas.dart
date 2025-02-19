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
        color: Colors.white,
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
      appBar: AppBar(
        title: const Text(
          'CocinApp',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        backgroundColor: Colors.green[700], // Verde oscuro
        actions: [
          IconButton(
            icon: const Icon(Icons.kitchen),
            tooltip: 'Mis utensilios',
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.set_meal),
            tooltip: 'Menú del día',
            onPressed: () {},
          ),
        ],
      ),
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
  List<Receta> _recetasFiltradas = [];
  final TextEditingController searchController = TextEditingController();
  String seleccion = "Todas";

  @override
  void initState() {
    super.initState();
    recuperarRecetas();
    searchController.addListener(filtrarRecetas);
  }

  void filtrarRecetas() {
    String query = searchController.text.toLowerCase();

    setState(() {
      _recetasFiltradas = _recetas.where((receta) {
        bool coincideCategoria = seleccion == "Todas" || receta.categoria == seleccion;
        bool coincideNombre = receta.nombre.toLowerCase().contains(query);
        return coincideCategoria && coincideNombre;
      }).toList();
    });
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
          _recetasFiltradas = List.from(listaRecetas); // Copia inicial de todas las recetas
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
                    filtrarRecetas(); // Ejecutar el filtro al cambiar la categoría
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
            itemCount: _recetasFiltradas.length,
            itemBuilder: (context, index) {
              final receta = _recetasFiltradas[index];

              return Card(
                elevation: 4, // Añadimos una pequeña sombra
                margin: EdgeInsets.all(8.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12), // Bordes redondeados
                ),
                child: ListTile(
                  leading: Icon(Icons.fastfood, color: Colors.green[700]), // Icono más representativo
                  title: Text(
                    receta.nombre,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Container(
                    constraints: BoxConstraints(
                      maxHeight: 100, // Permite scroll dentro del texto
                    ),
                    child: SingleChildScrollView(
                      child: Text(
                        'Categoría: ${receta.categoria}\n'
                            'Ingredientes: ${receta.ingredientes}\n'
                            'Preparación: ${receta.preparacion}',
                      ),
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
      return Center(
        child: Text(
          'No hay favoritos.',
          style: TextStyle(fontSize: 18),
        ),
      );
    }

    return ListView.builder(
      itemCount: appState.favorites.length,
      itemBuilder: (context, index) {
        final receta = appState.favorites[index];
        return ListTile(
          leading: Icon(Icons.favorite, color: Colors.red),
          title: Text(
            receta.nombre,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text('Categoría: ${receta.categoria}'),
        );
      },
    );
  }
}
