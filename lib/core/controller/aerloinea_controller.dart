import 'package:carretera/core/models/aerlineas.dart';
import 'package:carretera/core/services/aeroline_service.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AirlineController {
  final AirlineService _airlineService = AirlineService();

  static const String _apiKey = "xvyUCTIpUns94vg2o0Y8FkYFXj5RlRds";
  static const String _apiSecret = "IR6pcGkiTZHu6bM7";
  static const String _authUrl = "https://test.api.amadeus.com/v1/security/oauth2/token";
  static const String _flightsUrl = "https://test.api.amadeus.com/v1/shopping/flight-destinations";

  // Mapa de códigos IATA por país
final Map<String, List<String>> countryToIATA = {
  "Bolivia": ["PAR"], // GRU (São Paulo) como alternativa
  "United States": ["JFK", "LAX"],
  "France": ["CDG", "ORY"],
  "Germany": ["FRA", "MUC"],
};

  // Obtener el token de acceso
  Future<String?> _getAccessToken() async {
    try {
      final response = await http.post(
        Uri.parse(_authUrl),
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
        body: {
          "grant_type": "client_credentials",
          "client_id": _apiKey,
          "client_secret": _apiSecret,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data["access_token"];
      } else {
        print("Error obteniendo el token: ${response.body}");
        return null;
      }
    } catch (e) {
      print("Error en _getAccessToken: $e");
      return null;
    }
  }

  Future<List<Airline>> getFlightsFromAPI(String origin, double maxPrice) async {
  final token = await _getAccessToken();
  if (token == null) throw Exception("No se pudo obtener el token de Amadeus");

  try {
    final response = await http.get(
      Uri.parse(_flightsUrl).replace(queryParameters: {
        "origin": origin,
        "maxPrice": maxPrice.toString(),
      }),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      return (data["data"] as List).map((item) {
        final departureDateTime = DateTime.parse(item["departureDate"]);
        final returnDateTime = DateTime.parse(item["returnDate"]);

        return Airline(
          id: item["destination"] ?? UniqueKey().toString(),
          airlineBrand: "Amadeus",
          destination: item["destination"] ?? "Desconocido",
          price: double.tryParse(item["price"]["total"] ?? "0.0") ?? 0.0,
          departureDate: departureDateTime,
          returnDate: returnDateTime,
          departureTime: departureDateTime,
          returnTime: returnDateTime.add(Duration(hours: 2)), // Default
        );
      }).toList();
    } else {
      final errorDetails = json.decode(response.body);
      if (errorDetails["errors"]?[0]["code"] == 141) {
        print("Origen no compatible: $origin");
        throw Exception("El aeropuerto $origin no es soportado por la API de Amadeus.");
      }
      print("Error obteniendo vuelos: ${response.body}");
      throw Exception("Error en la API de Amadeus: ${response.body}");
    }
  } catch (e) {
    print("Error en getFlightsFromAPI: $e");
    throw Exception("Error al obtener vuelos");
  }
}

Future<void> fetchAndSaveFlights(String country, double maxPrice) async {
  try {
    final List<String>? iataCodes = countryToIATA[country];

    if (iataCodes == null || iataCodes.isEmpty) {
      throw Exception("No se encontró un código IATA para el país: $country");
    }

    Exception? lastError;
    for (final iataCode in iataCodes) {
      try {
        print("Intentando fetchAndSaveFlights para IATA: $iataCode");

        // Intentar obtener vuelos desde este aeropuerto
        final flights = await getFlightsFromAPI(iataCode, maxPrice);

        // Guardar vuelos en Firebase
        for (var flight in flights) {
          await _airlineService.createAirline(flight);
        }

        print("Vuelos guardados exitosamente desde $iataCode.");
        return; // Salir del bucle si se encuentra un aeropuerto válido
      } catch (e) {
        print("Error con aeropuerto $iataCode: $e");
        
      }
    }

    // Si todos los aeropuertos fallan, lanzar el último error
    if (lastError != null) throw lastError;
  } catch (e) {
    print("Error en fetchAndSaveFlights: $e");
    throw Exception("Error al procesar vuelos.");
  }
}


}
