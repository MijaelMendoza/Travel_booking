class HotelBooking {
  final String id;
  final String hotelName;
  final DateTime checkInDate;
  final DateTime checkOutDate;
  final int numberOfPeople;
  final String roomType;
  final double totalPrice;
  final String userId; // Relación con el usuario

  HotelBooking({
    required this.id,
    required this.hotelName,
    required this.checkInDate,
    required this.checkOutDate,
    required this.numberOfPeople,
    required this.roomType,
    required this.totalPrice,
    required this.userId,
  });

  // Convertir a mapa para la base de datos
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'hotelName': hotelName,
      'checkInDate': checkInDate.toIso8601String(),
      'checkOutDate': checkOutDate.toIso8601String(),
      'numberOfPeople': numberOfPeople,
      'roomType': roomType,
      'totalPrice': totalPrice,
      'userId': userId,
    };
  }

  // Crear desde un mapa
  factory HotelBooking.fromMap(Map<String, dynamic> map) {
    return HotelBooking(
      id: map['id'],
      hotelName: map['hotelName'],
      checkInDate: DateTime.parse(map['checkInDate']),
      checkOutDate: DateTime.parse(map['checkOutDate']),
      numberOfPeople: map['numberOfPeople'],
      roomType: map['roomType'],
      totalPrice: map['totalPrice'],
      userId: map['userId'],
    );
  }
}
