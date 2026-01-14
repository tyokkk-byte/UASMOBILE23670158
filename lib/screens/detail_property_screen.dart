import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import '../models/property.dart';
import '../services/db_helper.dart';
import '../routes/app_routes.dart';
import '../utils/constants.dart';

class DetailPropertyScreen extends StatefulWidget {
  final Property property;
  const DetailPropertyScreen({Key? key, required this.property}) : super(key: key);

  @override
  State<DetailPropertyScreen> createState() => _DetailPropertyScreenState();
}

class _DetailPropertyScreenState extends State<DetailPropertyScreen> {
  final DBHelper _db = DBHelper();
  String _userRole = 'tenant';

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userRole = prefs.getString('session_role') ?? 'tenant';
    });
  }

  Future<void> _deleteProperty() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
        title: const Text('Delete Property'),
        content: const Text('Are you sure you want to delete this property?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _db.deleteProperty(widget.property.id!);
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // App Bar with Image
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: AppColors.black,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.arrow_back, color: Colors.white),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            actions: _userRole == 'owner'
                ? [
                    IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.edit, color: Colors.white),
                      ),
                      onPressed: () => Navigator.pushNamed(
                        context,
                        AppRoutes.addEditProperty,
                        arguments: widget.property,
                      ),
                    ),
                    IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.delete, color: AppColors.error),
                      ),
                      onPressed: _deleteProperty,
                    ),
                  ]
                : null,
            flexibleSpace: FlexibleSpaceBar(
              background: widget.property.imagePath != null && widget.property.imagePath!.isNotEmpty
                  ? Image.file(File(widget.property.imagePath!), fit: BoxFit.cover)
                  : Container(
                      color: AppColors.gray200,
                      child: const Icon(Icons.home_work_rounded, size: 80, color: Colors.white),
                    ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status Badge
                      if (widget.property.status != 'available')
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: widget.property.status == 'booked'
                                ? AppColors.warning.withOpacity(0.1)
                                : AppColors.error.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            widget.property.status.toUpperCase(),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: widget.property.status == 'booked'
                                  ? AppColors.warning
                                  : AppColors.error,
                            ),
                          ),
                        ),
                      const SizedBox(height: 12),
                      // Title
                      Text(widget.property.title, style: AppTextStyles.displayMedium),
                      const SizedBox(height: 8),
                      // Location
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 18, color: AppColors.gray600),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(widget.property.location, style: AppTextStyles.bodyLarge),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Price
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.payments_outlined, color: AppColors.primary),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Price per Day', style: TextStyle(fontSize: 12)),
                                Text(
                                  'Rp ${widget.property.price.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                    fontSize: 24,
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

                const SizedBox(height: 8),

                // Description Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Description', style: AppTextStyles.titleLarge),
                      const SizedBox(height: 12),
                      Text(widget.property.description, style: AppTextStyles.bodyLarge),
                    ],
                  ),
                ),

                const SizedBox(height: 100), // Space for bottom buttons
              ],
            ),
          ),
        ],
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
          child: Row(
            children: [
              // Contact via WhatsApp
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final phone = '08123456789';
                    final message = 'Halo, saya tertarik menyewa "${widget.property.title}"';
                    final url = Uri.parse('https://wa.me/$phone?text=${Uri.encodeFull(message)}');

                    try {
                      await launchUrl(url, mode: LaunchMode.externalApplication);
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Cannot open WhatsApp')),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.chat_bubble_outline, size: 20),
                  label: const Text('Contact'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: BorderSide(color: AppColors.gray400),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Book Now
              if (_userRole != 'owner' && widget.property.status == 'available')
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.bookingForm,
                        arguments: widget.property,
                      );
                    },
                    icon: const Icon(Icons.event_available, size: 20),
                    label: const Text('Book Now'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
