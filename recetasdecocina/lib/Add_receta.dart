import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fluttertoast/fluttertoast.dart';

void main() {
  runApp(
    const AddReceta(),
  );
}

class AddReceta extends StatelessWidget {
  const AddReceta({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('Agregar Receta'),
        ),
        body: const RecetaForm(),
      ),
    );
  }
}

class RecetaForm extends StatefulWidget {
  const RecetaForm({super.key});

  @override
  _RecetaFormState createState() => _RecetaFormState();
}

class _RecetaFormState extends State<RecetaForm> {
  final DatabaseReference databaseRef = FirebaseDatabase.instance.ref();
  String? categoriaSeleccionada;
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _categoriaController = TextEditingController();
  final TextEditingController _ingredientesController = TextEditingController();
  final TextEditingController _preparacionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: <Widget>[
          Row(
            children: [
              Container(
                width: 600,
                child: TextField(
                  controller: _nombreController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre de la receta',
                    border: OutlineInputBorder(),

                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                    width: 500,
                    height: 48,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.black54, // Color del borde
                        width: 1, // Grosor del borde
                      ),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: DropdownCategoria(
                      onChanged: (String seleccion) {
                        setState(() {
                          categoriaSeleccionada = seleccion;
                          Fluttertoast.showToast(msg: seleccion);
                        });
                      },
                    )),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            // Alinea los textos arriba
            children: [
              Container(
                width: 300,
                height: 300,
                child: TextField(
                  controller: _ingredientesController,
                  decoration: const InputDecoration(
                    labelText: 'Ingredientes',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 7,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _preparacionController,
                  decoration: const InputDecoration(
                    labelText: 'Preparación',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 7,
                ),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: () {
              String nombre = _nombreController.text;
              String ingredientes = _ingredientesController.text;
              String preparacion = _preparacionController.text;
              String categoria = categoriaSeleccionada!;
              if (nombre.isNotEmpty &&
                  ingredientes.isNotEmpty &&
                  preparacion.isNotEmpty &&
                  categoria.isNotEmpty) {
                guardarReceta(nombre, ingredientes, preparacion, categoria);
              } else {
                Fluttertoast.showToast(msg: 'Rellena todos los datos');
                Fluttertoast.showToast(msg: categoria);
              }
            },
            child: const Text('Guardar Receta'),
          ),
        ],
      ),
    );
  }

  void guardarReceta(String nombre, String ingredientes, String preparacion,
      String categoria) {
    databaseRef.child("recetas").push().set({
      "nombre": nombre,
      "ingredientes": ingredientes,
      "preparacion": preparacion,
      "categoria": categoria
    }).then((_) {
      print("Receta guardada correctamente");
      Fluttertoast.showToast(msg: 'Receta guardada correctamente');
    }).catchError((error) {
      print("Error al guardar receta: $error");
      Fluttertoast.showToast(msg: 'Error al insertar');
    });
  }
}

class DropdownCategoria extends StatefulWidget {
  final Function(String) onChanged;

  DropdownCategoria({required this.onChanged});

  @override
  _DropdownCategoriaState createState() => _DropdownCategoriaState();
}

class _DropdownCategoriaState extends State<DropdownCategoria> {
  String? seleccion; // Se inicializa con una opción válida
  final List<String> categorias = [
    'Economicas',
    'Gourmet',
    'Tradicionales',
    'Saludables',
    'Niños',
    'Rapidas'
  ];

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: seleccion,
      hint: Text("Seleccione una categoría"),
      onChanged: (String? nuevaSeleccion) {
        setState(() {
          seleccion = nuevaSeleccion;
        });
        widget.onChanged(nuevaSeleccion!); // 🔥 Enviamos la selección al padre
      },
      items: categorias.map((String categoria) {
        return DropdownMenuItem<String>(
          value: categoria,
          child: Text(categoria),
        );
      }).toList(),
    );
  }
}

// ..
