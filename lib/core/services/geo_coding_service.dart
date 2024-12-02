import 'dart:convert';
import 'package:http/http.dart' as http;

class OpenCageGeocodingService {
  static const String _apiKey = "0014ef6d89aa4899b0cd2050f14978e6"; // Coloca tu API Key aquí
  static const String _baseUrl = "https://api.opencagedata.com/geocode/v1/json";

  Future<Map<String, double>> getCoordinates(String country) async {
    final url = Uri.parse("$_baseUrl?q=$country&key=$_apiKey");

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data['results'].isNotEmpty) {
        final firstResult = data['results'][0];
        final lat = firstResult['geometry']['lat'];
        final lon = firstResult['geometry']['lng'];

        return {"lat": lat, "lon": lon};
      } else {
        throw Exception("No se encontraron coordenadas para este país.");
      }
    } else {
      throw Exception(
          "Error al obtener coordenadas: ${response.statusCode} ${response.reasonPhrase}");
    }
  }
}
