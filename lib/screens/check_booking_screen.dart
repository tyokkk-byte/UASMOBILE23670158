import 'package:flutter/material.dart';
import '../services/db_helper.dart';
import '../models/booking.dart';
import '../routes/app_routes.dart';
import '../utils/constants.dart';

class CheckBookingScreen extends StatefulWidget {
  const CheckBookingScreen({Key? key}) : super(key: key);

  @override
  State<CheckBookingScreen> createState() => _CheckBookingScreenState();
}

class _CheckBookingScreenState extends State<CheckBookingScreen> {
  final _codeController = TextEditingController();
  final DBHelper _db = DBHelper();
  bool _isLoading = false;

  Future<void> _checkBooking() async {
    if (_codeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter booking code')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final booking = await _db.getBookingByCode(_codeController.text.trim().toUpperCase());

      if (booking == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Booking code not found'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      } else {
        if (mounted) {
          Navigator.pushNamed(context, AppRoutes.bookingDetail, arguments: booking);
        }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Check Booking'),
        backgroundColor: AppColors.black,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.search, size: 50, color: AppColors.primary),
            ),
            const SizedBox(height: 32),
            Text(
              'Enter Booking Code',
              textAlign: TextAlign.center,
              style: AppTextStyles.displayMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Enter the 8-character code from your booking',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyLarge,
            ),
            const SizedBox(height: 40),
            TextField(
              controller: _codeController,
              textAlign: TextAlign.center,
              textCapitalization: TextCapitalization.characters,
              maxLength: 8,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                letterSpacing: 4,
                color: AppColors.primary,
              ),
              decoration: InputDecoration(
                hintText: 'ABC12345',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  borderSide: BorderSide(color: AppColors.gray300, width: 2),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  borderSide: BorderSide(color: AppColors.primary, width: 2),
                ),
                counterText: '',
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _checkBooking,
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
                  : const Text('Check Booking', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }
}
