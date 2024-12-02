import 'package:carretera/carRental_service/car_details.dart';
import 'package:carretera/carRental_service/car_details_client.dart';
import 'package:carretera/carRental_service/register_car.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Importar para manejar la autenticación
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CarListScreenClient extends StatefulWidget {
  @override
  _CarListScreenClientState createState() => _CarListScreenClientState();
}

class _CarListScreenClientState extends State<CarListScreenClient> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<Map<String, dynamic>> cars = [];
  List<Map<String, dynamic>> filteredCars = [];
  TextEditingController searchController = TextEditingController();
  bool isAdmin = false;

  @override
  void initState() {
    super.initState();
    _checkAdminStatus(); // Verificar si el usuario es admin
    _fetchCars();
    searchController.addListener(_filterCars);
  }

  // Verificar si el usuario es admin
  Future<void> _checkAdminStatus() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await _firestore.collection('usuarios').doc(user.uid).get();
      var userData = userDoc.data() as Map<String, dynamic>;
      if (userData['nivel'] == 'admin') {
        setState(() {
          isAdmin = true;
        });
      }
    }
  }

  // Obtener todos los autos desde Firestore
  Future<void> _fetchCars() async {
    QuerySnapshot snapshot = await _firestore.collection('cars').get();
    cars = snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    filteredCars = cars;
    setState(() {});
  }

  // Filtrar los autos basado en el modelo
  void _filterCars() {
    String query = searchController.text.toLowerCase();
    setState(() {
      filteredCars = cars
          .where((car) =>
              (car['model'] ?? '').toString().toLowerCase().contains(query))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Autos para Rentar'),
        backgroundColor: Colors.blueGrey,
      ),
      body: Column(
        children: [
          // Campo de búsqueda
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Buscar por modelo',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          // Botón para agregar auto si el usuario es admin
          if (isAdmin)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RentalCarForm(), // Pantalla para agregar auto
                    ),
                  );
                },
                icon: Icon(Icons.add),
                label: Text('Agregar Auto'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ),
          Expanded(
            child: cars.isEmpty
                ? Center(child: CircularProgressIndicator())
                : filteredCars.isEmpty
                    ? Center(
                        child: Text(
                          'No se encontraron autos',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        itemCount: filteredCars.length,
                        itemBuilder: (context, index) {
                          var car = filteredCars[index];
                          List<dynamic> imageUrls = car['image_urls'] ?? [];
                          String? imageUrl = imageUrls.isNotEmpty ? imageUrls[0] : null;

                          return Card(
                            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              contentPadding: EdgeInsets.all(16),
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(50),
                                child: imageUrl != null
                                    ? Image.network(
                                        imageUrl,
                                        width: 50,
                                        height: 50,
                                        fit: BoxFit.cover,
                                      )
                                    : Icon(Icons.car_rental, size: 50, color: Colors.grey),
                              ),
                              title: Text(
                                car['model'] ?? 'Sin Modelo',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              subtitle: Text(
                                '${car['brand'] ?? 'Sin Marca'} - \$${car['price'] ?? '0'}',
                                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                              ),
                              onTap: () {
                                // Si es admin, ir a la pantalla de editar auto, si no es admin, solo detalles
                                if (isAdmin) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => CarDetailScreen(carId: car['car_uid']),
                                    ),
                                  );
                                } else {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => CarDetailScreenClient(carId: car['car_uid']),
                                    ),
                                  );
                                }
                              },
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
