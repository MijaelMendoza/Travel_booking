import 'package:cloud_firestore/cloud_firestore.dart';

class Booking {
  final String id;
  final String usuarioId;
  final String tourId;
  final DateTime fechaInicio;
  final DateTime fechaFin;
  final int pasajeros;
  final double precioTotal;
  final String estado;

  Booking({
    required this.id,
    required this.usuarioId,
    required this.tourId,
    required this.fechaInicio,
    required this.fechaFin,
    required this.pasajeros,
    required this.precioTotal,
    this.estado = 'pendiente',
  });
factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] as String,
      usuarioId: json['usuarioId'] as String,
      tourId: json['tourId'] as String,
      fechaInicio: (json['fechaInicio'] as Timestamp).toDate(),
      fechaFin: (json['fechaFin'] as Timestamp).toDate(),
      pasajeros: json['pasajeros'] as int,
      precioTotal: (json['precioTotal'] as num).toDouble(),
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'usuarioId': usuarioId,
      'tourId': tourId,
      'fechaInicio': fechaInicio.toIso8601String(),
      'fechaFin': fechaFin.toIso8601String(),
      'pasajeros': pasajeros,
      'precioTotal': precioTotal,
      'estado': estado,
    };
  }

  static Booking fromMap(Map<String, dynamic> map) {
    return Booking(
      id: map['id'],
      usuarioId: map['usuarioId'],
      tourId: map['tourId'],
      fechaInicio: DateTime.parse(map['fechaInicio']),
      fechaFin: DateTime.parse(map['fechaFin']),
      pasajeros: map['pasajeros'],
      precioTotal: map['precioTotal'],
      estado: map['estado'],
    );
  }
}
