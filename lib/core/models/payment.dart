class Payment {
  final String id;
  final String reservaId;
  final String usuarioId;
  final String metodoPago;
  final double monto;
  final DateTime fechaPago;

  Payment({
    required this.id,
    required this.reservaId,
    required this.usuarioId,
    required this.metodoPago,
    required this.monto,
    required this.fechaPago,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'reservaId': reservaId,
      'usuarioId': usuarioId,
      'metodoPago': metodoPago,
      'monto': monto,
      'fechaPago': fechaPago.toIso8601String(),
    };
  }

  static Payment fromMap(Map<String, dynamic> map) {
    return Payment(
      id: map['id'],
      reservaId: map['reservaId'],
      usuarioId: map['usuarioId'],
      metodoPago: map['metodoPago'],
      monto: map['monto'],
      fechaPago: DateTime.parse(map['fechaPago']),
    );
  }
}
