import 'dart:convert';

import 'package:http/http.dart' as http;

class CountriesApi {
  static const String _baseAuthUrl =
      'https://www.universal-tutorial.com/api/getaccesstoken';
  static const String _baseDataUrl = 'https://www.universal-tutorial.com/api';
  static const String _apiKey =
      'wy2_bvzU-iz67TPHK7lgKm04_h714UlE5aNuTjkJcpK4zf7OcoTQS0IyNJwb0TgS4eY';

  /// Obtiene el token de acceso de la API.
  static Future<String> _fetchAccessToken() async {
    try {
      final response = await http.get(
        Uri.parse(_baseAuthUrl),
        headers: {
          'Accept': 'application/json',
          'api-token': _apiKey,
          'user-email':
              'abelignaciogarcia89@gmail.com', // Reemplaza con tu correo registrado
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return data['auth_token'];
      } else {
        throw Exception(
            'Error al obtener el token de acceso: ${response.body}');
      }
    } catch (e) {
      print('Error en _fetchAccessToken: $e');
      throw Exception('No se pudo obtener el token de acceso');
    }
  }

  /// Obtiene la lista de países.
  static Future<List<String>> fetchCountries() async {
    try {
      final token = await _fetchAccessToken();
      final response = await http.get(
        Uri.parse('$_baseDataUrl/countries/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> countriesJson = jsonDecode(response.body);
        return countriesJson
            .map((country) => country['country_name'].toString())
            .toList();
      } else {
        throw Exception('Error al cargar la lista de países: ${response.body}');
      }
    } catch (e) {
      print('Error en fetchCountries: $e');
      throw Exception('No se pudo cargar la lista de países');
    }
  }

  /// Obtiene la lista de estados según el país seleccionado.
  static Future<List<String>> fetchCities(String country) async {
    try {
      final token = await _fetchAccessToken();
      final response = await http.get(
        Uri.parse('$_baseDataUrl/states/$country'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> citiesJson = jsonDecode(response.body);
        return citiesJson.map((city) => city['state_name'].toString()).toList();
      } else {
        throw Exception(
            'Error al cargar la lista de ciudades: ${response.body}');
      }
    } catch (e) {
      print('Error en fetchCities: $e');
      throw Exception('No se pudo cargar la lista de ciudades');
    }
  }
}
