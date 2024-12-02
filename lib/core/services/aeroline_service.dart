// lib/core/services/airline_service.dart
import 'package:carretera/core/models/aerlineas.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AirlineService {
  final CollectionReference _airlines =
      FirebaseFirestore.instance.collection('airlines');

  // Crear una nueva aerolínea
  Future<void> createAirline(Airline airline) async {
    try {
      await _airlines.doc(airline.id).set(airline.toMap());
    } catch (e) {
      throw Exception('Error al guardar la aerolínea: $e');
    }
  }

  // Actualizar información de una aerolínea
  Future<void> updateAirline(String airlineId, Map<String, dynamic> updates) async {
    try {
      await _airlines.doc(airlineId).update(updates);
    } catch (e) {
      throw Exception('Error al actualizar la aerolínea: $e');
    }
  }

  // Eliminar una aerolínea
  Future<void> deleteAirline(String airlineId) async {
    try {
      await _airlines.doc(airlineId).delete();
    } catch (e) {
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
      throw Exception('Error al obtener la aerolínea: $e');
    }
  }

  // Obtener todas las aerolíneas
 
  Future<List<Airline>> getAllAirlines() async {
    try {
      final querySnapshot = await _airlines.get();
      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>?;
        if (data != null) {
          return Airline.fromMap(data);
        } else {
          throw Exception('Datos de aerolínea nulos');
        }
      }).toList();
    } catch (e) {
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
      throw Exception('Error al filtrar las aerolíneas: $e');
    }
  }
}
