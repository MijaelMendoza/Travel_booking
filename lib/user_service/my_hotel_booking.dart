import 'package:carretera/core/models/hotel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MyHotelBookingPage extends StatefulWidget {
  final Hotel hotel;

  const MyHotelBookingPage({Key? key, required this.hotel}) : super(key: key);

  @override
  _MyHotelBookingPageState createState() => _MyHotelBookingPageState();
}

class _MyHotelBookingPageState extends State<MyHotelBookingPage> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _checkInDate;
  DateTime? _checkOutDate;
  String? _selectedRoomType;
  int _numberOfGuests = 1;

  int get _stayDays {
    if (_checkInDate != null && _checkOutDate != null) {
      return _checkOutDate!.difference(_checkInDate!).inDays;
    }
    return 0;
  }

  double _calculateTotalPrice() {
    if (_selectedRoomType != null && _stayDays > 0) {
      final roomIndex = widget.hotel.roomTypes.indexOf(_selectedRoomType!);
      final roomPricePerNight =
          roomIndex >= 0 ? widget.hotel.pricePerNight + roomIndex * 20.0 : 0.0;
      return roomPricePerNight * _stayDays;
    }
    return 0.0;
  }

  Future<void> _saveBooking() async {
    if (_formKey.currentState!.validate()) {
      if (_checkInDate == null ||
          _checkOutDate == null ||
          _selectedRoomType == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Por favor completa todos los campos.')),
        );
        return;
      }

      try {
        // Obtener el userId del usuario autenticado
        final userId = FirebaseAuth.instance.currentUser?.uid;
        if (userId == null) {
          throw Exception('Usuario no autenticado.');
        }

        final booking = {
          'hotelId': widget.hotel.id,
          'hotelName': widget.hotel.name,
          'checkInDate': _checkInDate!.toIso8601String(),
          'checkOutDate': _checkOutDate!.toIso8601String(),
          'numberOfGuests': _numberOfGuests,
          'roomType': _selectedRoomType!,
          'totalPrice': _calculateTotalPrice(),
          'createdAt': Timestamp.now(),
          'userId': userId,
        };

        await FirebaseFirestore.instance
            .collection('hotel_bookings')
            .add(booking);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Reserva realizada con éxito.')),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar la reserva: $e')),
        );
      }
    }
  }

  Future<void> _selectDate(BuildContext context, bool isCheckIn) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      setState(() {
        if (isCheckIn) {
          _checkInDate = pickedDate;
          if (_checkOutDate != null && _checkOutDate!.isBefore(_checkInDate!)) {
            _checkOutDate = null; // Reset check-out if it's invalid
          }
        } else {
          _checkOutDate = pickedDate;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Reservar Hotel"),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.hotel.name,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text("Ubicación: ${widget.hotel.city}, ${widget.hotel.country}"),
              SizedBox(height: 8),
              Text(
                  "Precio base por noche: \$${widget.hotel.pricePerNight.toStringAsFixed(2)}"),
              SizedBox(height: 16),
              // Selección de fecha de entrada
              TextButton(
                onPressed: () => _selectDate(context, true),
                child: Text(
                  _checkInDate == null
                      ? 'Seleccionar fecha de entrada'
                      : 'Fecha de entrada: ${_checkInDate!.toLocal()}'
                          .split(' ')[0],
                ),
              ),
              // Selección de fecha de salida
              TextButton(
                onPressed: () => _selectDate(context, false),
                child: Text(
                  _checkOutDate == null
                      ? 'Seleccionar fecha de salida'
                      : 'Fecha de salida: ${_checkOutDate!.toLocal()}'
                          .split(' ')[0],
                ),
              ),
              SizedBox(height: 16),
              // Número de huéspedes
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Número de huéspedes:'),
                  DropdownButton<int>(
                    value: _numberOfGuests,
                    items: List.generate(
                      10,
                      (index) => DropdownMenuItem(
                        value: index + 1,
                        child: Text('${index + 1}'),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _numberOfGuests = value!;
                      });
                    },
                  ),
                ],
              ),
              SizedBox(height: 16),
              // Tipo de habitación
              DropdownButtonFormField<String>(
                value: _selectedRoomType,
                decoration: InputDecoration(labelText: 'Tipo de habitación'),
                items: widget.hotel.roomTypes.map((roomType) {
                  return DropdownMenuItem(
                    value: roomType,
                    child: Text(roomType),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedRoomType = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Por favor selecciona un tipo de habitación.';
                  }
                  return null;
                },
              ),
              SizedBox(height: 24),
              // Mostrar precio total dinámico
              Text(
                'Precio total: \$${_calculateTotalPrice().toStringAsFixed(2)}',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green),
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveBooking,
                child: Text("Reservar"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
