import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MyBookingsPage extends StatelessWidget {
  const MyBookingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        title: const Text(
          'Mis Reservas',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('payments').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "No tienes reservas aún.",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                ),
              ),
            );
          }

          // Filtrar reservas con fechas futuras o actuales
          final today = DateTime.now();
          final bookings = snapshot.data!.docs.where((doc) {
            final timestamp = doc['timestamp'] as Timestamp?;
            if (timestamp == null) return false;

            // Convertir a DateTime y comparar solo las fechas
            final bookingDate = timestamp.toDate();
            final bookingDateOnly = DateTime(
              bookingDate.year,
              bookingDate.month,
              bookingDate.day,
            );

            final todayDateOnly = DateTime(
              today.year,
              today.month,
              today.day,
            );

            return bookingDateOnly.isAtSameMomentAs(todayDateOnly) || bookingDateOnly.isAfter(todayDateOnly);
          }).toList();

          if (bookings.isEmpty) {
            return const Center(
              child: Text(
                "No tienes reservas futuras o actuales.",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                ),
              ),
            );
          }

          return ListView.builder(
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final booking = bookings[index];
              final method = booking['method'] ?? "Desconocido";
              final totalAmount = booking['totalAmount'] ?? 0.0;
              final ticketCount = booking['ticketCount'] ?? 0;
              final timestamp = booking['timestamp'] as Timestamp?;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(
                    'Reserva #${index + 1}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Método de Pago: $method'),
                      Text('Total: \$${totalAmount.toStringAsFixed(2)}'),
                      Text('Número de Tickets: $ticketCount'),
                      if (timestamp != null)
                        Text(
                          'Fecha: ${timestamp.toDate()}',
                        ),
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
