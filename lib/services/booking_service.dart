import 'db_helper.dart';
import '../models/booking.dart';
import '../models/property.dart';

class BookingService {
  final DBHelper _db = DBHelper();

  // Create new booking with validation
  Future<Map<String, dynamic>> createBooking({
    required int propertyId,
    required int tenantId,
    required String startDate,
    required String endDate,
    required double dailyPrice,
    String rentalType = 'daily',
  }) async {
    // Validate dates
    final start = DateTime.parse(startDate);
    final end = DateTime.parse(endDate);
    
    if (end.isBefore(start)) {
      throw Exception('End date must be after start date');
    }

    // Calculate total price
    final duration = end.difference(start).inDays;
    if (duration < 1) {
      throw Exception('Minimum rental duration is 1 day');
    }
    
    final totalPrice = duration * dailyPrice;
    
    // Generate unique booking code
    final bookingCode = _db.generateBookingCode();

    // Create booking
    final booking = Booking(
      propertyId: propertyId,
      tenantId: tenantId,
      startDate: startDate,
      endDate: endDate,
      totalPrice: totalPrice,
      rentalType: rentalType,
      bookingCode: bookingCode,
      status: 'pending',
      createdAt: DateTime.now().toIso8601String(),
    );

    final bookingId = await _db.insertBooking(booking);
    
    // Return booking ID and code
    return {
      'bookingId': bookingId,
      'bookingCode': bookingCode,
    };
  }

  // Owner approves booking
  Future<void> approveBooking(int bookingId) async {
    // Get booking details
    final bookings = await _db.getAllBookings();
    final booking = bookings.firstWhere((b) => b.id == bookingId);

    // Update booking status to approved
    await _db.updateBookingStatus(bookingId, 'approved');

    // Update property status to booked
    await _db.updatePropertyStatus(booking.propertyId, 'booked');
  }

  // Owner rejects booking
  Future<void> rejectBooking(int bookingId) async {
    // Just update booking status, property remains available
    await _db.updateBookingStatus(bookingId, 'rejected');
  }

  // Get bookings by user role
  Future<List<Booking>> getMyBookings(int userId, String role) async {
    if (role == 'tenant') {
      return await _db.getBookingsByTenant(userId);
    } else if (role == 'owner') {
      return await _db.getPendingBookingsForOwner(userId);
    }
    return [];
  }

  // Get booking with full details (property + tenant info)
  Future<Map<String, dynamic>> getBookingDetails(int bookingId) async {
    final bookings = await _db.getAllBookings();
    final booking = bookings.firstWhere((b) => b.id == bookingId);

    final property = await _db.getPropertyById(booking.propertyId);
    final tenant = await _db.getUserById(booking.tenantId);

    return {
      'booking': booking,
      'property': property,
      'tenant': tenant,
    };
  }

  // Check if property has pending or approved bookings
  Future<bool> hasActiveBooking(int propertyId) async {
    final bookings = await _db.getBookingsByProperty(propertyId);
    return bookings.any((b) => b.status == 'pending' || b.status == 'approved');
  }
}
