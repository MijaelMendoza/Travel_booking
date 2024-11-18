import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MyAccountPage extends StatelessWidget {
  const MyAccountPage({Key? key}) : super(key: key);

  Future<Map<String, dynamic>?> _fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return null;

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (snapshot.exists) {
      return snapshot.data();
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        title: const Text(
          "Mi Cuenta",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _fetchUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(
              child: Text(
                "No se pudo cargar la información de la cuenta.",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                ),
              ),
            );
          }

          final userData = snapshot.data!;
          final userName = userData['name'] ?? 'Nombre no disponible';
          final email = userData['email'] ?? 'Correo no disponible';
          final phoneNumber = userData['phone'] ?? 'Teléfono no disponible';
          final joinDate = userData.containsKey('joinDate')
              ? (userData['joinDate'] as Timestamp).toDate()
              : null;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Información de la Cuenta",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: const Icon(Icons.person, color: Colors.blue),
                  title: const Text("Nombre"),
                  subtitle: Text(userName),
                ),
                ListTile(
                  leading: const Icon(Icons.email, color: Colors.blue),
                  title: const Text("Correo Electrónico"),
                  subtitle: Text(email),
                ),
                ListTile(
                  leading: const Icon(Icons.phone, color: Colors.blue),
                  title: const Text("Teléfono"),
                  subtitle: Text(phoneNumber),
                ),
                if (joinDate != null)
                  ListTile(
                    leading: const Icon(Icons.calendar_today, color: Colors.blue),
                    title: const Text("Fecha de Registro"),
                    subtitle: Text(
                        "${joinDate.day}/${joinDate.month}/${joinDate.year}"),
                  ),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text("Atrás"),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
