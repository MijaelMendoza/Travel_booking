import 'package:cloud_firestore/cloud_firestore.dart';

class Usuario {
  final String id; // UID del usuario en Firebase
  final String email;
  final String nivel;
  final String nombre;
  final DateTime fechaCreacion;
  final bool viajeroFrecuente; // Nuevo campo agregado

  Usuario({
    required this.id,
    required this.email,
    required this.nivel,
    required this.nombre,
    required this.fechaCreacion,
    required this.viajeroFrecuente, // Nuevo parámetro en el constructor
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
      viajeroFrecuente: json['viajeroFrecuente'] ?? false, // Valor por defecto a false
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'nivel': nivel,
      'nombre': nombre,
      'fechaCreacion': fechaCreacion,
      'id': id, // Asegúrate de incluir el UID aquí
      'viajeroFrecuente': viajeroFrecuente, // Agrega este campo al JSON
    };
  }
}
