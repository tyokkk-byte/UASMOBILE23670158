class Property {
  final int? id;
  final String title;
  final String location;
  final double price;
  final String description;
  final String? imagePath;
  final String status; // 'available', 'booked', 'rented'
  final int? ownerId; // Link to owner user
  final String? createdAt; // Timestamp

  Property({
    this.id,
    required this.title,
    required this.location,
    required this.price,
    required this.description,
    this.imagePath,
    this.status = 'available',
    this.ownerId,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'location': location,
      'price': price,
      'description': description,
      'imagePath': imagePath,
      'status': status,
      'ownerId': ownerId,
      'createdAt': createdAt,
    };
  }

  factory Property.fromMap(Map<String, dynamic> map) {
    return Property(
      id: map['id'],
      title: map['title'],
      location: map['location'],
      price: map['price'],
      description: map['description'],
      imagePath: map['imagePath'],
      status: map['status'] ?? 'available',
      ownerId: map['ownerId'],
      createdAt: map['createdAt'],
    );
  }
}
