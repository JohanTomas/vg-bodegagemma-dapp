import 'package:myapp/models/product_model.dart';

class ReservationDetail {
  int? id;
  Product product;
  double amount;

  ReservationDetail({
    this.id,
    required this.product,
    required this.amount,
  });

  factory ReservationDetail.fromJson(Map<String, dynamic> json) {
    return ReservationDetail(
      id: json['id'],
      product: Product.fromJson(json['product']),
      amount: json['amount']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product': product.toJson(),
      'amount': amount,
    };
  }
}