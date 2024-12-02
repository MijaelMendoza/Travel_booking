// lib/core/models/flight_reservation.dart
class FlightReservation {
  final String id;
  final String userId;
  final String flightId;
  final DateTime reservationDate;

  FlightReservation({
    required this.id,
    required this.userId,
    required this.flightId,
    required this.reservationDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'flightId': flightId,
      'reservationDate': reservationDate.toIso8601String(),
    };
  }

  factory FlightReservation.fromMap(Map<String, dynamic> map) {
    return FlightReservation(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      flightId: map['flightId'] ?? '',
      reservationDate: DateTime.parse(map['reservationDate']),
    );
  }
}
