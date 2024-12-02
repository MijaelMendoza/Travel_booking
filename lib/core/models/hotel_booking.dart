import 'hotel.dart';

class HotelBooking {
  final String id; // Identificador único de la reserva
  final Hotel hotel; // Referencia al modelo de hotel
  final DateTime checkInDate; // Fecha de entrada
  final DateTime checkOutDate; // Fecha de salida
  final int numberOfGuests; // Número de huéspedes
  final String roomType; // Tipo de habitación seleccionada (de Hotel.roomTypes)
  final double totalPrice; // Precio total calculado
  final String userId; // Relación con el usuario que hizo la reserva

  HotelBooking({
    required this.id,
    required this.hotel,
    required this.checkInDate,
    required this.checkOutDate,
    required this.numberOfGuests,
    required this.roomType,
    required this.userId,
  }) : totalPrice = _calculateTotalPrice(
            hotel.pricePerNight, checkInDate, checkOutDate);

  // Calcular el precio total en base al precio por noche y la duración de la estancia
  static double _calculateTotalPrice(
      double pricePerNight, DateTime checkIn, DateTime checkOut) {
    final int nights = checkOut.difference(checkIn).inDays;
    return pricePerNight *
        (nights > 0 ? nights : 1); // Asegura al menos 1 noche
  }

  // Convertir la reserva a un mapa para guardar en la base de datos
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'hotelId': hotel.id,
      'checkInDate': checkInDate.toIso8601String(),
      'checkOutDate': checkOutDate.toIso8601String(),
      'numberOfGuests': numberOfGuests,
      'roomType': roomType,
      'totalPrice': totalPrice,
      'userId': userId,
    };
  }

  // Crear una instancia de HotelBooking a partir de un mapa y un hotel
  factory HotelBooking.fromMap(Map<String, dynamic> map, Hotel hotel) {
    return HotelBooking(
      id: map['id'] ?? '',
      hotel: hotel,
      checkInDate: DateTime.parse(
          map['checkInDate'] ?? DateTime.now().toIso8601String()),
      checkOutDate: DateTime.parse(
          map['checkOutDate'] ?? DateTime.now().toIso8601String()),
      numberOfGuests: map['numberOfGuests'] ?? 0,
      roomType: map['roomType'] ??
          hotel
              .roomTypes.first, // Selecciona el primer tipo si no está definido
      userId: map['userId'] ?? '',
    );
  }
}
