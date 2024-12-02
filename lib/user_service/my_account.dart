import 'package:flutter/material.dart';

import 'my_hotel_b.dart';

class MyAccountPage extends StatelessWidget {
  const MyAccountPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 200,
            color: Colors.blue,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DrawerHeader(
                  decoration: BoxDecoration(
                    color: Colors.blue.shade700,
                  ),
                  child: Center(
                    child: Text(
                      "Menú",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.person, color: Colors.white),
                  title: Text(
                    "Información de la cuenta",
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    // Acción para Información de la cuenta (puedes agregar funcionalidad más tarde)
                  },
                ),
                ListTile(
                  leading: Icon(Icons.hotel, color: Colors.white),
                  title: Text(
                    "Reservas de hoteles",
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    // Navegar a reservas de hoteles
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MyHotelBPage(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          // Main content
          Expanded(
            child: Center(
              child: Text(
                "Selecciona una opción en el menú lateral.",
                style: TextStyle(fontSize: 18, color: Colors.black54),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
