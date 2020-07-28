import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:onanplus/constant/constant.dart';
import 'package:onanplus/model/model.dart';

class PriceService {
  Future<Price> create(Price newPrice) async {
    final response = await http.post('$kAPI/price',
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8'
      },
      body: jsonEncode(<String, dynamic> {
        'sku': newPrice.sku,
        'product_id': newPrice.product.id,
        'store_id': newPrice.store.id,
        'seller': newPrice.seller,
        'unit': newPrice.unit,
        'promotion': newPrice.promotion,
        'currency': newPrice.currency,
        'amount': newPrice.amount
      })
    );
    if(response.statusCode == 201) {
      final body = jsonDecode(response.body);
      var price = Price.fromJson(body['price']);
      print(price);
      return price;
    } else {
      throw Exception(response.body);
    }
  }
}