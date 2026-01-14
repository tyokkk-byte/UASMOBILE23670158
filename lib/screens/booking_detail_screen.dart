import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/booking.dart';
import '../services/booking_service.dart';
import '../services/db_helper.dart';
import '../utils/constants.dart';

class BookingDetailScreen extends StatefulWidget {
  final Booking booking;
  const BookingDetailScreen({Key? key, required this.booking}) : super(key: key);

  @override
  State<BookingDetailScreen> createState() => _BookingDetailScreenState();
}

class _BookingDetailScreenState extends State<BookingDetailScreen> {
  final BookingService _bookingService = BookingService();
  final DBHelper _db = DBHelper();
  bool _isLoading = false;
  String _userRole = 'tenant';
  int _currentUserId = 0;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userRole = prefs.getString('session_role') ?? 'tenant';
      _currentUserId = prefs.getInt('session_user_id') ?? 0;
    });
  }

  Future<void> _approveBooking() async {
    setState(() => _isLoading = true);
    try {
      await _bookingService.approveBooking(widget.booking.id!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Booking approved!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _rejectBooking() async {
    setState(() => _isLoading = true);
    try {
      await _bookingService.rejectBooking(widget.booking.id!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Booking rejected')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Details'),
        backgroundColor: AppColors.primary,
      ),
      body: FutureBuilder(
        future: Future.wait([
          _db.getPropertyById(widget.booking.propertyId),
          _db.getUserById(widget.booking.tenantId),
        ]),
        builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final property = snapshot.data![0];
          final tenant = snapshot.data![1];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status Badge
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      color: _getStatusColor(widget.booking.status),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      widget.booking.status.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Property Info
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Property Details', style: AppTextStyles.subtitle),
                        const Divider(),
                        Text(property.title, style: AppTextStyles.title),
                        const SizedBox(height: 4),
                        Text('Location: ${property.location}'),
                        Text('Price: Rp ${property.price.toStringAsFixed(0)}/day'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Tenant Info
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Tenant Information', style: AppTextStyles.subtitle),
                        const Divider(),
                        Text('Username: ${tenant.username}'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Booking Info
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Rental Period', style: AppTextStyles.subtitle),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Start Date'),
                            Text(widget.booking.startDate.split('T')[0]),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('End Date'),
                            Text(widget.booking.endDate.split('T')[0]),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Duration'),
                            Text('${widget.booking.durationInDays} days'),
                          ],
                        ),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Total Price', style: AppTextStyles.subtitle),
                            Text(
                              'Rp ${widget.booking.totalPrice.toStringAsFixed(0)}',
                              style: AppTextStyles.title,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Action Buttons (only for pending bookings AND if user is the property owner)
                if (widget.booking.status == 'pending' && 
                    _userRole == 'owner' && 
                    property.ownerId == _currentUserId) ...[
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _rejectBooking,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('REJECT'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _approveBooking,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('APPROVE'),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
