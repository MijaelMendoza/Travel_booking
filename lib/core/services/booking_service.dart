import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:carretera/core/models/user.dart';
import 'package:carretera/core/services/auth_service.dart';
import '../models/booking.dart';

class BookingService {
  final CollectionReference _bookings =
      FirebaseFirestore.instance.collection('bookings');
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService(); // Inicialización correcta

  // Función para contar las reservas de un usuario en el mes actual
  Future<int> _countUserBookingsInCurrentMonth(String userId) async {
    try {
      final currentDate = DateTime.now();
      final startOfMonth = DateTime(currentDate.year, currentDate.month, 1);
      final endOfMonth = DateTime(currentDate.year, currentDate.month + 1, 0);

      // Contar las reservas del usuario en el mes actual
      final querySnapshot = await _bookings
          .where('usuarioId', isEqualTo: userId)
          .where('fechaInicio', isGreaterThanOrEqualTo: startOfMonth)
          .where('fechaFin', isLessThanOrEqualTo: endOfMonth)
          .get();

      return querySnapshot.docs.length;
    } catch (e) {
      throw Exception('Error al contar las reservas: $e');
    }
  }

  // Función para actualizar el campo "viajeroFrecuente" del usuario
  Future<void> _updateFrequentTravelerStatus(String userId) async {
    try {
      // Verificar si el documento del usuario existe
      DocumentSnapshot usuarioDoc =
          await _firestore.collection('usuarios').doc(userId).get();

      // Si el documento no existe, crearlo con los valores iniciales
      if (!usuarioDoc.exists) {
        await _firestore.collection('usuarios').doc(userId).set({
          'viajeroFrecuente': false, // O el valor inicial que desees
        });
      }

      // Ahora actualizamos el estado de viajero frecuente
      await _firestore.collection('usuarios').doc(userId).update({
        'viajeroFrecuente': true, // O el valor correspondiente
      });
    } catch (e) {
      print('Error al actualizar el estado de viajero frecuente: $e');
      throw Exception('Error al actualizar el estado de viajero frecuente: $e');
    }
  }

  Future<void> createBooking(Booking booking) async {
    try {
      print('Guardando reserva con ID: ${booking.id}');
      await _bookings.doc(booking.id).set(booking.toMap());
      print('Reserva guardada exitosamente.');

      // Actualizar el estado de viajero frecuente
      await _updateFrequentTravelerStatus(booking.usuarioId);
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
