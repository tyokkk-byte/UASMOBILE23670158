import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/property.dart';
import '../services/booking_service.dart';
import '../utils/constants.dart';

class BookingFormScreen extends StatefulWidget {
  final Property property;
  const BookingFormScreen({Key? key, required this.property}) : super(key: key);

  @override
  State<BookingFormScreen> createState() => _BookingFormScreenState();
}

class _BookingFormScreenState extends State<BookingFormScreen> {
  final BookingService _bookingService = BookingService();
  DateTime? _startDate;
  DateTime? _endDate;
  String _rentalType = 'daily';
  String _userRole = 'tenant';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userRole = prefs.getString('session_role') ?? 'tenant';
    });
  }

  Future<void> _selectStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _startDate = picked;
        _endDate = _calculateEndDate(picked);
      });
    }
  }

  DateTime _calculateEndDate(DateTime startDate) {
    switch (_rentalType) {
      case 'daily':
        return startDate.add(const Duration(days: 1));
      case 'weekly':
        return startDate.add(const Duration(days: 7));
      case 'monthly':
        return startDate.add(const Duration(days: 30));
      case 'yearly':
        return startDate.add(const Duration(days: 365));
      default:
        return startDate.add(const Duration(days: 1));
    }
  }

  Future<void> _submitBooking() async {
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select start date')),
      );
      return;
    }

    if (!_canBook) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Monthly/Yearly booking requires Tenant account'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('session_user_id') ?? 1;

      final result = await _bookingService.createBooking(
        propertyId: widget.property.id!,
        tenantId: userId,
        startDate: _startDate!.toIso8601String(),
        endDate: _endDate!.toIso8601String(),
        dailyPrice: widget.property.price,
        rentalType: _rentalType,
      );

      if (mounted) {
        final bookingCode = result['bookingCode'];

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check_circle, size: 32, color: AppColors.success),
                  ),
                  const SizedBox(height: 16),
                  const Text('Booking Submitted!', style: AppTextStyles.headlineLarge),
                  const SizedBox(height: 8),
                  const Text('Your booking code:', style: AppTextStyles.bodyMedium),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: bookingCode));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Code copied to clipboard!'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        border: Border.all(color: AppColors.primary, width: 2),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            bookingCode,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 4,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Icon(Icons.copy, color: AppColors.primary, size: 20),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap to copy',
                    style: TextStyle(fontSize: 12, color: AppColors.gray600),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _userRole == 'guest'
                        ? 'Save this code to check your booking!'
                        : 'View in My Bookings',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.gray600),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                    ),
                    child: const Text('Done', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
          ),
        );
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

  bool get _canBook {
    if (_userRole != 'guest') return true;
    return _rentalType == 'daily' || _rentalType == 'weekly';
  }

  int get _durationDays {
    if (_startDate == null || _endDate == null) return 0;
    return _endDate!.difference(_startDate!).inDays;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Book Property'),
        backgroundColor: AppColors.black,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Property Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppRadius.md),
                boxShadow: AppShadows.small,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.property.title, style: AppTextStyles.titleLarge),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 16, color: AppColors.gray600),
                      const SizedBox(width: 4),
                      Text(widget.property.location, style: AppTextStyles.bodyMedium),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.payments, size: 20, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Rp ${widget.property.price.toStringAsFixed(0)} / day',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Rental Type
            Text('Rental Period', style: AppTextStyles.titleMedium),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildRentalTypeChip('daily', 'Daily (1 day)'),
                _buildRentalTypeChip('weekly', 'Weekly (7 days)'),
                _buildRentalTypeChip('monthly', 'Monthly (30 days)', locked: _userRole == 'guest'),
                _buildRentalTypeChip('yearly', 'Yearly (365 days)', locked: _userRole == 'guest'),
              ],
            ),
            const SizedBox(height: 24),

            // Start Date
            _buildDateCard(
              'Start Date',
              _startDate,
              Icons.event,
              () => _selectStartDate(),
            ),
            const SizedBox(height: 12),

            // End Date (auto-calculated)
            _buildDateCard(
              'End Date (Auto)',
              _endDate,
              Icons.event_available,
              null,
            ),
            const SizedBox(height: 24),

            // Summary
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: AppColors.primary.withOpacity(0.2)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Duration', style: AppTextStyles.bodyLarge),
                      Text('$_durationDays days', style: AppTextStyles.titleMedium),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Price', style: AppTextStyles.titleMedium),
                      Text(
                        'Rp ${(_durationDays * widget.property.price).toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: _isLoading ? null : _submitBooking,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              elevation: 0,
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : const Text('Submit Booking', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          ),
        ),
      ),
    );
  }

  Widget _buildRentalTypeChip(String type, String label, {bool locked = false}) {
    final isSelected = _rentalType == type;
    return ChoiceChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (locked) const Icon(Icons.lock, size: 14),
          if (locked) const SizedBox(width: 4),
          Text(label),
        ],
      ),
      selected: isSelected,
      onSelected: locked
          ? null
          : (selected) {
              setState(() {
                _rentalType = type;
                if (_startDate != null) {
                  _endDate = _calculateEndDate(_startDate!);
                }
              });
            },
      selectedColor: AppColors.primary,
      backgroundColor: Colors.white,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : (locked ? AppColors.gray500 : AppColors.textPrimary),
        fontWeight: FontWeight.w600,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        side: BorderSide(
          color: isSelected ? AppColors.primary : AppColors.gray300,
        ),
      ),
    );
  }

  Widget _buildDateCard(String label, DateTime? date, IconData icon, VoidCallback? onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.gray300),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: TextStyle(fontSize: 12, color: AppColors.gray600)),
                  const SizedBox(height: 2),
                  Text(
                    date != null
                        ? '${date.day}/${date.month}/${date.year}'
                        : 'Select date',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            if (onTap != null)
              Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.gray500),
          ],
        ),
      ),
    );
  }
}
