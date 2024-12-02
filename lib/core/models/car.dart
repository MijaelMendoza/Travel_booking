class Car {
  final String model;
  final String brand;
  final double price;
  final List<String> imageUrls;
  final String description;
  final bool isAvailable;
  final String userId;
  final String? carUid;  // Este es el UID de Firestore, opcional.

  Car({
    required this.model,
    required this.brand,
    required this.price,
    required this.imageUrls,
    required this.description,
    required this.isAvailable,
    required this.userId,
    this.carUid,
  });

  // Convertir el objeto Car a un mapa para Firestore
  Map<String, dynamic> toMap() {
    return {
      'model': model,
      'brand': brand,
      'price': price,
      'image_urls': imageUrls,
      'description': description,
      'is_available': isAvailable,
      'user_id': userId,
    };
  }

  // Crear un objeto Car desde un mapa de Firestore
  factory Car.fromMap(Map<String, dynamic> map, String documentId) {
    return Car(
      model: map['model'],
      brand: map['brand'],
      price: map['price'],
      imageUrls: List<String>.from(map['image_urls']),
      description: map['description'],
      isAvailable: map['is_available'],
      userId: map['user_id'],
      carUid: documentId, // El ID del documento de Firestore
    );
  }
}
