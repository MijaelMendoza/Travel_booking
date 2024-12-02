// lib/core/models/airline.dart
class Airline {
  final String id;
  final String destination;
  final double price;
  final DateTime departureDate;
  final DateTime returnDate;
  final String airlineBrand; 

  Airline({
    required this.id,
    required this.destination,
    required this.price,
    required this.departureDate,
    required this.returnDate,
    required this.airlineBrand, 
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'destination': destination,
      'price': price,
      'departureDate': departureDate.toIso8601String(),
      'returnDate': returnDate.toIso8601String(),
      'airlineBrand': airlineBrand, // Nueva propiedad
    };
  }

  static Airline fromMap(Map<String, dynamic> map) {
    return Airline(
      id: map['id'],
      destination: map['destination'],
      price: map['price'],
      departureDate: DateTime.parse(map['departureDate']),
      returnDate: DateTime.parse(map['returnDate']),
      airlineBrand: map['airlineBrand'], // Nueva propiedad
    );
  }
}
