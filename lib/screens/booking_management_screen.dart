import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/booking.dart';
import '../services/db_helper.dart';
import '../routes/app_routes.dart';
import '../utils/constants.dart';

class BookingManagementScreen extends StatefulWidget {
  const BookingManagementScreen({Key? key}) : super(key: key);

  @override
  State<BookingManagementScreen> createState() => _BookingManagementScreenState();
}

class _BookingManagementScreenState extends State<BookingManagementScreen> {
  final DBHelper _db = DBHelper();
  List<Booking> _allBookings = [];
  List<Booking> _filteredBookings = [];
  String _selectedFilter = 'all';
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
    final bookings = await _db.getPendingBookingsForOwner(userId);
    setState(() {
      _allBookings = bookings;
      _applyFilter();
      _isLoading = false;
    });
  }

  void _applyFilter() {
    if (_selectedFilter == 'all') {
      _filteredBookings = _allBookings;
    } else {
      _filteredBookings = _allBookings.where((b) => b.status == _selectedFilter).toList();
    }
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
        title: const Text('All Bookings'),
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
      body: Column(
        children: [
          // Filter Chips
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('all', 'All', _allBookings.length),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    'pending',
                    'Pending',
                    _allBookings.where((b) => b.status == 'pending').length,
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    'approved',
                    'Approved',
                    _allBookings.where((b) => b.status == 'approved').length,
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    'rejected',
                    'Rejected',
                    _allBookings.where((b) => b.status == 'rejected').length,
                  ),
                ],
              ),
            ),
          ),
          // Bookings List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : _filteredBookings.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        color: AppColors.primary,
                        onRefresh: _loadBookings,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredBookings.length,
                          itemBuilder: (context, index) {
                            return _buildBookingCard(_filteredBookings[index]);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String value, String label, int count) {
    final isSelected = _selectedFilter == value;
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label),
          if (count > 0) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : AppColors.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? AppColors.primary : Colors.white,
                ),
              ),
            ),
          ],
        ],
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = value;
          _applyFilter();
        });
      },
      selectedColor: AppColors.primary,
      backgroundColor: Colors.white,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppColors.textPrimary,
        fontWeight: FontWeight.w600,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? AppColors.primary : AppColors.gray300,
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
          Text('No Bookings', style: AppTextStyles.headlineLarge),
          const SizedBox(height: 8),
          Text(
            _selectedFilter == 'all'
                ? 'No booking requests yet'
                : 'No $_selectedFilter bookings',
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
        border: booking.status == 'pending'
            ? Border.all(color: AppColors.warning, width: 2)
            : null,
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
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.confirmation_number, size: 14, color: AppColors.primary),
                        const SizedBox(width: 6),
                        Text(
                          booking.bookingCode,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
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
              const SizedBox(height: 12),
              // Property & Tenant Info
              FutureBuilder(
                future: Future.wait([
                  _db.getPropertyById(booking.propertyId),
                  _db.getUserById(booking.tenantId),
                ]),
                builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
                  if (!snapshot.hasData) return const SizedBox(height: 60);
                  final property = snapshot.data![0];
                  final tenant = snapshot.data![1];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(property.title, style: AppTextStyles.titleLarge),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.person, size: 14, color: AppColors.gray600),
                          const SizedBox(width: 4),
                          Text('by ${tenant.username}', style: AppTextStyles.bodyMedium),
                        ],
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),
              // Dates & Price
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Period', style: TextStyle(fontSize: 11, color: AppColors.gray600)),
                        const SizedBox(height: 2),
                        Text(
                          '${booking.startDate.split('T')[0]} - ${booking.endDate.split('T')[0]}',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Rp ${booking.totalPrice.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
