class Item {
  int id = 0;
  final String name;
  final String description;
  final String ownerName;
  final String ownerEmail;
  String image;
  final String location;
  double longitude = 0.0;
  double latitude = 0.0;
  String contactInfo = '';
  String state = "undefined";
  double reward = 0.0;
  DateTime? timestamp;

  Item({
    required this.id,
    required this.name,
    required this.description,
    required this.ownerName,
    required this.ownerEmail,
    required this.image,
    required this.location,
    required this.longitude,
    required this.latitude,
    required this.contactInfo,
    required this.state,
    required this.reward,
    this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'ownerName': ownerName,
      'ownerEmail': ownerEmail,
      'image': image,
      'location': location,
      'longitude': longitude,
      'latitude': latitude,
      'contactInfo': contactInfo,
      'state': state,
      'reward': reward,
      'timestamp': timestamp?.toIso8601String(), // Save as ISO 8601 format
    };
  }

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      image: json['image'] ?? '',
      ownerName: json['ownerName'] ?? '',
      ownerEmail: json['ownerEmail'] ?? '',
      location: json['location'] ?? '',
      longitude: json['longitude'] ?? 0.0,
      latitude: json['latitude'] ?? 0.0,
      contactInfo: json['contactInfo'] ?? '',
      state: json['state'] ?? 'undefined',
      reward: json['reward'] ?? 0.0,
      timestamp:
          json['timestamp'] != null ? DateTime.parse(json['timestamp']) : null,
    );
  }
}
