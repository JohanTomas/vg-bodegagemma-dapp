import 'package:myapp/models/category_model.dart';

class Product {
  final int id;
  final String code; // Add the code field
  final String name;
  final Category categoryProduct;
  final double priceUnit;
  final String unitSale;
  final DateTime? dateExpiry;
  final double stock;
  final String active;

  Product({
    required this.id,
    required this.code, // Add the code field
    required this.name,
    required this.categoryProduct,
    required this.priceUnit,
    required this.unitSale,
    this.dateExpiry,
    required this.stock,
    required this.active,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json["id"] ?? 0,
      code: json["code"] ?? "", // Add the code field
      name: json["name"] ?? "",
      categoryProduct: Category.fromJson(json["categoryProduct"] ?? {}),
      priceUnit: (json["priceUnit"] ?? 0).toDouble(),
      unitSale: json["unitSale"] ?? "",
      dateExpiry: json["dateExpiry"] != null
          ? DateTime.parse(json["dateExpiry"])
          : null,
      stock: (json["stock"] ?? 0).toDouble(),
      active: json["active"] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code, // Add the code field
      'name': name,
      'categoryProduct': categoryProduct.toJson(),
      'priceUnit': priceUnit,
      'unitSale': unitSale,
      'dateExpiry': dateExpiry?.toIso8601String(),
      'stock': stock,
      'active': active,
    };
  }

  static Product empty() {
    return Product(
      id: 0,
      code: '', // Add the code field
      name: '',
      categoryProduct: Category.empty(),
      priceUnit: 0.0,
      unitSale: '',
      dateExpiry: null,
      stock: 0,
      active: '',
    );
  }
}