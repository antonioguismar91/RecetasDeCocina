import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'register.dart';
import 'user_dashboard.dart'; // Reemplaza con la pantalla a la que deseas navegar tras iniciar sesión

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;

  Future<void> _loginUser() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        UserCredential userCredential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        // Redirigir a la pantalla de interfaz tras iniciar sesión
        /*Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ListScreen(), // Reemplazar con la pantalla adecuada
          ),
        );*/
      } on FirebaseAuthException catch (e) {
        String errorMessage;

        if (e.code == 'user-not-found') {
          errorMessage = 'No se encontró un usuario con este correo.';
        } else if (e.code == 'wrong-password') {
          errorMessage = 'Contraseña incorrecta.';
        } else {
          errorMessage = 'Ocurrió un error: ${e.message}';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Iniciar Sesión",
          style: TextStyle(color: Colors.white), // Cambia el color del título a blanco
        ),
        backgroundColor: Colors.green.shade700,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green.shade300, Colors.green.shade800],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Bienvenido de nuevo",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white, // Fondo blanco del recuadro
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 300,
                          child: TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              labelText: 'Correo Electrónico',
                              labelStyle: TextStyle(color: Colors.black87), // Cambia el color del label a negro
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.2),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide(
                                  color: Colors.black38, // Añade un borde suave
                                  width: 1.5, // Grosor del borde
                                ),
                              ),
                              prefixIcon: Icon(Icons.email, color: Colors.black87), // Icono de color negro
                            ),
                            style: TextStyle(color: Colors.black87), // Texto dentro del campo de color negro
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor ingresa tu correo.';
                              }
                              if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                                return 'Por favor ingresa un correo válido.';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          width: 300,
                          child: TextFormField(
                            controller: _passwordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: 'Contraseña',
                              labelStyle: TextStyle(color: Colors.black87), // Cambia el color del label a negro
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.2),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide(
                                  color: Colors.black38, // Añade un borde suave
                                  width: 1.5, // Grosor del borde
                                ),
                              ),
                              prefixIcon: Icon(Icons.lock, color: Colors.black87), // Icono de color negro
                            ),
                            style: TextStyle(color: Colors.black87), // Texto dentro del campo de color negro
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor ingresa tu contraseña.';
                              }
                              if (value.length < 6) {
                                return 'La contraseña debe tener al menos 6 caracteres.';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  _isLoading
                      ? CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  )
                      : ElevatedButton(
                    onPressed: _loginUser,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.greenAccent,
                      backgroundColor: Colors.white, // Color del botón
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 50,
                        vertical: 15,
                      ),
                    ),
                    child: Text(
                      "Iniciar Sesión",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black, // Cambia el color del texto del botón a negro
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => RegisterScreen()),
                      );
                    },
                    child: Text(
                      "¿No tienes cuenta? Regístrate",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // Navegar a la pantalla de cambiar contraseña
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ResetScreen(), // Reemplazar con la pantalla de cambiar contraseña
                        ),
                      );
                    },
                    child: Text(
                      "¿Olvidaste tu contraseña? Cámbiala aquí",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
