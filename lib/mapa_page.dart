import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;

class MapaPage extends StatefulWidget {
  @override
  _MapaPageState createState() => _MapaPageState();
}

class _MapaPageState extends State<MapaPage> {

  List<Marker> markers = [];
  Timer? timer; // 🔥 AQUÍ VA (variable global del estado)

  @override
  void initState() {
    super.initState();

    obtenerUbicaciones();

    timer = Timer.periodic(Duration(seconds: 8), (_) {
      obtenerUbicaciones();
    });
  }

  Future<void> obtenerUbicaciones() async {
    try {
      final url = Uri.parse('https://servidor-appbus.onrender.com/ubicaciones');

      final response = await http.get(url);
      final data = jsonDecode(response.body);

      List<Marker> nuevos = [];

      for (var bus in data) {
        nuevos.add(
          Marker(
            width: 40,
            height: 40,
            point: LatLng(bus['lat'], bus['lng']),
            child: Icon(
              Icons.directions_bus,
              color: Colors.red,
              size: 30,
            ),
          ),
        );
      }

      // 🔥 evita errores de rebuild
      if (mounted) {
        setState(() {
          markers = nuevos;
        });
      }

    } catch (e) {
      print("Error mapa: $e");
    }
  }

  @override
  void dispose() {
    timer?.cancel(); // 🔥 evita fugas de memoria
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
  title: Text("Mapa de autobuses"),
  leading: IconButton(
    icon: Icon(Icons.arrow_back),
    onPressed: () => Navigator.pop(context),
  ),
),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: LatLng(19.4326, -99.1332),
          initialZoom: 14,
        ),
        children: [
          TileLayer(
            urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
            userAgentPackageName: 'com.example.app_autobus', // 🔥 IMPORTANTE (evita error 403)
          ),
          MarkerLayer(markers: markers),
        ],
      ),
    );
  }
}

/*
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;

// 🔥 MODELO DE AUTOBÚS
class Bus {
  String id;
  LatLng posicion;
  LatLng? destino;

  Bus({
    required this.id,
    required this.posicion,
    this.destino,
  });
}

class MapaPage extends StatefulWidget {
  @override
  _MapaPageState createState() => _MapaPageState();
}

class _MapaPageState extends State<MapaPage> {

  Map<String, Bus> buses = {};
  List<Marker> markers = [];

  Timer? timer;          // 🔁 actualización de API
  Timer? animationTimer; // 🎞️ animación suave

  @override
  void initState() {
    super.initState();

    obtenerUbicaciones();

    // 🔁 cada 8 segundos pide nuevas posiciones
    timer = Timer.periodic(Duration(seconds: 8), (_) {
      obtenerUbicaciones();
    });

    // 🎞️ animación fluida (cada 100ms)
    animationTimer = Timer.periodic(Duration(milliseconds: 100), (_) {
      animarBuses();
    });
  }

  // 🌐 OBTENER DATOS DEL BACKEND
  Future<void> obtenerUbicaciones() async {
    try {
      final url = Uri.parse('http://10.15.139.150:3000/ubicaciones');
      final response = await http.get(url);
      final data = jsonDecode(response.body);

      for (var bus in data) {
        String id = bus['id'].toString();
        LatLng nuevaPos = LatLng(bus['lat'], bus['lng']);

        if (buses.containsKey(id)) {
          buses[id]!.destino = nuevaPos;
        } else {
          buses[id] = Bus(
            id: id,
            posicion: nuevaPos,
          );
        }
      }

    } catch (e) {
      print("Error mapa: $e");
    }
  }

  // 🎞️ ANIMACIÓN SUAVE
  void animarBuses() {
    for (var bus in buses.values) {
      if (bus.destino != null) {

        double lat = bus.posicion.latitude +
            (bus.destino!.latitude - bus.posicion.latitude) * 0.1;

        double lng = bus.posicion.longitude +
            (bus.destino!.longitude - bus.posicion.longitude) * 0.1;

        bus.posicion = LatLng(lat, lng);
      }
    }

    actualizarMarkers();
  }

  // 🔄 ACTUALIZAR MARKERS
  void actualizarMarkers() {
    List<Marker> nuevos = [];

    for (var bus in buses.values) {
      nuevos.add(
        Marker(
          width: 40,
          height: 40,
          point: bus.posicion,
          child: Icon(
            Icons.directions_bus,
            color: Colors.red,
            size: 30,
          ),
        ),
      );
    }

    if (mounted) {
      setState(() {
        markers = nuevos;
      });
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    animationTimer?.cancel(); // 🔥 importante
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Mapa de autobuses"),
      ),
      body: FlutterMap(
        options: MapOptions(
          // 📍 TESVG
          initialCenter: LatLng(19.7110, -99.6417),
          initialZoom: 15,
        ),
        children: [
          TileLayer(
            urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
            userAgentPackageName: 'com.example.app_autobus', // 🔥 NO BORRAR
          ),
          MarkerLayer(markers: markers),
        ],
      ),
    );
  }
}
*/