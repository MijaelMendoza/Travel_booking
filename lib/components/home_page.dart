import 'package:carretera/airplane_service/flight_list_page.dart';
import 'package:carretera/carRental_service/car_list_client.dart';
import 'package:carretera/components/place.dart';
import 'package:carretera/core/models/aerlineas.dart';
import 'package:carretera/core/models/booking.dart';
import 'package:carretera/core/models/user.dart';
import 'package:carretera/core/services/aeroline_service.dart';
import 'package:carretera/core/services/booking_service.dart';
import 'package:carretera/core/services/payment_service.dart';
import 'package:carretera/core/services/ticket_service.dart';
import 'package:carretera/user_service/my_account.dart';
import 'package:carretera/user_service/my_hotel.dart';
import 'package:carretera/user_service/notifications_page.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../core/services/auth_service.dart'; // Asegúrate de agregar `uuid` en pubspec.yaml
import 'buttons.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final BookingService _bookingService = BookingService();
  final PaymentService _paymentService = PaymentService();
  final TicketService _ticketService = TicketService();
  final AuthService _authService = AuthService(); // Servicio de autenticación
  final Uuid _uuid = Uuid();
  final AirlineService _airlineService = AirlineService();
  List<Airline> _flights = [];

  String _selectedSortOption = 'Calificaciones';

  @override
  void initState() {
    super.initState();
    _loadFlights();
  }

  Future<void> _loadFlights() async {
    try {
      final flights = await _airlineService.getAllAirlines();
      setState(() {
        _flights = flights;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar los vuelos: $e')),
      );
    }
  }

  final List<String> stationNames = [
    'Playas de cancun',
    'Playa de maiami',
    'Caribe',
    'Himalaya',
  ];

  // Datos seleccionados
  String? fromStation;
  String? toStation;
  int passengers = 1;
  DateTime? selectedStartDate;
  DateTime? selectedEndDate;
  DateTime? selectedDate;

  Future<List<Booking>> _fetchBookings() async {
    Usuario? usuario = await _authService.getAuthenticatedUser();
    if (usuario == null) {
      throw Exception('Usuario no autenticado');
    }

    return await _bookingService.getUserBookings(usuario.id);
  }

  Widget _buildBookingsList() {
    return FutureBuilder<List<Booking>>(
      future: _fetchBookings(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }

        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        final bookings = snapshot.data ?? [];
        return ListView.builder(
          shrinkWrap: true, // Para que funcione dentro del `ListView` principal
          physics: const NeverScrollableScrollPhysics(),
          itemCount: bookings.length,
          itemBuilder: (context, index) {
            final booking = bookings[index];
            return ListTile(
              title: Text('Reserva: ${booking.tourId}'),
              subtitle: Text('Fecha: ${booking.fechaInicio.toLocal()}'),
            );
          },
        );
      },
    );
  }

  void _createBooking() async {
    if (fromStation == null ||
        toStation == null ||
        selectedStartDate == null ||
        selectedEndDate == null ||
        passengers <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor completa todos los campos')),
      );
      return;
    }

    final usuario = await _authService.getAuthenticatedUser();
    if (usuario == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuario no autenticado')),
      );
      return;
    }

    final booking = Booking(
      id: _uuid.v4(),
      usuarioId: usuario.id, // ID del usuario autenticado
      tourId: 'tour456', // Cambiar por el ID del tour seleccionado
      fechaInicio: selectedStartDate!,
      fechaFin: selectedEndDate!,
      pasajeros: passengers,
      precioTotal: 1020.00, // Calcular dinámicamente según lógica
    );

    try {
      await _bookingService.createBooking(booking);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reserva creada exitosamente')),
      );

      // Navegar a la siguiente página
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const ElysiumColony(),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al crear la reserva: $e')),
      );
    }
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2160),
    );

    if (pickedDate != null) {
      setState(() {
        if (isStartDate) {
          selectedStartDate = pickedDate;
        } else {
          selectedEndDate = pickedDate;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double displayWidth = MediaQuery.of(context).size.width;
    double accountButtonHeight = 75.0;
    double spaceBetweenButtons = 16.0;

    return Scaffold(
        backgroundColor: Colors.white,
        body: ListView(
          children: [
            // Account button and notification button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: FittedBox(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const MyAccountPage()));
                      },
                      child: Container(
                        height: accountButtonHeight,
                        width: displayWidth * 0.7,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color.fromARGB(255, 1, 73, 255),
                              Color.fromARGB(255, 162, 221, 255)
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(100.0),
                        ),
                        child: const Row(
                          children: [
                            SizedBox(width: 10),
                            CircleAvatar(
                              radius: 30,
                              backgroundImage:
                                  AssetImage('assets/images/profile.png'),
                            ),
                            SizedBox(width: 5),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 10.0),
                                  child: Text(
                                    'Nombre de Usuario',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 10.0),
                                  child: Text(
                                    'User ID: 123456',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: spaceBetweenButtons),
                    Material(
                      elevation: 2.0,
                      borderRadius: BorderRadius.circular(20.0),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const NotificationsPage()));
                        },
                        child: Container(
                          width: accountButtonHeight,
                          height: accountButtonHeight,
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 255, 255, 255),
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          child: const Center(
                            child: ImageIcon(
                              AssetImage('assets/images/bell.png'),
                              color: Colors.blue,
                              size: 32,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Search bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                height: 400,
                width: displayWidth,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(displayWidth * 0.03),
                  color: Color.fromARGB(255, 255, 255, 255),
                  boxShadow: [
                    BoxShadow(
                      color:
                          const Color.fromARGB(255, 0, 0, 0).withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, 0),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    const Text(
                      "Encuentra tu tour",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 0, 0, 0),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // "FROM"
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 10.0),
                      child: Autocomplete<String>(
                        optionsBuilder: (textEditingValue) {
                          return stationNames.where((option) => option
                              .toLowerCase()
                              .contains(textEditingValue.text.toLowerCase()));
                        },
                        onSelected: (value) {
                          setState(() {
                            fromStation = value; // Actualiza correctamente
                          });
                        },
                        fieldViewBuilder:
                            (context, controller, focusNode, onFieldSubmitted) {
                          return TextField(
                            controller: controller,
                            focusNode: focusNode,
                            decoration: InputDecoration(
                              labelText: "Desde",
                              border: OutlineInputBorder(),
                            ),
                          );
                        },
                      ),
                    ),

                    // "TO"
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 10.0),
                      child: Autocomplete<String>(
                        optionsBuilder: (textEditingValue) {
                          return stationNames.where((option) => option
                              .toLowerCase()
                              .contains(textEditingValue.text.toLowerCase()));
                        },
                        onSelected: (value) {
                          setState(() {
                            toStation = value; // Actualiza correctamente
                          });
                        },
                        fieldViewBuilder:
                            (context, controller, focusNode, onFieldSubmitted) {
                          return TextField(
                            controller: controller,
                            focusNode: focusNode,
                            decoration: InputDecoration(
                              labelText: "Hasta",
                              border: OutlineInputBorder(),
                            ),
                          );
                        },
                      ),
                    ),

                    // "DATE" and "PASSENGERS"
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 10),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Pasajeros',
                                hintText: "Número de pasajeros",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16.0),
                                ),
                              ),
                              onChanged: (value) {
                                setState(() {
                                  passengers = int.tryParse(value) ??
                                      1; // Valor predeterminado
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              readOnly: true,
                              onTap: () => _selectDate(context, true),
                              decoration: InputDecoration(
                                labelText: 'Fecha de inicio',
                                hintText: "Selecciona la fecha",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16.0),
                                ),
                              ),
                              controller: TextEditingController(
                                text: selectedStartDate != null
                                    ? '${selectedStartDate!.year}-${selectedStartDate!.month}-${selectedStartDate!.day}'
                                    : '',
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              readOnly: true,
                              onTap: () => _selectDate(context, false),
                              decoration: InputDecoration(
                                labelText: 'Fecha de salida',
                                hintText: "Selecciona la fecha",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16.0),
                                ),
                              ),
                              controller: TextEditingController(
                                text: selectedEndDate != null
                                    ? '${selectedEndDate!.year}-${selectedEndDate!.month}-${selectedEndDate!.day}'
                                    : '',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // "SEARCH" button
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: GradientButton(
                        onPressed:
                            _createBooking, // Llama a la función modificada
                        height: 60.0,
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search,
                              color: Colors.white,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Buscar',
                              style: TextStyle(
                                  fontSize: 16.0, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Best destinations container
            Padding(
              padding: EdgeInsets.symmetric(vertical: displayWidth * .05),
              child: Container(
                height: 400,
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 255, 255, 255),
                  boxShadow: [
                    BoxShadow(
                      color: Color.fromARGB(50, 50, 50, 50),
                      // offset: Offset(0.0, 0.0),
                      blurRadius: 5,
                      // spreadRadius: 1,
                      // inset: true,
                    ),
                    BoxShadow(
                      color: Color.fromARGB(50, 50, 50, 50),
                      // offset: Offset(0.0, 0.0),
                      blurRadius: 5,
                      // spreadRadius: 1,
                      // inset: true,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: displayWidth * .05,
                          vertical: displayWidth * .025),
                      child: Padding(
                        padding: EdgeInsets.only(top: displayWidth * .025),
                        child: Text(
                          'Mejores Destinos',
                          style: TextStyle(
                            fontSize: displayWidth * .05,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          LocationButton(
                            imageAsset: 'assets/images/location1.png',
                            title: 'Playas de cancun\n',
                            description: 'Destino',
                            onTap: () {
                              // Navigate to the related pages
                            },
                          ),
                          LocationButton(
                            imageAsset: 'assets/images/location2.png',
                            title: 'Playas de miami\n',
                            description: 'Destino',
                            onTap: () {
                              // Navigate to the related pages
                            },
                          ),
                          LocationButton(
                            imageAsset: 'assets/images/location3.png',
                            title: 'Caribe\n',
                            description: 'Destino',
                            onTap: () {
                              // Navigate to the related pages
                            },
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: displayWidth * .025),
                  ],
                ),
              ),
            ),

            // The best tours container
            Padding(
              padding: EdgeInsets.all(displayWidth * 0.05),
              child: SizedBox(
                height: displayWidth * 1.4,
                width: double.infinity,
                child: Column(
                  children: [
                    Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: displayWidth * 0.025),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(top: displayWidth * 0.01),
                            child: Text(
                              'Métodos de viaje',
                              style: TextStyle(
                                fontSize: displayWidth * 0.05,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: displayWidth * 0.01),
                            child: TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const FlightListPage(),
                                  ),
                                );
                              },
                              child: const Text("Más"),
                            ),
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: displayWidth * 0.01),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Ordenar por',
                            style: TextStyle(
                              fontSize: displayWidth * 0.04,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          SizedBox(width: displayWidth * 0.02),
                          DropdownButton<String>(
                            value: _selectedSortOption,
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedSortOption = newValue!;
                              });
                            },
                            items: <String>[
                              'Calificaciones',
                              'Precio',
                              'Capacidad',
                            ].map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                          itemCount: _flights.length > 4 ? 4 : _flights.length, // Máximo 3 elementos,
                        itemBuilder: (context, index) {
                          final flight = _flights[index];
                          return LongButton(
                            imageAsset:   'assets/icons/airplane.jpg', 
                            description: 'Destino: ${flight.destination}\n'
                                'Precio: ${flight.price} EUR\n'
                                'Salida: ${flight.departureDate.toLocal()}',
                            title: flight.airlineBrand,
                            backgroundColor:
                                const Color.fromARGB(255, 9, 0, 136),
                            onTap: () {
                              // Acción al tocar el botón del vuelo (si es necesario)
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Dentro del método build de HomePage
            Padding(
              padding: EdgeInsets.symmetric(vertical: displayWidth * 0.05),
              child: Container(
                height: 300,
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 255, 255, 255),
                  boxShadow: [
                    BoxShadow(
                      color: Color.fromARGB(50, 50, 50, 50),
                      blurRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: displayWidth * 0.05,
                        vertical: displayWidth * 0.025,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Los Mejores Hoteles',
                            style: TextStyle(
                              fontSize: displayWidth * 0.05,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MyHotelsPage(),
                                ),
                              );
                            },
                            child: Text(
                              "Más",
                              style: TextStyle(fontSize: displayWidth * 0.04),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: displayWidth * 0.05),
                      child: Container(
                        height: 200,
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(
                              255, 0, 0, 136), // Fondo azul
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 5,
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // Imagen del hotel
                            ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(16),
                                bottomLeft: Radius.circular(16),
                              ),
                              child: Image.asset(
                                'assets/images/location3.png',
                                width: displayWidth * 0.4,
                                height: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 10),
                            // Información del hotel
                            Expanded(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Hotel Paradise',
                                      style: TextStyle(
                                        fontSize: displayWidth * 0.05,
                                        fontWeight: FontWeight.bold,
                                        color: Colors
                                            .white, // Color del texto blanco
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      '4/5',
                                      style: TextStyle(
                                        fontSize: displayWidth * 0.04,
                                        fontWeight: FontWeight.normal,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // Flecha de navegación
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Icon(
                                Icons.arrow_forward_ios,
                                size: displayWidth * 0.05,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: displayWidth * 0.05),
              child: Container(
                height: 300,
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 255, 255, 255),
                  boxShadow: [
                    BoxShadow(
                      color: Color.fromARGB(50, 50, 50, 50),
                      blurRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: displayWidth * 0.05,
                        vertical: displayWidth * 0.025,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Renta de autos',
                            style: TextStyle(
                              fontSize: displayWidth * 0.05,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CarListScreenClient(),
                                ),
                              );
                            },
                            child: Text(
                              "Más",
                              style: TextStyle(fontSize: displayWidth * 0.04),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: displayWidth * 0.05),
                      child: Container(
                        height: 200,
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(
                              255, 0, 0, 136), // Fondo azul
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 5,
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // Imagen del hotel
                            ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(16),
                                bottomLeft: Radius.circular(16),
                              ),
                              child: Image.asset(
                                'assets/images/rentcar.jpg',
                                width: displayWidth * 0.4,
                                height: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 10),
                            // Información del hotel
                            Expanded(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Toyota',
                                      style: TextStyle(
                                        fontSize: displayWidth * 0.05,
                                        fontWeight: FontWeight.bold,
                                        color: Colors
                                            .white, // Color del texto blanco
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      '70',
                                      style: TextStyle(
                                        fontSize: displayWidth * 0.04,
                                        fontWeight: FontWeight.normal,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // Flecha de navegación
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Icon(
                                Icons.arrow_forward_ios,
                                size: displayWidth * 0.05,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ));
  }
}
