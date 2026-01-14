import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/booking.dart';
import '../services/db_helper.dart';
import '../routes/app_routes.dart';
import '../utils/constants.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({Key? key}) : super(key: key);

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  final DBHelper _db = DBHelper();
  List<Booking> _bookings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('session_user_id') ?? 0;
    final bookings = await _db.getBookingsByTenant(userId);
    setState(() {
      _bookings = bookings;
      _isLoading = false;
    });
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return AppColors.warning;
      case 'approved':
        return AppColors.success;
      case 'rejected':
        return AppColors.error;
      default:
        return AppColors.gray500;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Bookings'),
        backgroundColor: AppColors.black,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadBookings,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _bookings.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: _loadBookings,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _bookings.length,
                    itemBuilder: (context, index) {
                      return _buildBookingCard(_bookings[index]);
                    },
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 200,
            height: 200,
            child: Lottie.asset('lib/animations/booking.json'),
          ),
          const SizedBox(height: 24),
          Text('No Bookings Yet', style: AppTextStyles.headlineLarge),
          const SizedBox(height: 8),
          Text(
            'Your booking requests will appear here',
            style: AppTextStyles.bodyLarge,
          ),
        ],
      ),
    );
  }

  Widget _buildBookingCard(Booking booking) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: AppShadows.small,
      ),
      child: InkWell(
        onTap: () => Navigator.pushNamed(
          context,
          AppRoutes.bookingDetail,
          arguments: booking,
        ).then((_) => _loadBookings()),
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Code + Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Booking Code
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.confirmation_number, size: 16, color: AppColors.primary),
                        const SizedBox(width: 6),
                        Text(
                          booking.bookingCode,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(booking.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      booking.status.toUpperCase(),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: _getStatusColor(booking.status),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Property Info (will be loaded async)
              FutureBuilder(
                future: _db.getPropertyById(booking.propertyId),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const SizedBox(height: 40);
                  }
                  final property = snapshot.data!;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        property.title,
                        style: AppTextStyles.titleLarge,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 14, color: AppColors.gray600),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              property.location,
                              style: AppTextStyles.bodyMedium,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),
              // Booking Details
              Row(
                children: [
                  Expanded(
                    child: _buildInfoItem(
                      icon: Icons.calendar_today,
                      label: 'Start',
                      value: booking.startDate.split('T')[0],
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 30,
                    color: AppColors.gray300,
                  ),
                  Expanded(
                    child: _buildInfoItem(
                      icon: Icons.event_available,
                      label: 'End',
                      value: booking.endDate.split('T')[0],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Price
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.gray100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total Price', style: AppTextStyles.bodyMedium),
                    Text(
                      'Rp ${booking.totalPrice.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, size: 16, color: AppColors.gray600),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 11, color: AppColors.gray600)),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
