import 'package:cloud_firestore/cloud_firestore.dart';

class Usuario {
  final String id; // UID del usuario en Firebase
  final String email;
  final String nivel;
  final String nombre;
  final DateTime fechaCreacion;

  Usuario({
    required this.id,
    required this.email,
    required this.nivel,
    required this.nombre,
    required this.fechaCreacion,
  });

  factory Usuario.fromJson(Map<String, dynamic> json, {required String id}) {
    final fechaCreacionRaw = json['fechaCreacion'];
    final fechaCreacion = fechaCreacionRaw is Timestamp
        ? fechaCreacionRaw.toDate() // Convierte Timestamp a DateTime
        : DateTime.parse(fechaCreacionRaw); // Maneja String como DateTime

    return Usuario(
      id: id,
      email: json['email'],
      nombre: json['nombre'],
      nivel: json['nivel'],
      fechaCreacion: fechaCreacion,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'nivel': nivel,
      'nombre': nombre,
      'fechaCreacion': fechaCreacion,
      'id': id, // Asegúrate de incluir el UID aquí
    };
  }
}
