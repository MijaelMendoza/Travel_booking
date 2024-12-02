import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
              return Card(
                child: ListTile(
                  title: Text("Destino: ${reservation['destination'] ?? 'Desconocido'}"),
                  subtitle: Text("Precio: \$${reservation['price'] ?? 0.0}"),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
