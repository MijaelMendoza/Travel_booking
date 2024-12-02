import 'package:carretera/core/services/rental_car_service.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RentCarScreen extends StatefulWidget {
  final String carId;
  final double pricePerDay;

  const RentCarScreen({required this.carId, required this.pricePerDay, Key? key})
      : super(key: key);

  @override
  _RentCarScreenState createState() => _RentCarScreenState();
}

class _RentCarScreenState extends State<RentCarScreen> {
  int selectedPaymentMethod = 1; // 1: Credit Card, 2: Bank Transfer
  DateTime? startDate;
  DateTime? endDate;
  double totalAmount = 0.0;
  final RentalCarService _rentalCarService = RentalCarService(); // Instanciamos el servicio

  // Método para seleccionar fecha de inicio y fin
  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          startDate = picked;
          if (endDate != null && startDate!.isAfter(endDate!)) {
            endDate = null; // Reset end date if invalid
          }
        } else {
          endDate = picked;
        }
        _calculateTotal();
      });
    }
  }

  // Calcular el total a pagar basado en las fechas seleccionadas
  void _calculateTotal() {
    if (startDate != null && endDate != null) {
      int days = endDate!.difference(startDate!).inDays + 1; // Include end day
      totalAmount = days * widget.pricePerDay;
    } else {
      totalAmount = 0.0;
    }
  }

  // Confirmar la renta del auto
  Future<void> confirmRent() async {
    if (startDate == null || endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona las fechas de inicio y fin.')),
      );
      return;
    }

    String paymentMethod = selectedPaymentMethod == 1
        ? "Tarjeta de Crédito"
        : "Transferencia Bancaria";

    try {
      await _rentalCarService.rentCar(
        carId: widget.carId,
        startDate: startDate!,
        endDate: endDate!,
        pricePerDay: widget.pricePerDay,
        totalAmount: totalAmount,
        paymentMethod: paymentMethod,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Renta confirmada exitosamente.')),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al confirmar la renta: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Confirmar Renta',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20.0),
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x19000000),
                        blurRadius: 10,
                        offset: Offset(0, 1),
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Precio por día: \$${widget.pricePerDay.toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Fecha de inicio:',
                          style: const TextStyle(fontSize: 16),
                        ),
                        ListTile(
                          title: Text(
                            startDate != null
                                ? '${startDate!.day}/${startDate!.month}/${startDate!.year}'
                                : 'Seleccionar fecha de inicio',
                          ),
                          trailing: const Icon(Icons.calendar_today),
                          onTap: () => _selectDate(context, true),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Fecha de fin:',
                          style: const TextStyle(fontSize: 16),
                        ),
                        ListTile(
                          title: Text(
                            endDate != null
                                ? '${endDate!.day}/${endDate!.month}/${endDate!.year}'
                                : 'Seleccionar fecha de fin',
                          ),
                          trailing: const Icon(Icons.calendar_today),
                          onTap: () => _selectDate(context, false),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Total: \$${totalAmount.toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Método de pago',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _buildPaymentOption(1, 'Tarjeta de Crédito'),
                    const SizedBox(width: 20),
                    _buildPaymentOption(2, 'Transferencia Bancaria'),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF002032),
                  Color(0xFF96A8FF),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    child: const Text(
                      'Cancelar',
                      style: TextStyle(color: Colors.blue, fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: confirmRent,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    child: const Text(
                      'Confirmar',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption(int value, String label) {
    return Row(
      children: [
        Radio<int>(
          value: value,
          groupValue: selectedPaymentMethod,
          onChanged: (newValue) {
            setState(() {
              selectedPaymentMethod = newValue!;
            });
          },
        ),
        Text(label),
      ],
    );
  }
}
