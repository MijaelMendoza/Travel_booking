import 'package:carretera/core/models/hotel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HotelService {
  final CollectionReference _hotels =
      FirebaseFirestore.instance.collection('hotels');
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Crear un hotel
  Future<void> createHotel(Hotel hotel) async {
    try {
      print('Guardando hotel con ID: ${hotel.id}');
      await _hotels.doc(hotel.id).set(hotel.toMap());
      print('Hotel guardado exitosamente.');
    } catch (e) {
      print('Error al guardar el hotel: $e');
      throw Exception('Error al guardar el hotel: $e');
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
