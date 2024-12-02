import 'package:carretera/airplane_service/my_fligh_reservation.dart';
import 'package:carretera/carRental_service/my_car_reservation.dart';
import 'package:carretera/core/controller/aerloinea_controller.dart';
import 'package:carretera/core/controller/car_controller.dart';
import 'package:carretera/core/controller/holel_controller.dart';
import 'package:carretera/core/models/user.dart';
import 'package:carretera/core/services/geo_coding_service.dart';
import 'package:flutter/material.dart';
import 'package:carretera/core/services/auth_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'my_hotel_b.dart';


class MyAccountPage extends StatefulWidget {
  const MyAccountPage({Key? key}) : super(key: key);

  @override
  State<MyAccountPage> createState() => _MyAccountPageState();
}

class _MyAccountPageState extends State<MyAccountPage> {
  final AuthService _authService = AuthService();
  Usuario? _authenticatedUser;

  // Estado para país
  String? _selectedCountry = 'Bolivia';
  List<String> _countries = [];

  // Pantalla actual para mostrar en el cuerpo principal
  Widget _currentScreen = const Center(
    child: Text(
      "Selecciona una opción en el menú lateral.",
      style: TextStyle(fontSize: 18, color: Colors.black54),
    ),
  );

  @override
  void initState() {
    super.initState();
    _loadAuthenticatedUser();
    _fetchCountries();
  }

  Future<void> _loadAuthenticatedUser() async {
    try {
      final user = await _authService.getAuthenticatedUser();
      setState(() {
        _authenticatedUser = user;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Error al cargar la información del usuario: $e')),
      );
    }
  }

  Future<void> _fetchCountries() async {
    try {
      final response =
          await http.get(Uri.parse('https://restcountries.com/v3.1/all'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _countries = data
              .map((country) => country['name']['common'] as String)
              .toList();
          _countries.sort();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al obtener la lista de países.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al obtener la lista de países: $e')),
      );
    }
  }

  void _setScreen(Widget screen) {
    setState(() {
      _currentScreen = screen;
    });
    Navigator.pop(context); // Cierra el Drawer al seleccionar una opción
  }

  void _onCountrySelected(String country) async {
    setState(() {
      _selectedCountry = country;
    });

    final geocodingService = OpenCageGeocodingService();
    final hotelController = HotelController();
    final airlineController = AirlineController();
    final carController = CarController();

    try {
      // Obtener coordenadas del país seleccionado
      final coordinates = await geocodingService.getCoordinates(country);
      final lat = coordinates["lat"]!;
      final lon = coordinates["lon"]!;

      // Guardar hoteles cercanos en Firebase
      await hotelController.fetchAndSaveHotels(lat, lon);

      // Guardar aerolíneas
      await airlineController.fetchAndSaveFlights(country, 500);

      // Guardar autos
      await carController.fetchAndSaveCars();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Datos guardados exitosamente.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al procesar el país seleccionado: $e')),
      );
    }
  }

  Widget _buildAccountInfoScreen() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: _authenticatedUser == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Información de la cuenta",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.blue,
                      child: Icon(
                        Icons.person,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              "Nombre: ${_authenticatedUser?.nombre ?? 'No disponible'}"),
                          Text(
                              "Email: ${_authenticatedUser?.email ?? 'No disponible'}"),
                          Text(
                              "Nivel: ${_authenticatedUser?.nivel ?? 'No disponible'}"),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                DropdownButton<String>(
                  value: _selectedCountry,
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      _onCountrySelected(newValue);
                    }
                  },
                  items:
                      _countries.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ],
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mi Cuenta"),
        backgroundColor: Colors.blue,
      ),
      drawer: Drawer(
        child: SingleChildScrollView(
          child: Column(
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.blue.shade700,
                ),
                child: _authenticatedUser == null
                    ? const Center(child: CircularProgressIndicator())
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const CircleAvatar(
                            radius: 40,
                            backgroundColor: Colors.white,
                            child: Icon(
                              Icons.person,
                              size: 40,
                              color: Colors.blue,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            _authenticatedUser?.nombre ?? "Nombre de Usuario",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
              ),
              ListTile(
                leading: const Icon(Icons.person, color: Colors.blue),
                title: const Text("Información de la cuenta"),
                onTap: () {
                  _setScreen(_buildAccountInfoScreen());
                },
              ),
              ListTile(
                leading: const Icon(Icons.hotel, color: Colors.blue),
                title: const Text("Reservas de hoteles"),
                onTap: () {
                  _setScreen(const MyHotelBPage(showInOverlay: true));
                },
              ),
              ListTile(
                leading: const Icon(Icons.car_rental, color: Colors.blue),
                title: const Text("Reservas de autos"),
                onTap: () {
                  _setScreen(const MyCarReservationsPage());
                },
              ),
              ListTile(
                leading: const Icon(Icons.flight, color: Colors.blue),
                title: const Text("Reservas de aviones"),
                onTap: () {
                  _setScreen(const MyFlightReservationsPage());
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.blue),
                title: const Text("Cerrar sesión"),
                onTap: () async {
                  await _authService.signOut();
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Sesión cerrada correctamente')),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _currentScreen,
      ),
    );
  }
}
