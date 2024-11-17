import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/payment.dart';

class PaymentService {
  final CollectionReference _payments =
      FirebaseFirestore.instance.collection('payments');

  Future<void> createPayment(Payment payment) async {
    await _payments.doc(payment.id).set(payment.toMap());
  }

  Future<List<Payment>> getPaymentsByUser(String userId) async {
    final snapshot = await _payments.where('usuarioId', isEqualTo: userId).get();
    return snapshot.docs
        .map((doc) => Payment.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }
}
