import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:carretera/core/models/car.dart';
import 'package:carretera/core/services/rental_car_service.dart';

class CarController {
  final RentalCarService _rentalCarService = RentalCarService();

  static const String _apiKey = "tM5d+DaSx6AMsRQQr2BNRA==8dtl48kHLnL7Fzno";
  static const String _baseUrl = "https://api.api-ninjas.com/v1/cars";

  // Obtener autos aleatorios desde la API
  Future<List<Car>> fetchCarsFromAPI({String make = "toyota"}) async {
  try {
    final response = await http.get(
      Uri.parse("https://api.api-ninjas.com/v1/cars?make=$make"),
      headers: {"X-Api-Key": _apiKey},
    );

    if (response.statusCode == 200) {
      final data = List<Map<String, dynamic>>.from(json.decode(response.body));
      final cars = <Car>[];

      for (var i = 0; i < 5 && i < data.length; i++) {
        final carData = data[i];
        final car = Car(
          model: carData["model"] ?? "Modelo desconocido",
          brand: carData["make"] ?? "Marca desconocida",
          price: (carData["price"] ?? 20000).toDouble(),
          imageUrls: [
            "" // URL genérica si no hay imágenes
          ],
          description: carData["fuel_efficiency"] != null
              ? "Consumo de combustible: ${carData['fuel_efficiency']} km/l"
              : "Descripción no disponible",
          isAvailable: true,
          userId: "system", // Identificador predeterminado para el sistema
        );
        cars.add(car);
      }
      return cars;
    } else {
      // Registrar el error completo para depuración
      print("Error al obtener autos de la API: ${response.statusCode}");
      print("Respuesta del servidor: ${response.body}");
      throw Exception("Error al obtener autos de la API: ${response.statusCode}");
    }
  } catch (e) {
    print("Error en fetchCarsFromAPI: $e");
    throw Exception("Error al obtener autos de la API.");
  }
}

Future<void> fetchAndSaveCars({String make = "toyota"}) async {
  try {
    print("Iniciando fetchAndSaveCars para marca: $make...");

    // Obtener autos desde la API
    final cars = await fetchCarsFromAPI(make: make);

    // Guardar autos en Firebase
    for (var car in cars) {
      await _rentalCarService.registerCar(
        model: car.model,
        brand: car.brand,
        price: car.price,
        carImages: [], // No usamos imágenes locales aquí
        description: car.description,
        isAvailable: car.isAvailable,
      );
    }

    print("Autos guardados exitosamente.");
  } catch (e) {
    print("Error en fetchAndSaveCars: $e");
    throw Exception("Error al procesar autos.");
  }
}

}
