import 'package:carretera/core/models/hotel_booking.dart';
import 'package:carretera/core/services/hotel_service.dart';
import 'package:flutter/material.dart';

class MyHotel extends StatelessWidget {
  const MyHotel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalles del Hotel'),
        backgroundColor: Colors.blue,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildHotelCard(
            context,
            name: 'Hotel Paradise',
            imagePath: 'assets/images/location3.png',
            rating: '4.5/5',
          ),
          const SizedBox(height: 16),
          _buildHotelCard(
            context,
            name: 'Ocean Breeze',
            imagePath: 'assets/images/location1.png',
            rating: '4/5',
          ),
          const SizedBox(height: 16),
          _buildHotelCard(
            context,
            name: 'Mountain Escape',
            imagePath: 'assets/images/location2.png',
            rating: '5/5',
          ),
        ],
      ),
    );
  }

  Widget _buildHotelCard(
    BuildContext context, {
    required String name,
    required String imagePath,
    required String rating,
  }) {
    return GestureDetector(
      onTap: () {
        _showReservationPopup(context, name);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 5,
            ),
          ],
        ),
        child: Row(
          children: [
            // Imagen del hotel
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
              child: Image.asset(
                imagePath,
                width: 120,
                height: 120,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 10),
            // Información del hotel
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    rating,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Icon(
                Icons.arrow_forward_ios,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showReservationPopup(BuildContext context, String hotelName) {
    final HotelService hotelService = HotelService();

    showDialog(
      context: context,
      builder: (context) {
        int numberOfPeople = 1;
        String? selectedRoomType;
        DateTime? checkInDate;
        DateTime? checkOutDate;
        double pricePerNight = 0;
        int stayDays = 0;

        final Map<String, double> roomPrices = {
          'Habitación Individual': 50.0,
          'Habitación Doble': 80.0,
          'Suite Pareja': 120.0,
          'Habitación Familiar': 150.0,
          'Suite Grande': 200.0,
          'Habitación Grupal': 300.0,
          'Suite Ejecutiva': 500.0,
        };

        double calculateTotalPrice() {
          if (selectedRoomType != null && stayDays > 0) {
            return roomPrices[selectedRoomType]! * stayDays;
          }
          return 0.0;
        }

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Reservar en $hotelName'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Fecha de ingreso
                  TextButton(
                    onPressed: () async {
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                      );
                      if (pickedDate != null) {
                        setState(() {
                          checkInDate = pickedDate;
                          if (checkInDate != null && checkOutDate != null) {
                            stayDays =
                                checkOutDate!.difference(checkInDate!).inDays;
                          }
                        });
                      }
                    },
                    child: Text(
                      checkInDate == null
                          ? 'Seleccionar fecha de ingreso'
                          : 'Fecha de ingreso: ${checkInDate!.toLocal()}'
                              .split(' ')[0],
                    ),
                  ),
                  // Fecha de salida
                  TextButton(
                    onPressed: () async {
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: checkInDate ?? DateTime.now(),
                        firstDate: checkInDate ?? DateTime.now(),
                        lastDate: DateTime(2100),
                      );
                      if (pickedDate != null) {
                        setState(() {
                          checkOutDate = pickedDate;
                          if (checkInDate != null && checkOutDate != null) {
                            stayDays =
                                checkOutDate!.difference(checkInDate!).inDays;
                          }
                        });
                      }
                    },
                    child: Text(
                      checkOutDate == null
                          ? 'Seleccionar fecha de salida'
                          : 'Fecha de salida: ${checkOutDate!.toLocal()}'
                              .split(' ')[0],
                    ),
                  ),
                  // Cantidad de personas
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Número de personas:'),
                      DropdownButton<int>(
                        value: numberOfPeople,
                        items: List.generate(
                          10,
                          (index) => DropdownMenuItem(
                            value: index + 1,
                            child: Text('${index + 1}'),
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            numberOfPeople = value!;
                            selectedRoomType = null; // Resetear selección
                          });
                        },
                      ),
                    ],
                  ),
                  // Tipo de habitación
                  const SizedBox(height: 10),
                  Text(
                    'Tipo de habitación:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 10),
                  ..._getRoomOptions(numberOfPeople).map((roomType) {
                    return RadioListTile<String>(
                      title: Text(roomType),
                      value: roomType,
                      groupValue: selectedRoomType,
                      onChanged: (value) {
                        setState(() {
                          selectedRoomType = value;
                          pricePerNight = roomPrices[selectedRoomType!]!;
                        });
                      },
                    );
                  }),
                  const SizedBox(height: 10),
                  // Mostrar precio
                  Text(
                    'Precio total: \$${calculateTotalPrice().toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () async {
                    if (checkInDate != null &&
                        checkOutDate != null &&
                        selectedRoomType != null) {
                      final booking = HotelBooking(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        hotelName: hotelName,
                        checkInDate: checkInDate!,
                        checkOutDate: checkOutDate!,
                        numberOfPeople: numberOfPeople,
                        roomType: selectedRoomType!,
                        totalPrice: calculateTotalPrice(),
                        userId:
                            'user123', // Aquí debes usar el ID real del usuario autenticado
                      );

                      try {
                        await hotelService.createHotelBooking(booking);
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Reserva realizada con éxito')),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: $e')),
                        );
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content:
                                Text('Por favor completa todos los campos')),
                      );
                    }
                  },
                  child: const Text('Reservar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  List<String> _getRoomOptions(int numberOfPeople) {
    if (numberOfPeople == 1) {
      return ['Habitación Individual'];
    } else if (numberOfPeople == 2) {
      return ['Habitación Doble', 'Suite Pareja'];
    } else if (numberOfPeople <= 4) {
      return ['Habitación Familiar', 'Suite Grande'];
    } else {
      return ['Habitación Grupal', 'Suite Ejecutiva'];
    }
  }
}
