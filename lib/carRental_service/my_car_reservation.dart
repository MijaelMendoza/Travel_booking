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

    final List<Map<String, dynamic>> rentals = [];

    for (var rentalDoc in snapshot.docs) {
      final rentalData = rentalDoc.data();
      final carSnapshot = await FirebaseFirestore.instance
          .collection('cars')
          .doc(rentalData['carId'])
          .get();

      if (carSnapshot.exists) {
        final carData = carSnapshot.data();
        rentalData['carModel'] = carData?['model'] ?? 'Desconocido';
        rentalData['carBrand'] = carData?['brand'] ?? 'Desconocido';
        rentalData['carImages'] = carData?['image_urls'] ?? [];
      }

      rentals.add(rentalData);
    }

    return rentals;
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
              String? imageUrl = rental['carImages'].isNotEmpty
                  ? rental['carImages'][0]
                  : 'assets/icons/auto.jpg';

              return Card(
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: Image.network(
                      imageUrl!,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                  title: Text("Modelo: ${rental['carModel'] ?? 'Desconocido'}"),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Marca: ${rental['carBrand'] ?? 'Desconocido'}"),
                      Text("Precio Total: \$${rental['totalAmount'] ?? 0.0}"),
                      Text("Fechas: ${rental['startDate']} - ${rental['endDate']}"),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
