import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'dart:typed_data';
import 'package:carretera/core/models/car.dart';
import 'package:carretera/core/models/rental_car.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RentalCarService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final String imgbbApiKey =
      '2c68fb0d7ff2f04835d1da3cf672e0a3'; // Inserta tu clave de API aquí

  // URL predeterminada para imágenes
  final String defaultImageUrl =
      "https://via.placeholder.com/150"; // Imagen predeterminada

  // Función para leer la imagen y convertirla en Uint8List
  Future<Uint8List> _loadImageBytes(html.File file) async {
    final reader = html.FileReader();
    final completer = Completer<Uint8List>();

    reader.readAsArrayBuffer(file);
    reader.onLoadEnd.listen((event) {
      completer.complete(reader.result as Uint8List);
    });

    reader.onError.listen((event) {
      completer.completeError("Error al leer el archivo");
    });

    return completer.future;
  }

  // Función para subir múltiples imágenes a Imgbb y obtener sus URLs
  Future<List<String>> _uploadImagesToImgbb(List<html.File> files) async {
    List<String> imageUrls = [];
    for (var file in files) {
      final uri = Uri.parse('https://api.imgbb.com/1/upload?key=$imgbbApiKey');
      final request = http.MultipartRequest('POST', uri);

      final fileBytes = await _loadImageBytes(file);

      // Agregar la imagen a la solicitud
      request.files.add(http.MultipartFile.fromBytes(
        'image',
        fileBytes,
        filename: file.name,
      ));

      try {
        final response = await request.send();
        final responseBody = await response.stream.bytesToString();

        if (response.statusCode == 200) {
          final responseData = jsonDecode(responseBody);
          imageUrls.add(responseData['data']['url']);
        } else {
          print('Error al subir la imagen: ${response.reasonPhrase}');
        }
      } catch (e) {
        print('Error al subir la imagen a Imgbb: $e');
        continue;
      }
    }

    // Si no se pudieron subir imágenes, usar la imagen predeterminada
    if (imageUrls.isEmpty) {
      print("No se pudieron subir imágenes, usando imagen predeterminada.");
      imageUrls.add(defaultImageUrl);
    }

    return imageUrls;
  }

  // Función para registrar el auto con múltiples imágenes
  Future<void> registerCar({
    required String model,
    required String brand,
    required double price,
    required List<html.File> carImages,
    required String description,
    required bool isAvailable,
  }) async {
    try {
      // Intentar subir todas las imágenes
      List<String> imageUrls = await _uploadImagesToImgbb(carImages);

      // Obtener información del usuario autenticado
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('El usuario no está autenticado');
      }

      // Crear el objeto Car
      Car car = Car(
        model: model,
        brand: brand,
        price: price,
        imageUrls: imageUrls,
        description: description,
        isAvailable: isAvailable,
        userId: user.uid,
      );

      // Crear el documento del auto en Firestore
      final carRef = await _firestore.collection('cars').add(car.toMap());

      // Guardar el UID del documento en Firestore
      await carRef.update({
        'car_uid': carRef.id, // ID generado automáticamente por Firestore
      });

      print('Auto registrado exitosamente con ID: ${carRef.id}');
    } catch (e) {
      throw Exception('Error al registrar el auto: $e');
    }
  }

  // Función para registrar una renta
  Future<void> rentCar({
    required String carId,
    required DateTime startDate,
    required DateTime endDate,
    required double pricePerDay,
    required double totalAmount,
    required String paymentMethod,
  }) async {
    try {
      // Obtener información del usuario autenticado
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('El usuario no está autenticado');
      }

      // Crear el objeto Rental
      Rental rental = Rental(
        carId: carId,
        startDate: startDate,
        endDate: endDate,
        pricePerDay: pricePerDay,
        totalAmount: totalAmount,
        paymentMethod: paymentMethod,
        userId: user.uid,
      );

      // Registrar la renta en Firestore
      await _firestore.collection('rentals').add(rental.toMap());

      print('Renta registrada exitosamente');
    } catch (e) {
      throw Exception('Error al registrar la renta: $e');
    }
  }
}
