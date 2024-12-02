// lib/core/services/airline_service.dart
import 'package:carretera/core/models/aerlineas.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AirlineService {
  final CollectionReference _airlines =
      FirebaseFirestore.instance.collection('airlines');
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Crear una nueva aerolínea
  Future<void> createAirline(Airline airline) async {
    try {
      print('Guardando aerolínea con ID: ${airline.id}');
      await _airlines.doc(airline.id).set(airline.toMap());
      print('Aerolínea guardada exitosamente.');
    } catch (e) {
      print('Error al guardar la aerolínea: $e');
      throw Exception('Error al guardar la aerolínea: $e');
    }
  }

  // Actualizar información de una aerolínea
  Future<void> updateAirline(String airlineId, Map<String, dynamic> updates) async {
    try {
      print('Actualizando aerolínea con ID: $airlineId');
      await _airlines.doc(airlineId).update(updates);
      print('Aerolínea actualizada exitosamente.');
    } catch (e) {
      print('Error al actualizar la aerolínea: $e');
      throw Exception('Error al actualizar la aerolínea: $e');
    }
  }

  // Eliminar una aerolínea
  Future<void> deleteAirline(String airlineId) async {
    try {
      print('Eliminando aerolínea con ID: $airlineId');
      await _airlines.doc(airlineId).delete();
      print('Aerolínea eliminada exitosamente.');
    } catch (e) {
      print('Error al eliminar la aerolínea: $e');
      throw Exception('Error al eliminar la aerolínea: $e');
    }
  }

  // Obtener una aerolínea por ID
  Future<Airline?> getAirlineById(String airlineId) async {
    try {
      final snapshot = await _airlines.doc(airlineId).get();
      if (snapshot.exists) {
        return Airline.fromMap(snapshot.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print('Error al obtener la aerolínea: $e');
      throw Exception('Error al obtener la aerolínea: $e');
    }
  }

  // Obtener todas las aerolíneas
  Future<List<Airline>> getAllAirlines() async {
    try {
      final querySnapshot = await _airlines.get();
      return querySnapshot.docs.map((doc) {
        return Airline.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      print('Error al obtener las aerolíneas: $e');
      throw Exception('Error al obtener las aerolíneas: $e');
    }
  }

  // Filtrar aerolíneas por destino
  Future<List<Airline>> getAirlinesByDestination(String destination) async {
    try {
      final querySnapshot = await _airlines
          .where('destination', isEqualTo: destination)
          .get();
      return querySnapshot.docs.map((doc) {
        return Airline.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      print('Error al filtrar las aerolíneas: $e');
      throw Exception('Error al filtrar las aerolíneas: $e');
    }
  }
}
