class Receta {
  // Atributos
  String nombre;
  String ingredientes;
  String preparacion;
  String categoria;
  Receta({
    required this.nombre,
    required this.ingredientes,
    required this.preparacion,
    required this.categoria,
  });
  // Constructor
  // Método
  // Método para crear una receta a partir de un mapa de Firebase
  factory Receta.fromMap(Map<dynamic, dynamic> map) {
    return Receta(
      nombre: map['nombre'] ?? '',
      ingredientes: map['ingredientes'] ?? '',
      preparacion: map['preparacion'] ?? '',
      categoria: map['categoria'] ?? '',
    );
  }
}
/*

void main() {
  List<String> lista = [];

  // Agregar un objeto a la lista
  lista.add("objeto1");
  Receta p = Receta( "ennove",lista,"ff","cat");
}

*/


