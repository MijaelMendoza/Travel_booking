import 'package:carretera/core/models/hotel.dart';
import 'package:carretera/core/services/hotel_service.dart';

class HotelController {
  final HotelService _hotelService = HotelService();

  // Guardar hoteles desde la API
  Future<void> fetchAndSaveHotels(double latitude, double longitude) async {
    print("Iniciando fetchAndSaveHotels en lat: $latitude, lon: $longitude");
    try {
      // Aumenta el radio a 10000 metros y el límite a 50
      final hotels = await _hotelService.getHotelsNearby(
        lat: latitude,
        lon: longitude,
        radius: 100000, // Aumentado a 10 km
        limit: 20,    // Incrementado a 50 resultados
      );

      if (hotels.isEmpty) {
        print("No se encontraron hoteles cercanos.");
        return;
      }

      for (var hotelData in hotels) {
        print("Procesando hotel: ${hotelData['name'] ?? 'Sin nombre'}");

        final xid = hotelData["xid"];
        print("Obteniendo detalles para XID: $xid");
        final hotelDetails = await _hotelService.getHotelDetails(xid);

        final hotel = Hotel(
          id: hotelDetails["xid"] ?? xid,
          name: hotelDetails["name"] ?? "Nombre desconocido",
          rating: 4.0, // Valor default
          description: hotelDetails["info"]?["descr"] ?? "No disponible",
          address: hotelDetails["address"]?["road"] ?? "Dirección desconocida",
          city: hotelDetails["address"]?["city"] ?? "La Paz",
          country: hotelDetails["address"]?["country"] ?? "País desconocido",
          amenities: ["WiFi", "Desayuno"],
          roomTypes: ["Individual", "Doble"],
          pricePerNight: 120.0, // Precio default
          imageUrl: hotelDetails["image"] ?? "",
        );

        // Llamar a la función para guardar el hotel
        print("Guardando hotel: ${hotel.name}");
        await _saveHotel(hotel);
      }
    } catch (e) {
      print("Error en fetchAndSaveHotels: $e");
      throw Exception("Error al procesar hoteles.");
    }
  }

  // Método para guardar un hotel en Firebase
  Future<void> _saveHotel(Hotel hotel) async {
    try {
      print("Intentando guardar hotel en Firebase: ${hotel.name}");
      await _hotelService.createHotel(hotel);
      print("Hotel guardado exitosamente en Firebase: ${hotel.name}");
    } catch (e) {
      print("Error al guardar el hotel en Firebase: $e");
    }
  }
}
