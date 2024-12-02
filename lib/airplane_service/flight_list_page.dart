import 'package:carretera/core/models/aerlineas.dart';
import 'package:carretera/core/models/flight_reservation.dart';
import 'package:carretera/core/services/aeroline_service.dart';
import 'package:flutter/material.dart';
import 'package:carretera/core/services/auth_service.dart';

class FlightListPage extends StatefulWidget {
  const FlightListPage({Key? key}) : super(key: key);

  @override
  State<FlightListPage> createState() => _FlightListPageState();
}

class _FlightListPageState extends State<FlightListPage> {
  final AirlineService _airlineService = AirlineService();
  final AuthService _authService = AuthService();
  final TextEditingController _searchController = TextEditingController();

  List<Airline> _flights = [];
  List<Airline> _filteredFlights = [];
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _checkAdmin();
    _loadFlights();
    _searchController.addListener(_filterFlights);
  }

  Future<void> _checkAdmin() async {
    try {
      final user = await _authService.getAuthenticatedUser();
      if (user != null && user.nivel == "admin") {
        setState(() {
          _isAdmin = true;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al verificar el nivel de usuario: $e')),
      );
    }
  }

  Future<void> _loadFlights() async {
    try {
      final flights = await _airlineService.getAllAirlines();
      setState(() {
        _flights = flights;
        _filteredFlights = flights; // Copia inicial para búsquedas
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar los vuelos: $e')),
      );
    }
  }

  void _filterFlights() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredFlights = _flights
          .where((flight) =>
              flight.airlineBrand.toLowerCase().contains(query) ||
              flight.destination.toLowerCase().contains(query))
          .toList();
    });
  }

  Future<void> _deleteFlight(String flightId) async {
    try {
      await _airlineService.deleteAirline(flightId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aerolínea eliminada correctamente')),
      );
      _loadFlights();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar la aerolínea: $e')),
      );
    }
  }
void _reserveFlight(Airline flight) async {
  try {
    final user = await _authService.getAuthenticatedUser();

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inicia sesión para reservar un vuelo.')),
      );
      return;
    }

    final reservation = FlightReservation(
      id: UniqueKey().toString(),
      userId: user.id,
      flightId: flight.id,
      reservationDate: DateTime.now(),
    );

    await _airlineService.createFlightReservation(reservation);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Vuelo reservado exitosamente.')),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error al reservar el vuelo: $e')),
    );
  }
}
  Future<void> _showFlightDialog({Airline? flight}) async {
    final TextEditingController brandController =
        TextEditingController(text: flight?.airlineBrand ?? '');
    final TextEditingController destinationController =
        TextEditingController(text: flight?.destination ?? '');
    final TextEditingController priceController =
        TextEditingController(text: flight?.price.toString() ?? '');
    final TextEditingController departureDateController =
        TextEditingController(
            text: flight?.departureDate.toIso8601String() ?? '');
    final TextEditingController returnDateController =
        TextEditingController(text: flight?.returnDate.toIso8601String() ?? '');
    final TextEditingController departureTimeController =
        TextEditingController(
            text: flight?.departureTime?.toIso8601String() ?? '');
    final TextEditingController returnTimeController =
        TextEditingController(text: flight?.returnTime?.toIso8601String() ?? '');

    final isEditing = flight != null;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEditing ? 'Editar Aerolínea' : 'Crear Aerolínea'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: brandController,
                decoration: const InputDecoration(labelText: 'Marca'),
              ),
              TextField(
                controller: destinationController,
                decoration: const InputDecoration(labelText: 'Destino'),
              ),
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Precio'),
              ),
              TextField(
                controller: departureDateController,
                readOnly: true,
                decoration: const InputDecoration(labelText: 'Fecha de salida'),
                onTap: () async {
                  final DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2023),
                    lastDate: DateTime(2123),
                  );
                  if (pickedDate != null) {
                    departureDateController.text = pickedDate.toIso8601String();
                  }
                },
              ),
              TextField(
                controller: returnDateController,
                readOnly: true,
                decoration: const InputDecoration(labelText: 'Fecha de regreso'),
                onTap: () async {
                  final DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2023),
                    lastDate: DateTime(2123),
                  );
                  if (pickedDate != null) {
                    returnDateController.text = pickedDate.toIso8601String();
                  }
                },
              ),
              TextField(
                controller: departureTimeController,
                readOnly: true,
                decoration: const InputDecoration(labelText: 'Hora de salida'),
                onTap: () async {
                  final TimeOfDay? pickedTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (pickedTime != null) {
                    departureTimeController.text = DateTime(
                      DateTime.now().year,
                      DateTime.now().month,
                      DateTime.now().day,
                      pickedTime.hour,
                      pickedTime.minute,
                    ).toIso8601String();
                  }
                },
              ),
              TextField(
                controller: returnTimeController,
                readOnly: true,
                decoration: const InputDecoration(labelText: 'Hora de regreso'),
                onTap: () async {
                  final TimeOfDay? pickedTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (pickedTime != null) {
                    returnTimeController.text = DateTime(
                      DateTime.now().year,
                      DateTime.now().month,
                      DateTime.now().day,
                      pickedTime.hour,
                      pickedTime.minute,
                    ).toIso8601String();
                  }
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final airline = Airline(
                id: flight?.id ?? UniqueKey().toString(),
                airlineBrand: brandController.text,
                destination: destinationController.text,
                price: double.tryParse(priceController.text) ?? 0.0,
                departureDate: DateTime.parse(departureDateController.text),
                returnDate: DateTime.parse(returnDateController.text),
                departureTime: DateTime.parse(departureTimeController.text),
                returnTime: DateTime.parse(returnTimeController.text),
              );

              if (isEditing) {
                await _airlineService.updateAirline(
                  airline.id,
                  airline.toMap(),
                );
              } else {
                await _airlineService.createAirline(airline);
              }

              Navigator.pop(context);
              _loadFlights();
            },
            child: Text(isEditing ? 'Guardar' : 'Crear'),
          ),
        ],
      ),
    );
  }


  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('Lista de Vuelos'),
      backgroundColor: Colors.blueGrey,
      actions: [
        if (_isAdmin)
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showFlightDialog(),
          ),
      ],
    ),
    body: Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              labelText: 'Buscar por destino o marca',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.search),
            ),
          ),
        ),
        Expanded(
          child: _filteredFlights.isEmpty
              ? const Center(
                  child: Text(
                    'No se encontraron vuelos.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  itemCount: _filteredFlights.length,
                  itemBuilder: (context, index) {
                    final flight = _filteredFlights[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8.0),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(
                            'assets/icons/airplane.jpg',
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          ),
                        ),
                        title: Text(
                          flight.airlineBrand,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Text(
                          '${flight.destination} - \$${flight.price.toStringAsFixed(2)}',
                          style:
                              TextStyle(fontSize: 14, color: Colors.grey[700]),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (_isAdmin)
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () =>
                                    _showFlightDialog(flight: flight),
                              ),
                            if (_isAdmin)
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => _deleteFlight(flight.id),
                              ),
                           
                              ElevatedButton(
                                onPressed: () => _reserveFlight(flight),
                                child: const Text('Reservar'),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    ),
  );
}


  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
