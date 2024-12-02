import 'package:cloud_firestore/cloud_firestore.dart';

class Rental {
  String carId;
  DateTime startDate;
  DateTime endDate;
  double pricePerDay;
  double totalAmount;
  String paymentMethod;
  String userId;

  Rental({
    required this.carId,
    required this.startDate,
    required this.endDate,
    required this.pricePerDay,
    required this.totalAmount,
    required this.paymentMethod,
    required this.userId,
  });

  Map<String, dynamic> toMap() {
    return {
      'carId': carId,
      'startDate': startDate,
      'endDate': endDate,
      'pricePerDay': pricePerDay,
      'totalAmount': totalAmount,
      'paymentMethod': paymentMethod,
      'userId': userId,
      'timestamp': FieldValue.serverTimestamp(),
    };
  }
}