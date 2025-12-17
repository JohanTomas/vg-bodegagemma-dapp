import 'package:myapp/models/client_model.dart';
import 'package:myapp/models/paymentMethod_model.dart';
import 'package:myapp/models/reservation_detail_model.dart';
import 'package:myapp/models/seller_model.dart';

class Reservation {
  int? id;
  Client client;
  Seller seller;
  PaymentMethod paymentMethod;
  String reservationDate;
  String active;
  List<ReservationDetail> reservationDetails;
  String? clientNames;
  String? sellerNames;
  String? formattedReservationDate;
  double? totalReservation;

  Reservation({
    this.id,
    required this.client,
    required this.seller,
    required this.paymentMethod,
    required this.reservationDate,
    this.active = 'A',
    required this.reservationDetails,
    this.clientNames,
    this.sellerNames,
    this.formattedReservationDate,
    this.totalReservation,
  });

  factory Reservation.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      throw Exception('Failed to parse JSON');
    }

    return Reservation(
      id: json['id'],
      client: Client.fromJson(json['client'] ?? {}),
      seller: Seller.fromJson(json['seller'] ?? {}),
      paymentMethod: PaymentMethod.fromJson(json['paymentMethod'] ?? {}),
      reservationDate: json['reservationDate'] ?? '',
      active: json["active"] ?? "A",
      reservationDetails: (json['reservationDetails'] as List<dynamic>?)
              ?.map((e) => ReservationDetail.fromJson(e))
              .toList() ??
          [],
      clientNames: json['clientNames'] ?? '',
      sellerNames: json['sellerNames'] ?? '',
      formattedReservationDate: json['formattedReservationDate'] ?? '',
      totalReservation: json['totalReservation']?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'client': client.toJson(),
      'seller': seller.toJson(),
      'paymentMethod': paymentMethod.toJson(),
      'reservationDate': reservationDate,
      'active': active,
      'reservationDetails': reservationDetails.map((i) => i.toJson()).toList(),
      'clientNames': clientNames,
      'sellerNames': sellerNames,
      'formattedReservationDate': formattedReservationDate,
      'totalReservation': totalReservation,
    };
  }

  static Reservation empty() {
    return Reservation(
      id: null,
      client: Client.empty(),
      seller: Seller.empty(),
      paymentMethod: PaymentMethod.empty(),
      reservationDate: DateTime.now().toIso8601String(),
      active: 'A',
      reservationDetails: [],
    );
  }
}