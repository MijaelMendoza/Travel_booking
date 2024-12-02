class Airline {
  final String id;
  final String destination;
  final double price;
  final DateTime departureDate;
  final DateTime returnDate;
  final String airlineBrand;
  final DateTime departureTime;
  final DateTime returnTime;

  Airline({
    required this.id,
    required this.destination,
    required this.price,
    required this.departureDate,
    required this.returnDate,
    required this.airlineBrand,
    required this.departureTime,
    required this.returnTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'destination': destination,
      'price': price,
      'departureDate': departureDate.toIso8601String(),
      'returnDate': returnDate.toIso8601String(),
      'airlineBrand': airlineBrand,
      'departureTime': departureTime.toIso8601String(),
      'returnTime': returnTime.toIso8601String(),
    };
  }

  static Airline fromMap(Map<String, dynamic> map) {
    return Airline(
      id: map['id'] ?? '', // Valor predeterminado para ID
      destination: map['destination'] ?? 'Destino desconocido', // Predeterminado
      price: (map['price'] ?? 0.0).toDouble(), // Asegura un valor numérico
      departureDate: map['departureDate'] != null
          ? DateTime.parse(map['departureDate'])
          : DateTime.now(), // Fecha predeterminada
      returnDate: map['returnDate'] != null
          ? DateTime.parse(map['returnDate'])
          : DateTime.now().add(const Duration(days: 1)), // Fecha predeterminada
      airlineBrand: map['airlineBrand'] ?? 'Marca desconocida', // Predeterminado
      departureTime: map['departureTime'] != null
          ? DateTime.parse(map['departureTime'])
          : DateTime.now(), // Hora predeterminada
      returnTime: map['returnTime'] != null
          ? DateTime.parse(map['returnTime'])
          : DateTime.now().add(const Duration(hours: 2)), // Hora predeterminada
    );
  }
}
