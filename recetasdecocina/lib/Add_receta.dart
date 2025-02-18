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
          title: const Text(
            'Agregar Receta',
            style: TextStyle(
              color: Colors.white, // Cambia el color de las letras a blanco
            ),
          ),
          backgroundColor: Colors.green.shade700, // Verde suave para la AppBar
        ),
        body: Container(
          color: Colors.green.shade300, // Fondo verde claro
          child: const RecetaForm(),
        ),
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
  final TextEditingController _ingredientesController = TextEditingController();
  final TextEditingController _preparacionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[

          // Campo de nombre de la receta
          Text(
            'Nombre de la receta',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: TextField(
              controller: _nombreController,
              decoration: InputDecoration(
                hintText: 'Escriba el nombre',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Dropdown de categoría
          Text(
            'Categoría',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.black54),
            ),
            child: DropdownCategoria(
              onChanged: (String seleccion) {
                setState(() {
                  categoriaSeleccionada = seleccion;
                  Fluttertoast.showToast(msg: seleccion);
                });
              },
            ),
          ),
          const SizedBox(height: 20),
          // Campo de ingredientes
          Text(
            'Ingredientes',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: TextField(
              controller: _ingredientesController,
              decoration: InputDecoration(
                hintText: 'Escriba los ingredientes',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
              maxLines: 7,
            ),
          ),
          const SizedBox(height: 20),
          // Campo de preparación
          Text(
            'Preparación',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: TextField(
              controller: _preparacionController,
              decoration: InputDecoration(
                hintText: 'Escriba los pasos de preparación',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
              maxLines: 7,
            ),
          ),
          const SizedBox(height: 30),
          // Botón de guardar receta
          Center(
            child: ElevatedButton(
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
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white, // Botón blanco
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Guardar Receta',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black, // Texto en negro
                ),
              ),
            ),
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
  String? seleccion;
  final List<String> categorias = [
    'Económicas',
    'Gourmet',
    'Tradicionales',
    'Saludables',
    'Niños',
    'Rápidas'
  ];

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: seleccion,
      hint: const Text("Seleccione una categoría"),
      onChanged: (String? nuevaSeleccion) {
        setState(() {
          seleccion = nuevaSeleccion;
        });
        widget.onChanged(nuevaSeleccion!);
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
