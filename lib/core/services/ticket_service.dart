import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/ticket.dart';

class TicketService {
  final CollectionReference _tickets =
      FirebaseFirestore.instance.collection('tickets');

  Future<void> createTicket(Ticket ticket) async {
    await _tickets.doc(ticket.id).set(ticket.toMap());
  }

  Future<List<Ticket>> getTicketsByBooking(String bookingId) async {
    final snapshot = await _tickets.where('reservaId', isEqualTo: bookingId).get();
    return snapshot.docs
        .map((doc) => Ticket.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }
}
