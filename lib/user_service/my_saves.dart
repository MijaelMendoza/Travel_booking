import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MySavesPage extends StatelessWidget {
  const MySavesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        title: const Text(
          'Mis Tickets',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('tickets').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "No tienes tickets guardados aún.",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                ),
              ),
            );
          }

          final tickets = snapshot.data!.docs;

          return ListView.builder(
            itemCount: tickets.length,
            itemBuilder: (context, index) {
              final ticket = tickets[index].data() as Map<String, dynamic>;

              final destination = ticket.containsKey('destination')
                  ? ticket['destination']
                  : "Destino desconocido";
              final seatNumber = ticket.containsKey('seatNumber')
                  ? ticket['seatNumber']
                  : "No asignado";
              final purchaseDate = ticket.containsKey('purchaseDate')
                  ? (ticket['purchaseDate'] as Timestamp).toDate()
                  : null;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(
                    'Ticket #${index + 1}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Destino: $destination'),
                      Text('Número de Asiento: $seatNumber'),
                      if (purchaseDate != null)
                        Text(
                          'Fecha de Compra: $purchaseDate',
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
