import 'package:carretera/core/models/hotel.dart';
import 'package:carretera/core/services/hotel_service.dart';
import 'package:carretera/user_service/new_hotel.dart';
import 'package:flutter/material.dart';

import 'my_hotel_booking.dart';

class MyHotelsPage extends StatefulWidget {
  @override
  _MyHotelsPageState createState() => _MyHotelsPageState();
}

class _MyHotelsPageState extends State<MyHotelsPage> {
  final HotelService _hotelService = HotelService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Hoteles Registrados"),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HotelFormPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Hotel>>(
        future: _hotelService.getAllHotels(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error al cargar los hoteles: ${snapshot.error}",
                textAlign: TextAlign.center,
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text("No hay hoteles registrados."),
            );
          } else {
            final hotels = snapshot.data!;
            return ListView.builder(
              itemCount: hotels.length,
              itemBuilder: (context, index) {
                final hotel = hotels[index];
                return Padding(
                  padding:
                      EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: InkWell(
                      onTap: () {
                        _showHotelDetails(context, hotel);
                      },
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: hotel.imageUrl.isNotEmpty
                                ? Image.network(
                                    hotel.imageUrl,
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                  )
                                : Container(
                                    width: 80,
                                    height: 80,
                                    color: Colors.grey[300],
                                    child: Icon(
                                      Icons.hotel,
                                      size: 40,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    hotel.name,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    "${hotel.city}, ${hotel.country}",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Text(
                                        "\$${hotel.pricePerNight.toStringAsFixed(2)}",
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green[700],
                                        ),
                                      ),
                                      Spacer(),
                                      Row(
                                        children: List.generate(5, (starIndex) {
                                          return Icon(
                                            starIndex < hotel.rating
                                                ? Icons.star
                                                : Icons.star_border,
                                            color: Colors.amber,
                                            size: 16,
                                          );
                                        }),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    "Habitaciones: ${hotel.roomTypes.join(', ')}",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }

  void _showHotelDetails(BuildContext context, Hotel hotel) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            hotel.name,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Ubicación:",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text("${hotel.city}, ${hotel.country}"),
                SizedBox(height: 8),
                Text(
                  "Dirección:",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(hotel.address),
                SizedBox(height: 8),
                Text(
                  "Precio por noche:",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text("\$${hotel.pricePerNight.toStringAsFixed(2)}"),
                SizedBox(height: 8),
                Text(
                  "Calificación:",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text("${hotel.rating} estrellas"),
                SizedBox(height: 8),
                Text(
                  "Descripción:",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(hotel.description),
                SizedBox(height: 8),
                Text(
                  "Amenidades:",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(hotel.amenities.join(", ")),
                SizedBox(height: 8),
                Text(
                  "Tipos de Habitación:",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(hotel.roomTypes.join(", ")),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Cerrar"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MyHotelBookingPage(hotel: hotel),
                  ),
                );
              },
              child: Text("Reservar"),
            ),
          ],
        );
      },
    );
  }
}
