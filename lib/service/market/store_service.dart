import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:onanplus/constant/constant.dart';
import 'package:onanplus/model/model.dart';

class StoreService {

  Future<List<Store>> list() async {
    final response = await http.get('$kAPI/store')
      .timeout(Duration(seconds: 10));
    if(response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final stores = body['stores'] as List;
      return stores.map<Store>((json) => Store.fromJson(json)).toList();
    } else {
      throw Exception(response.body);
    }
  }

  Future<Store> create(Store newStore) async {
    final response = await http.post('$kAPI/store',
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8'
      },
      body: jsonEncode(<String, dynamic> {
        'code': newStore.code,
        'name': newStore.name,
        'online': newStore.online,
        'website': newStore.website,
        'latitude': newStore.latitude,
        'longitude': newStore.longitude,
        'source_id': newStore.sourceId
      })
    );
    if(response.statusCode == 201) {
      final body = json.decode(response.body);
      return Store.fromJson(body['store']);
    } else {
      throw Exception(response.body);
    }
  }

  Future<Store> detail(String code) async {
    final response = await http.get('$kAPI/store/$code')
      .timeout(Duration(seconds: 10));
    if(response.statusCode == 200) {
      Map<String, dynamic> body = jsonDecode(response.body);
      final store = Store.fromJson(body['store']);
      return store;
    } else {
      throw Exception(response.body);
    }
  }

  Future<List<Store>> around(double latitude, double longitude) async {
    final response = await http.post('$kAPI/store/around',
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8'
      },
      body: jsonEncode(<String, dynamic> {
        'latitude': latitude,
        'longitude': longitude,
      })
    );
    if(response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final stores = body['stores'] as List;
      return stores.map<Store>((json) => Store.fromJson(json)).toList();
    } else {
      throw Exception(response.body);
    }
  }
}