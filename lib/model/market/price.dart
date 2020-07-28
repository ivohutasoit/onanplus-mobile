import 'package:onanplus/model/market/product.dart';
import 'package:onanplus/model/market/store.dart';

class Price {
  final int id;
  final String sku;
  final Product product;
  final Store store;
  final String seller;
  final bool promotion;
  final String unit;
  final String currency;
  final double amount;
  final DateTime startDate;
  final DateTime endDate;

  Price({
    this.id,
    this.sku,
    this.product,
    this.store,
    this.seller,
    this.promotion,
    this.unit,
    this.currency,
    this.amount,
    this.startDate,
    this.endDate,
  });

  factory Price.fromJson(Map<String, dynamic> json) {
    return Price(
      id: json['id'],
      sku: json['sku'],
      product: Product.fromJson(json['product']) ?? null,
      store: Store.fromJson(json['store']) ?? null,
      seller: json['seller'],
      currency: json['currency'],
      promotion: json['promotion'],
      unit: json['unit'],
      amount: json['amount']
    );
  }
}