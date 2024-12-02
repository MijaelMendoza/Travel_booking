import 'package:carretera/core/services/aeroline_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:carretera/core/models/aerlineas.dart';

class MyFlightReservationsPage extends StatelessWidget {
  const MyFlightReservationsPage({Key? key}) : super(key: key);

  Future<List<Map<String, dynamic>>> _fetchUserFlightReservations() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return [];

    final snapshot = await FirebaseFirestore.instance
        .collection('flight_reservations')
        .where('userId', isEqualTo: user.uid)
        .get();

    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  Future<Airline?> _fetchFlightDetails(String flightId) async {
    final airlineService = AirlineService();
    return await airlineService.getAirlineById(flightId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Reservas de Aviones"),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchUserFlightReservations(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text("No tienes reservas realizadas."),
            );
          }

          final reservations = snapshot.data!;

          return ListView.builder(
            itemCount: reservations.length,
            itemBuilder: (context, index) {
              final reservation = reservations[index];
              final flightId = reservation['flightId'] ?? 'ID desconocido';
              final reservationDate =
                  DateTime.parse(reservation['reservationDate'] ?? DateTime.now().toString());

              return FutureBuilder<Airline?>(
                future: _fetchFlightDetails(flightId),
                builder: (context, flightSnapshot) {
                  if (flightSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!flightSnapshot.hasData) {
                    return Card(
                      child: ListTile(
                        title: Text("Vuelo no encontrado"),
                        subtitle: Text("ID del vuelo: $flightId"),
                      ),
                    );
                  }

                  final flight = flightSnapshot.data!;
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      title: Text("Destino: ${flight.destination}"),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Marca: ${flight.airlineBrand}"),
                          Text("Precio: \$${flight.price.toStringAsFixed(2)}"),
                          Text(
                              "Fecha de reserva: ${reservationDate.day}/${reservationDate.month}/${reservationDate.year}"),
                          Text(
                              "Salida: ${flight.departureDate.day}/${flight.departureDate.month}/${flight.departureDate.year}"),
                          Text(
                              "Regreso: ${flight.returnDate.day}/${flight.returnDate.month}/${flight.returnDate.year}"),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
