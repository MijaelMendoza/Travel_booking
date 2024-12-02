class Hotel {
  final String id;
  final String name;
  final double rating; // Calificación del hotel
  final String description; // Descripción del hotel
  final String address; // Dirección del hotel
  final String city; // Ciudad donde está ubicado
  final String country; // País donde está ubicado
  final List<String> amenities; // Lista de servicios (WiFi, piscina, etc.)
  final List<String>
      roomTypes; // Lista de tipos de habitaciones (Ej: individual, doble, suite)
  final double pricePerNight; // Precio por noche
  final String imageUrl; // URL de una imagen representativa

  Hotel({
    required this.id,
    required this.name,
    required this.rating,
    required this.description,
    required this.address,
    required this.city,
    required this.country,
    required this.amenities,
    required this.roomTypes,
    required this.pricePerNight,
    required this.imageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'rating': rating,
      'description': description,
      'address': address,
      'city': city,
      'country': country,
      'amenities': amenities,
      'roomTypes': roomTypes,
      'pricePerNight': pricePerNight,
      'imageUrl': imageUrl,
    };
  }

  factory Hotel.fromMap(Map<String, dynamic> map) {
    return Hotel(
      id: map['id'] ?? '',
      name: map['name'] ?? 'Nombre desconocido',
      rating: (map['rating'] ?? 0).toDouble(),
      description: map['description'] ?? '',
      address: map['address'] ?? '',
      city: map['city'] ?? '',
      country: map['country'] ?? '',
      amenities: List<String>.from(map['amenities'] ?? []),
      roomTypes: List<String>.from(map['roomTypes'] ?? []),
      pricePerNight: (map['pricePerNight'] ?? map['price'] ?? 0.0).toDouble(),
      imageUrl: map['imageUrl'] ?? '',
    );
  }
}
