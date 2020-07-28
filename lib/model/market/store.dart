class Store {
  final int id;
  final String code;
  final String name;
  final String website;
  final bool online;
  final double latitude;
  final double longitude;
  final String source;
  final String sourceId;
  final double distance;

  Store({
    this.id,
    this.code,
    this.name,
    this.website,
    this.online,
    this.latitude,
    this.longitude,
    this.source,
    this.sourceId,
    this.distance,
  });

  factory Store.fromJson(Map<String, dynamic> json) {
    return Store(
      id: json['id'],
      code: json['code'],
      name: json['name'],
      website: json['website'],
      online: json['online'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      source: json['source'],
      sourceId: json['source_id'],
      distance: json['distance']
    );
  }
}