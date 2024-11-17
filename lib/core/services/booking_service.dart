import 'package:carretera/core/models/user.dart';
import 'package:carretera/core/services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/booking.dart';

class BookingService {
  final CollectionReference _bookings =
      FirebaseFirestore.instance.collection('bookings');
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService(); // Inicialización correcta

 
  Future<void> createBooking(Booking booking) async {
    try {
      print('Guardando reserva con ID: ${booking.id}');
      await _bookings.doc(booking.id).set(booking.toMap());
      print('Reserva guardada exitosamente.');
    } catch (e) {
      print('Error al guardar la reserva: $e');
      throw Exception('Error al guardar la reserva: $e');
    }
  }

  // Actualizar el estado de una reserva
  Future<void> updateBookingStatus(String bookingId, String status) async {
    await _bookings.doc(bookingId).update({'estado': status});
  }

  // Obtener una reserva por ID
  Future<Booking?> getBookingById(String bookingId) async {
    final snapshot = await _bookings.doc(bookingId).get();
    if (snapshot.exists) {
      return Booking.fromMap(snapshot.data() as Map<String, dynamic>);
    }
    return null;
  }

  // Obtener reservas de un usuario
  Future<List<Booking>> getUserBookings(String usuarioId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('bookings')
          .where('usuarioId', isEqualTo: usuarioId)
          .get();

      return snapshot.docs.map((doc) {
        return Booking.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      throw Exception('Error al obtener las reservas: $e');
    }
  }

  // Método para obtener reservas del usuario autenticado
  Future<List<Booking>> fetchUserBookings() async {
    Usuario? usuario = await _authService.getAuthenticatedUser();
    if (usuario == null) {
      throw Exception('Usuario no autenticado');
    }

    return await getUserBookings(usuario.id); // Llama directamente al método
  }
}
