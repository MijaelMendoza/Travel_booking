import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:carousel_slider/carousel_slider.dart';

class CarDetailScreen extends StatefulWidget {
  final String carId;
  CarDetailScreen({required this.carId});

  @override
  _CarDetailScreenState createState() => _CarDetailScreenState();
}

class _CarDetailScreenState extends State<CarDetailScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late TextEditingController _priceController;
  late TextEditingController _descriptionController;
  List<String> imageUrls = [];

  @override
  void initState() {
    super.initState();
    _priceController = TextEditingController();
    _descriptionController = TextEditingController();
    _getCarDetails();
  }

  Future<void> _getCarDetails() async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('cars').doc(widget.carId).get();
      var carData = doc.data() as Map<String, dynamic>;

      if (carData.containsKey('image_urls') && carData['image_urls'] is List) {
        imageUrls = List<String>.from(carData['image_urls']);
      }

      _priceController.text = carData['price'].toString();
      _descriptionController.text = carData['description'];
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error al cargar datos: $e')));
    }
  }

  Future<void> _updateCarDetails() async {
    try {
      await _firestore.collection('cars').doc(widget.carId).update({
        'price': double.parse(_priceController.text),
        'description': _descriptionController.text,
      });
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Detalles actualizados exitosamente')));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error al actualizar: $e')));
    }
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
            // Campo de texto para el precio
            TextFormField(
              controller: _priceController,
              decoration: InputDecoration(
                labelText: 'Precio',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.monetization_on),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),

            // Campo de texto para la descripción
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Descripción',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 4,
            ),
            SizedBox(height: 20),

            // Carrusel de imágenes
            imageUrls.isNotEmpty
                ? CarouselSlider(
                    items: imageUrls
                        .map((url) => ClipRRect(
                              borderRadius: BorderRadius.circular(10.0),
                              child: Image.network(
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
                  )
                : Center(
                    child: Text(
                      'No hay imágenes disponibles',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ),
            SizedBox(height: 20),

            // Botón para actualizar los detalles del coche
            Center(
              child: ElevatedButton.icon(
                onPressed: _updateCarDetails,
                icon: Icon(Icons.save),
                label: Text('Actualizar'),
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
