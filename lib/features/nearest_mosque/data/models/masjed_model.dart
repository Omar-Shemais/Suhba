class MasjedModel {
  final String id;
  final String name;
  final double lat;
  final double lng;
  final String vicinity;
  MasjedModel({
    required this.id,
    required this.name,
    required this.lat,
    required this.lng,
    required this.vicinity,
  });

  factory MasjedModel.fromJson(Map<String, dynamic> json) {
    return MasjedModel(
      id: json['place_id'],
      name: json['name'],
      vicinity: json['vicinity'] ?? "",
      lat: json['geometry']['location']['lat'],
      lng: json['geometry']['location']['lng'],
    );
  }
}
