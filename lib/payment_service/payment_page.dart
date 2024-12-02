import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:carretera/components/bottom_navbar.dart';
import 'package:carretera/payment_service/payment_verification.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// Importa BankCard y Bank desde su archivo original
import 'bank_card.dart';

class Payment extends StatefulWidget {
  const Payment({Key? key}) : super(key: key);

  @override
  _PaymentState createState() => _PaymentState();
}

class _PaymentState extends State<Payment> {
  int selectedPaymentMethod = 1; // 0: None, 1: Credit Card, 2: Bank Transfer
  BankCard? selectedCard;
  Bank? selectedBank;

  // Variables para almacenar detalles del ticket y pago
  double ticketPrice = 250000;
  int ticketCount = 4;
  double tax = 20000;
  double totalAmount = 1020000;

  String selectedImage = ''; // Imagen seleccionada para tarjeta o banco

  bool isFrequentTraveler = false;

  @override
  void initState() {
    super.initState();
    _checkFrequentTravelerStatus();
  }

  Future<void> _checkFrequentTravelerStatus() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Verifica en Firestore si el usuario es viajero frecuente
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .get();
      setState(() {
        isFrequentTraveler = userDoc['viajeroFrecuente'] ?? false;
      });
    }
  }

  Future<void> registerPaymentAndTickets() async {
    if (selectedCard == null && selectedBank == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Seleccione un método de pago antes de continuar.'),
        ),
      );
      return;
    }

    String paymentMethod =
        selectedCard != null ? "Tarjeta de Crédito" : "Transferencia Bancaria";

    try {
      // Registrar el pago en Firebase
      CollectionReference payments =
          FirebaseFirestore.instance.collection('payments');
      DocumentReference paymentDoc = await payments.add({
        'method': paymentMethod,
        'totalAmount': totalAmount,
        'ticketPrice': ticketPrice,
        'ticketCount': ticketCount,
        'tax': tax,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Registrar los tickets asociados al pago
      CollectionReference tickets =
          FirebaseFirestore.instance.collection('tickets');
      for (int i = 1; i <= ticketCount; i++) {
        await tickets.add({
          'paymentId': paymentDoc.id,
          'ticketNumber': i,
          'ticketPrice': ticketPrice,
          'tax': tax,
          'timestamp': FieldValue.serverTimestamp(),
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Pago y tickets registrados exitosamente en la base de datos.'),
        ),
      );

      // Navega a la pantalla de verificación
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Verification(
            selectedCard: selectedCard,
            selectedBank: selectedBank,
          ),
        ),
      );
    } catch (e) {
      print("Error al registrar el pago y tickets: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al registrar el pago y tickets: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double displayWidth = MediaQuery.of(context).size.width;
    double discount = isFrequentTraveler
        ? 0.1
        : 0; // 10% de descuento si es viajero frecuente
    double discountedTotal = totalAmount - (totalAmount * discount);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        title: const Text(
          'Hacer un pago',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Stack(
        children: [
          ListView(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20.0, vertical: 30.0),
                child: Container(
                  width: displayWidth,
                  decoration: ShapeDecoration(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    shadows: const [
                      BoxShadow(
                        color: Color(0x19000000),
                        blurRadius: 10,
                        offset: Offset(0, 1),
                        spreadRadius: 0,
                      )
                    ],
                  ),
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/images/elysiumbooking.png',
                        width: displayWidth,
                        fit: BoxFit.cover,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20.0, vertical: 30.0),
                        child: SizedBox(
                          width: displayWidth,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Precios de Tickets',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 20,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 16),
                              FittedBox(
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: const [
                                            Text(
                                              'Para un ticket',
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 14,
                                                fontFamily: 'Inter',
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            SizedBox(height: 8),
                                            Text(
                                              'No de tickets',
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 14,
                                                fontFamily: 'Inter',
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            SizedBox(height: 8),
                                            Text(
                                              'Impuesto',
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 14,
                                                fontFamily: 'Inter',
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(width: 159),
                                        Column(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              '\$ ${ticketPrice.toStringAsFixed(2)}',
                                              style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 14,
                                                fontFamily: 'Inter',
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              '$ticketCount',
                                              style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 14,
                                                fontFamily: 'Inter',
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              '\$ ${tax.toStringAsFixed(2)}',
                                              style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 14,
                                                fontFamily: 'Inter',
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          'Total',
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 16,
                                            fontFamily: 'Inter',
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        Text(
                                          '\$ ${discountedTotal.toStringAsFixed(2)}',
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 16,
                                            fontFamily: 'Inter',
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (isFrequentTraveler)
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 8.0),
                                        child: Text(
                                          '¡Descuento aplicado! 10% de descuento por ser viajero frecuente.',
                                          style: TextStyle(
                                            color: Colors.green,
                                            fontSize: 16,
                                            fontFamily: 'Inter',
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                  ],
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
              Padding(
                padding:
                    const EdgeInsets.only(top: 20.0, left: 20.0, right: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(bottom: 16.0),
                      child: Text(
                        'Escoge un método de pago',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        _buildPaymentOption(1, 'Tarjeta de crédito'),
                        const SizedBox(width: 20),
                        _buildPaymentOption(2, 'Transferencia bancaria'),
                      ],
                    ),
                  ],
                ),
              ),
              if (selectedPaymentMethod == 1) _buildCreditCardSection(),
              if (selectedPaymentMethod == 2) _buildBankTransferSection(),
              const SizedBox(height: 150),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: 120,
              padding: EdgeInsets.all(displayWidth * .05),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color.fromARGB(239, 0, 32, 50),
                    Color.fromARGB(230, 150, 168, 255),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const NavBar()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      minimumSize: Size(displayWidth * .44, displayWidth * .16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50.0),
                        side: const BorderSide(
                            color: Color.fromARGB(255, 0, 73, 255)),
                      ),
                    ),
                    child: const Text(
                      'Cancelar',
                      style: TextStyle(
                        color: Color.fromARGB(255, 0, 73, 255),
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: registerPaymentAndTickets,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color.fromARGB(255, 0, 73, 255),
                            Color.fromARGB(255, 162, 221, 255),
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(50.0),
                      ),
                      width: displayWidth * 0.44,
                      height: displayWidth * 0.16,
                      child: const Center(
                        child: Text(
                          'Pago',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
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
          onChanged: (int? newValue) {
            setState(() {
              selectedPaymentMethod = newValue!;
              selectedCard = null;
              selectedBank = null;
            });
          },
        ),
        Text(
          label,
          style: TextStyle(
            color: selectedPaymentMethod == value ? Colors.blue : Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildCreditCardSection() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _SelectableImage(
            imagePath: "assets/images/card1.png",
            isSelected: selectedImage == "assets/images/card1.png",
            onTap: () {
              setState(() {
                selectedImage = "assets/images/card1.png";
                selectedCard = BankCard("assets/images/card1.png");
              });
            },
          ),
          _SelectableImage(
            imagePath: "assets/images/card2.png",
            isSelected: selectedImage == "assets/images/card2.png",
            onTap: () {
              setState(() {
                selectedImage = "assets/images/card2.png";
                selectedCard = BankCard("assets/images/card2.png");
              });
            },
          ),
          _SelectableImage(
            imagePath: "assets/images/card3.png",
            isSelected: selectedImage == "assets/images/card3.png",
            onTap: () {
              setState(() {
                selectedImage = "assets/images/card3.png";
                selectedCard = BankCard("assets/images/card3.png");
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBankTransferSection() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _SelectableImage(
            imagePath: "assets/images/Bank1.png",
            isSelected: selectedImage == "assets/images/Bank1.png",
            onTap: () {
              setState(() {
                selectedImage = "assets/images/Bank1.png";
                selectedBank = Bank("assets/images/Bank1.png");
              });
            },
          ),
          _SelectableImage(
            imagePath: "assets/images/Bank2.png",
            isSelected: selectedImage == "assets/images/Bank2.png",
            onTap: () {
              setState(() {
                selectedImage = "assets/images/Bank2.png";
                selectedBank = Bank("assets/images/Bank2.png");
              });
            },
          ),
        ],
      ),
    );
  }
}

class _SelectableImage extends StatelessWidget {
  final String imagePath;
  final bool isSelected;
  final VoidCallback onTap;

  const _SelectableImage({
    required this.imagePath,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(8.0),
        width: 100,
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.transparent,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Image.asset(
          imagePath,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
