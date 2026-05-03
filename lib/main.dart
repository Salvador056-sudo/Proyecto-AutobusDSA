import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'mapa_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: LoginPage());
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController correo = TextEditingController();
  TextEditingController password = TextEditingController();

  @override
  void initState() {
    super.initState();
    _verificarSesion();  // 🔥 NUEVO: Revisa si ya hay sesión
  }

  // 🔥 NUEVO: Función para verificar sesión guardada
  Future<void> _verificarSesion() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? isLoggedIn = prefs.getBool('isLoggedIn');
    
    if (isLoggedIn == true) {
      String nombre = prefs.getString('nombre') ?? 'Usuario';
      int saldo = prefs.getInt('saldo') ?? 0;
      
      // Ir directo al Home sin pedir login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(nombre: nombre, saldo: saldo),
        ),
      );
    }
  }

  Future<void> login() async {
    if (correo.text.isEmpty || password.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Completa todos los campos')));
      return;
    }
    try {
      final url = Uri.parse('https://servidor-appbus.onrender.com/login');

      print("Intentando conectar a: $url");

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'correo': correo.text, 'password': password.text}),
      );

      print("Respuesta status: ${response.statusCode}");
      print("Respuesta body: ${response.body}");

      final data = jsonDecode(response.body);

      if (data['success']) {
        // 🔥 NUEVO: Guardar sesión en el teléfono
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('nombre', data['nombre']);
        await prefs.setInt('saldo', data['saldo']);
        await prefs.setBool('isLoggedIn', true);
        
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(nombre: data['nombre'], saldo: data['saldo']),
          ),
        );
      } else {
        print('Login incorrecto');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Credenciales incorrectas'), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      print("ERROR: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error de conexión'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0F2027),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Bienvenido',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: 30),

              TextField(
                controller: correo,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Correo',
                  hintStyle: TextStyle(color: Colors.white54),
                  filled: true,
                  fillColor: Colors.white10,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              SizedBox(height: 15),

              TextField(
                controller: password,
                obscureText: true,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Contraseña',
                  hintStyle: TextStyle(color: Colors.white54),
                  filled: true,
                  fillColor: Colors.white10,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              SizedBox(height: 25),

              ElevatedButton(
                onPressed: login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF2C5364),
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: Text(
                  'Iniciar sesión',
                  style: TextStyle(color: Colors.white),
                ),
              ),

              SizedBox(height: 15),

              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => RegisterPage()),
                  );
                },
                child: Text(
                  '¿No tienes cuenta? Regístrate',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RegisterPage extends StatelessWidget {
  final TextEditingController nombre = TextEditingController();
  final TextEditingController correo = TextEditingController();
  final TextEditingController password = TextEditingController();

  Future<void> register(BuildContext context) async {
    if (correo.text.isEmpty || password.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Completa todos los campos')));
      return;
    }
    try {
      final url = Uri.parse('https://servidor-appbus.onrender.com/register');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nombre': nombre.text,
          'correo': correo.text,
          'password': password.text,
        }),
      );

      final data = jsonDecode(response.body);

      if (data['success']) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Registro exitoso')));
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message']), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error de conexión')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0F2027),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Registro',
                style: TextStyle(color: Colors.white, fontSize: 28),
              ),

              SizedBox(height: 20),

              TextField(
                controller: nombre,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(hintText: 'Nombre'),
              ),
              SizedBox(height: 15),
              TextField(
                controller: correo,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(hintText: 'Correo'),
              ),
              SizedBox(height: 15),
              TextField(
                controller: password,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(hintText: 'Contraseña'),
              ),

              SizedBox(height: 20),

              ElevatedButton(
                onPressed: () => register(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF2C5364),
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: Text(
                  'Registrarse',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  final String nombre;
  final int saldo;

  HomePage({required this.nombre, required this.saldo});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text('Mi Cuenta'),
        backgroundColor: Color(0xFF0F2027),
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              // 🔥 NUEVO: Cerrar sesión (borrar datos guardados)
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 30),

              // Tarjeta de saldo
              Container(
                margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF0F2027),
                      Color(0xFF203A43),
                      Color(0xFF2C5364),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black54,
                      blurRadius: 15,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Tarjeta de Transporte',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                            letterSpacing: 1,
                          ),
                        ),
                        Icon(Icons.directions_bus, color: Colors.white70),
                      ],
                    ),

                    SizedBox(height: 15),

                    Text(
                      nombre,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    Text(
                      'Saldo disponible',
                      style: TextStyle(color: Colors.white60, fontSize: 12),
                    ),

                    SizedBox(height: 5),

                    Text(
                      '\$ $saldo',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),

                    SizedBox(height: 12),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '**** 4582',
                          style: TextStyle(color: Colors.white38),
                        ),
                        Text('Válida', style: TextStyle(color: Colors.white38)),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20),
              
              // Botón para ir al mapa
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => MapaPage()),
                  );
                },
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  padding: EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFF0F2027),
                        Color(0xFF203A43),
                        Color(0xFF2C5364),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black54,
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.map, color: Colors.white, size: 28),
                      SizedBox(width: 15),
                      Text(
                        "Ver mapa en tiempo real",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
