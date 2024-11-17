class Ticket {
  final String id;
  final String reservaId;
  final String usuarioId;
  final String codigoTicket;
  final String informacionAdicional;

  Ticket({
    required this.id,
    required this.reservaId,
    required this.usuarioId,
    required this.codigoTicket,
    this.informacionAdicional = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'reservaId': reservaId,
      'usuarioId': usuarioId,
      'codigoTicket': codigoTicket,
      'informacionAdicional': informacionAdicional,
    };
  }

  static Ticket fromMap(Map<String, dynamic> map) {
    return Ticket(
      id: map['id'],
      reservaId: map['reservaId'],
      usuarioId: map['usuarioId'],
      codigoTicket: map['codigoTicket'],
      informacionAdicional: map['informacionAdicional'],
    );
  }
}
