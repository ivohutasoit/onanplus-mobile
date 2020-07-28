import 'package:onanplus/service/market/product_service.dart';

enum CodeInfo {
  none,
  product,
  user,
  url
}

class CodeService {
  ProductService _productService;

  CodeService() {
    _productService = ProductService(); 
  }
  
  Future<Map<String, dynamic>> getInfo(String code) async {
    var product = await _productService.detail(code);
    if(product != null) {
      return {
        'detail': CodeInfo.product,
        'data': product,
      };
    }
    return {
      'detail': CodeInfo.none,
    };
  }
}