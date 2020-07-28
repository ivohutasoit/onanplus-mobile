import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:onanplus/constant/constant.dart';
import 'package:onanplus/model/model.dart';

class ProductService {
  Future<List<Product>> list() async {
    final response = await http.get('$kAPI/product')
      .timeout(Duration(seconds: 10));
    if(response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final products = body['products'] as List;
      return products.map<Product>((json) => Product.fromJson(json)).toList();
    } else {
      throw Exception(response.body);
    }
  }

  Future<Product> create(Product newProduct) async {
    final response = await http.post('$kAPI/product',
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8'
      },
      body: jsonEncode(<String, dynamic> {
        'barcode': newProduct.barcode,
        'name': newProduct.name,
        'manufacture': newProduct.manufacture,
        'detail': newProduct.detail
      })
    );
    if(response.statusCode == 201) {
      final body = json.decode(response.body);
      final product = Product.fromJson(body['product']);
      print(product);
      return product;
    } else {
      throw Exception(response.body);
    }
  }

  Future<Product> detail(String code) async {
    final response = await http.get('$kAPI/product/$code')
      .timeout(Duration(seconds: 10));
    if(response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return Product.fromJson(body['product']);
    } else if(response.statusCode == 404) {
      return null;
    } else {
      throw Exception(response.body);
    }
  }

  Future<List<Price>> prices(String code) async {
    return null;
  }
}