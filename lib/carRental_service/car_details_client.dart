import 'package:carousel_slider/carousel_options.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:carretera/carRental_service/rent_car_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:carretera/carRental_service/car_details.dart';

// CarDetailScreenClient
class CarDetailScreenClient extends StatefulWidget {
  final String carId;
  CarDetailScreenClient({required this.carId});

  @override
  _CarDetailScreenClientState createState() => _CarDetailScreenClientState();
}

class _CarDetailScreenClientState extends State<CarDetailScreenClient> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String price = '';
  String description = '';
  List<String> imageUrls = [];
  final String defaultImageUrl = 'assets/icons/auto.jpg'; // Imagen predeterminada

  @override
  void initState() {
    super.initState();
    _getCarDetails();
  }

  Future<void> _getCarDetails() async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('cars').doc(widget.carId).get();
      var carData = doc.data() as Map<String, dynamic>;

      if (carData.containsKey('image_urls') && carData['image_urls'] is List) {
        imageUrls = List<String>.from(carData['image_urls']) ;
      }

      price = carData['price'].toString();
      description = carData['description'];
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error al cargar datos: $e')));
    }
  }

  void _goToRentScreen() {
    if (price.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cargando detalles del auto...')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RentCarScreen(
          carId: widget.carId,
          pricePerDay: double.parse(price),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalles del Auto'),
        backgroundColor: Colors.blueGrey,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Carrusel de imágenes
            CarouselSlider(
              items: (imageUrls.isNotEmpty ? imageUrls : [defaultImageUrl])
                  .map((url) => ClipRRect(
                        borderRadius: BorderRadius.circular(10.0),
                        child: url.startsWith('http')
                            ? Image.network(
                                url,
                                width: MediaQuery.of(context).size.width,
                                height: 200,
                                fit: BoxFit.cover,
                              )
                            : Image.asset(
                                url,
                                width: MediaQuery.of(context).size.width,
                                height: 200,
                                fit: BoxFit.cover,
                              ),
                      ))
                  .toList(),
              options: CarouselOptions(
                height: 200,
                enlargeCenterPage: true,
                autoPlay: true,
                autoPlayInterval: Duration(seconds: 3),
                aspectRatio: 16 / 9,
                viewportFraction: 0.9,
              ),
            ),
            SizedBox(height: 20),

            // Detalles del auto
            Text(
              'Precio por día:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              '\$${price.isNotEmpty ? price : 'Cargando...'}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),

            Text(
              'Descripción:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              description.isNotEmpty ? description : 'Cargando...',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),

            // Botón para ir a la pantalla de renta
            Center(
              child: ElevatedButton.icon(
                onPressed: _goToRentScreen,
                icon: Icon(Icons.car_rental),
                label: Text('Rentar Auto'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
