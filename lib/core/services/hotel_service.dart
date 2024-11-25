import 'package:carretera/core/models/hotel_booking.dart';
import 'package:carretera/core/models/user.dart';
import 'package:carretera/core/services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HotelService {
  final CollectionReference _hotels =
      FirebaseFirestore.instance.collection('hotel_bookings');
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();

  // Crear una reserva de hotel
  Future<void> createHotelBooking(HotelBooking booking) async {
    try {
      print('Guardando reserva de hotel con ID: ${booking.id}');
      await _hotels.doc(booking.id).set(booking.toMap());
      print('Reserva de hotel guardada exitosamente.');
    } catch (e) {
      print('Error al guardar la reserva de hotel: $e');
      throw Exception('Error al guardar la reserva de hotel: $e');
    }
  }

  // Obtener todas las reservas de un usuario
  Future<List<HotelBooking>> getUserHotelBookings(String userId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('hotel_bookings')
          .where('userId', isEqualTo: userId)
          .get();

      return snapshot.docs.map((doc) {
        return HotelBooking.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      throw Exception('Error al obtener las reservas de hotel: $e');
    }
  }

  // Obtener reservas del usuario autenticado
  Future<List<HotelBooking>> fetchAuthenticatedUserBookings() async {
    Usuario? user = await _authService.getAuthenticatedUser();
    if (user == null) {
      throw Exception('Usuario no autenticado');
    }

    return await getUserHotelBookings(user.id);
  }

  // Actualizar una reserva
  Future<void> updateHotelBooking(
      String bookingId, Map<String, dynamic> updates) async {
    try {
      await _hotels.doc(bookingId).update(updates);
    } catch (e) {
      throw Exception('Error al actualizar la reserva de hotel: $e');
    }
  }

  // Eliminar una reserva
  Future<void> deleteHotelBooking(String bookingId) async {
    try {
      await _hotels.doc(bookingId).delete();
    } catch (e) {
      throw Exception('Error al eliminar la reserva de hotel: $e');
    }
  }
}
