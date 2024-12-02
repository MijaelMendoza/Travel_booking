import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

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
                  trailing: IconButton(
                    icon: const Icon(Icons.share),
                    onPressed: () {
                      // Generar el texto para compartir
                      final shareContent = '''
Reserva #${index + 1}
Método de Pago: $method
Total: \$${totalAmount.toStringAsFixed(2)}
Número de Tickets: $ticketCount
${timestamp != null ? 'Fecha: ${timestamp.toDate()}' : ''}
''';

                      // Mostrar opciones para compartir en Facebook o Instagram
                      showModalBottomSheet(
                        context: context,
                        builder: (BuildContext context) {
                          return Wrap(
                            children: [
                              ListTile(
                                leading: const Icon(Icons.facebook),
                                title: const Text('Compartir en Facebook'),
                                onTap: () async {
                                  final shareUrl = 'https://carretera.com/my_bookings/ViFluuAisFgMShHlZ8pf8622GoH3';
                                  final facebookUrl =
                                      'https://www.facebook.com/sharer/sharer.php?u=$shareUrl';

                                  if (await canLaunch(facebookUrl)) {
                                    await launch(facebookUrl);
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            'No se pudo abrir Facebook para compartir.'),
                                      ),
                                    );
                                  }
                                  Navigator.of(context).pop();
                                },
                              ),
                              ListTile(
                                leading: const Icon(Icons.camera_alt),
                                title: const Text('Compartir en Instagram'),
                                onTap: () async {
                                  final url = Uri.encodeFull(
                                      'https://www.instagram.com/?text=$shareContent');
                                  if (await canLaunch(url)) {
                                    await launch(url);
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            'No se pudo abrir Instagram para compartir.'),
                                      ),
                                    );
                                  }
                                  Navigator.of(context).pop();
                                },
                              ),
                              if (kIsWeb) // Si está en el navegador, dar opción de copiar al portapapeles
                                ListTile(
                                  leading: const Icon(Icons.copy),
                                  title: const Text('Copiar al portapapeles'),
                                  onTap: () {
                                    Clipboard.setData(
                                            ClipboardData(text: shareContent))
                                        .then((_) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(const SnackBar(
                                        content: Text('Copiado al portapapeles'),
                                      ));
                                    });
                                    Navigator.of(context).pop();
                                  },
                                ),
                            ],
                          );
                        },
                      );
                    },
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
