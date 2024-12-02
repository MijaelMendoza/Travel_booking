import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MyCarReservationsPage extends StatelessWidget {
  const MyCarReservationsPage({Key? key}) : super(key: key);

  Future<List<Map<String, dynamic>>> _fetchUserCarRentals() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return [];

    final snapshot = await FirebaseFirestore.instance
        .collection('rentals')
        .where('userId', isEqualTo: user.uid)
        .get();

    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Reservas de Autos"),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchUserCarRentals(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text("No tienes reservas realizadas."),
            );
          }

          final rentals = snapshot.data!;

          return ListView.builder(
            itemCount: rentals.length,
            itemBuilder: (context, index) {
              final rental = rentals[index];
              return Card(
                child: ListTile(
                  title: Text("Modelo: ${rental['model'] ?? 'Desconocido'}"),
                  subtitle: Text("Precio Total: \$${rental['totalAmount'] ?? 0.0}"),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
