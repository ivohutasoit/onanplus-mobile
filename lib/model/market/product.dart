class Product {
  final int id;
  final String barcode;
  final String name;
  final String manufacture;
  final String detail;

  Product({
    this.id,
    this.barcode,
    this.name,
    this.manufacture,
    this.detail
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      barcode: json['barcode'],
      name: json['name'],
      manufacture: json['manufacture'],
      detail: json['detail']
    );
  }
}