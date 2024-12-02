import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MyHotelBPage extends StatelessWidget {
  const MyHotelBPage({Key? key}) : super(key: key);

  Future<List<Map<String, dynamic>>> _fetchUserBookings() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return [];

    final snapshot = await FirebaseFirestore.instance
        .collection('hotel_bookings')
        .where('userId', isEqualTo: user.uid)
        .get();

    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mis Reservas"),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchUserBookings(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                "No tienes reservas realizadas.",
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          final bookings = snapshot.data!;

          return ListView.builder(
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final booking = bookings[index];
              final checkInDate = DateTime.parse(booking['checkInDate']);
              final checkOutDate = DateTime.parse(booking['checkOutDate']);
              final formattedCheckIn =
                  "${checkInDate.day}/${checkInDate.month}/${checkInDate.year}";
              final formattedCheckOut =
                  "${checkOutDate.day}/${checkOutDate.month}/${checkOutDate.year}";

              return Card(
                margin: const EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text(booking['hotelName'] ?? 'Nombre no disponible'),
                  subtitle: Text(
                      "Desde: $formattedCheckIn - Hasta: $formattedCheckOut"),
                  trailing: Text(
                    "\$${booking['totalPrice']?.toStringAsFixed(2) ?? '0.00'}",
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onTap: () {
                    _showBookingDetails(context, booking);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showBookingDetails(BuildContext context, Map<String, dynamic> booking) {
    final checkInDate = DateTime.parse(booking['checkInDate']);
    final checkOutDate = DateTime.parse(booking['checkOutDate']);
    final formattedCheckIn =
        "${checkInDate.day}/${checkInDate.month}/${checkInDate.year}";
    final formattedCheckOut =
        "${checkOutDate.day}/${checkOutDate.month}/${checkOutDate.year}";

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(booking['hotelName'] ?? 'Nombre no disponible'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Tipo de habitación: ${booking['roomType']}"),
              const SizedBox(height: 8),
              Text("Número de huéspedes: ${booking['numberOfGuests']}"),
              const SizedBox(height: 8),
              Text("Fecha de ingreso: $formattedCheckIn"),
              const SizedBox(height: 8),
              Text("Fecha de salida: $formattedCheckOut"),
              const SizedBox(height: 8),
              Text(
                  "Precio total: \$${booking['totalPrice']?.toStringAsFixed(2)}"),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cerrar"),
            ),
          ],
        );
      },
    );
  }
}
