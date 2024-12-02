// lib/pages/flight_list_page.dart
import 'package:carretera/core/models/aerlineas.dart';
import 'package:carretera/core/services/aeroline_service.dart';
import 'package:flutter/material.dart';


class FlightListPage extends StatefulWidget {
  const FlightListPage({Key? key}) : super(key: key);

  @override
  State<FlightListPage> createState() => _FlightListPageState();
}

class _FlightListPageState extends State<FlightListPage> {
  final AirlineService _airlineService = AirlineService();
  List<Airline> _flights = [];

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
        leading: IconButton(
          icon: const Icon(Icons.add),
          onPressed: () => _showFlightDialog(),
        ),
      ),
      body: _flights.isEmpty
          ? const Center(
              child: Text(
                'No hay vuelos registrados.',
                style: TextStyle(fontSize: 16),
              ),
            )
          : ListView.builder(
              itemCount: _flights.length,
              itemBuilder: (context, index) {
                final flight = _flights[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    children: [
                      // Default image for the flight
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.asset(
                            'assets/images/airplane.jpg', // Default image
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Marca: ${flight.airlineBrand}',
                                style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'Destino: ${flight.destination}',
                                style: const TextStyle(fontSize: 14),
                              ),
                              Text(
                                'Precio: ${flight.price.toStringAsFixed(2)} EUR',
                                style: const TextStyle(fontSize: 14),
                              ),
                              Text(
                                'Salida: ${flight.departureDate.toLocal()}',
                                style: const TextStyle(fontSize: 14),
                              ),
                              Text(
                                'Regreso: ${flight.returnDate.toLocal()}',
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _showFlightDialog(flight: flight),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _deleteFlight(flight.id),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
