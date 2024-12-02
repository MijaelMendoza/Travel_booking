import 'package:carretera/core/models/hotel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
class HotelService {
  final CollectionReference _hotels =
      FirebaseFirestore.instance.collection('hotels');
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Crear un hotel
  
 static const String _apiKey = "5ae2e3f221c38a28845f05b6013fd780207c28c755217a2a8fc76f7a";
  static const String _baseUrl = "https://api.opentripmap.com/0.1/en/places";

   Future<void> createHotel(Hotel hotel) async {
    try {
      print('Intentando guardar hotel con ID: ${hotel.id}');
      await _hotels.doc(hotel.id).set(hotel.toMap());
      print('Hotel guardado exitosamente: ${hotel.name}');
    } catch (e) {
      print('Error al guardar el hotel: $e');
      throw Exception('Error al guardar el hotel: $e');
    }
  }

  // Método para buscar hoteles cercanos a una coordenada
  Future<List<Map<String, dynamic>>> getHotelsNearby({
    required double lat,
    required double lon,
    int radius = 10000,
    int limit = 10,
  }) async {
    print("Obteniendo hoteles cercanos en lat: $lat, lon: $lon");
    final url = Uri.parse("$_baseUrl/radius");
    final params = {
      "apikey": _apiKey,
      "lat": lat.toString(),
      "lon": lon.toString(),
      "radius": radius.toString(),
      "kinds": "accomodations",
      "limit": limit.toString(),
      "format": "json",
    };

    final response = await http.get(url.replace(queryParameters: params));
    print("Respuesta de la API de hoteles: ${response.statusCode}");
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    } else {
      print("Error al obtener hoteles: ${response.body}");
      throw Exception("Error al obtener hoteles: ${response.body}");
    }
  }

  // Método para obtener detalles de un hotel
  Future<Map<String, dynamic>> getHotelDetails(String xid) async {
    print("Obteniendo detalles del hotel con XID: $xid");
    final url = Uri.parse("$_baseUrl/xid/$xid?apikey=$_apiKey");

    final response = await http.get(url);
    print("Respuesta de la API para detalles del hotel: ${response.statusCode}");
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      print("Error al obtener detalles del hotel: ${response.body}");
      throw Exception("Error al obtener detalles del hotel: ${response.body}");
    }
  }
  // Obtener todos los hoteles
  Future<List<Hotel>> getAllHotels() async {
    try {
      QuerySnapshot snapshot = await _hotels.get();
      return snapshot.docs.map((doc) {
        return Hotel.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      throw Exception('Error al obtener los hoteles: $e');
    }
  }

  // Obtener un hotel por su ID
  Future<Hotel?> getHotelById(String hotelId) async {
    try {
      DocumentSnapshot doc = await _hotels.doc(hotelId).get();
      if (doc.exists) {
        return Hotel.fromMap(doc.data() as Map<String, dynamic>);
      } else {
        return null;
      }
    } catch (e) {
      throw Exception('Error al obtener el hotel: $e');
    }
  }

  // Actualizar un hotel
  Future<void> updateHotel(String hotelId, Map<String, dynamic> updates) async {
    try {
      print('Actualizando hotel con ID: $hotelId');
      await _hotels.doc(hotelId).update(updates);
      print('Hotel actualizado exitosamente.');
    } catch (e) {
      print('Error al actualizar el hotel: $e');
      throw Exception('Error al actualizar el hotel: $e');
    }
  }

  // Eliminar un hotel
  Future<void> deleteHotel(String hotelId) async {
    try {
      print('Eliminando hotel con ID: $hotelId');
      await _hotels.doc(hotelId).delete();
      print('Hotel eliminado exitosamente.');
    } catch (e) {
      print('Error al eliminar el hotel: $e');
      throw Exception('Error al eliminar el hotel: $e');
    }
  }
}
