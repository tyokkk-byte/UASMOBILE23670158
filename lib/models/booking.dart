class Booking {
  int? id;
  int propertyId;
  int tenantId; // Link to user instead of name/phone
  String startDate; // Rental start date (ISO 8601)
  String endDate; // Rental end date
  double totalPrice; // Calculated total
  String rentalType; // 'daily', 'weekly', 'monthly', 'yearly'
  String bookingCode; // Unique code for check-in (8 chars)
  String status; // 'pending', 'approved', 'rejected', 'completed'
  String? createdAt; // Booking timestamp

  Booking({
    this.id,
    required this.propertyId,
    required this.tenantId,
    required this.startDate,
    required this.endDate,
    required this.totalPrice,
    this.rentalType = 'daily',
    required this.bookingCode,
    this.status = 'pending',
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'propertyId': propertyId,
      'tenantId': tenantId,
      'startDate': startDate,
      'endDate': endDate,
      'totalPrice': totalPrice,
      'rentalType': rentalType,
      'bookingCode': bookingCode,
      'status': status,
      'createdAt': createdAt,
    };
  }

  factory Booking.fromMap(Map<String, dynamic> map) {
    return Booking(
      id: map['id'],
      propertyId: map['propertyId'],
      tenantId: map['tenantId'],
      startDate: map['startDate'],
      endDate: map['endDate'],
      totalPrice: map['totalPrice'],
      rentalType: map['rentalType'] ?? 'daily',
      bookingCode: map['bookingCode'] ?? '',
      status: map['status'] ?? 'pending',
      createdAt: map['createdAt'],
    );
  }

  // Helper: Calculate rental duration in days
  int get durationInDays {
    try {
      final start = DateTime.parse(startDate);
      final end = DateTime.parse(endDate);
      return end.difference(start).inDays;
    } catch (e) {
      return 0;
    }
  }
}
