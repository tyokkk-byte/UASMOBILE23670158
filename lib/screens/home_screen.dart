import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../models/property.dart';
import '../services/db_helper.dart';
import '../routes/app_routes.dart';
import '../utils/constants.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DBHelper _db = DBHelper();
  List<Property> _properties = [];
  String _userRole = 'owner';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProperties();
  }

  Future<void> _loadProperties() async {
    setState(() => _isLoading = true);
    
    final prefs = await SharedPreferences.getInstance();
    final role = prefs.getString('session_role') ?? 'owner';
    setState(() => _userRole = role);

    if (role == 'tenant' || role == 'guest') {
      _properties = await _db.getAvailableProperties();
    } else {
      _properties = await _db.getAllProperties();
    }
    
    setState(() => _isLoading = false);
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.black,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Rental Properti',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            Text(
              _userRole == 'guest' ? 'Guest Mode' : _userRole.toUpperCase(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            tooltip: 'Refresh',
            onPressed: _loadProperties,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : RefreshIndicator(
              color: AppColors.primary,
              onRefresh: _loadProperties,
              child: _properties.isEmpty
                  ? _buildEmptyState()
                  : GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.75,
                      ),
                      itemCount: _properties.length,
                      itemBuilder: (context, index) {
                        return _buildPropertyCard(_properties[index]);
                      },
                    ),
            ),
      floatingActionButton: _userRole == 'owner'
          ? FloatingActionButton.extended(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.addEditProperty)
                  .then((_) => _loadProperties()),
              backgroundColor: AppColors.primary,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text('Add', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            )
          : null,
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.gray100,
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: Icon(Icons.home_work_outlined, size: 50, color: AppColors.gray500),
          ),
          const SizedBox(height: 24),
          Text('No Properties', style: AppTextStyles.headlineLarge),
          const SizedBox(height: 8),
          Text(
            _userRole == 'owner' ? 'Tap + to add property' : 'No available properties',
            style: AppTextStyles.bodyLarge,
          ),
        ],
      ),
    );
  }

  Widget _buildPropertyCard(Property property) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(
        context,
        AppRoutes.detailProperty,
        arguments: property,
      ).then((_) => _loadProperties()),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.md),
          boxShadow: AppShadows.small,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.md)),
              child: Container(
                height: 120,
                width: double.infinity,
                color: AppColors.gray200,
                child: property.imagePath != null && property.imagePath!.isNotEmpty
                    ? Image.file(File(property.imagePath!), fit: BoxFit.cover)
                    : Icon(Icons.home_work_rounded, size: 40, color: AppColors.gray400),
              ),
            ),
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      property.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // Location
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 14, color: AppColors.gray500),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            property.location,
                            style: TextStyle(fontSize: 12, color: AppColors.gray600),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    // Price & Status
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Rp ${(property.price / 1000).toStringAsFixed(0)}K',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                        if (property.status != 'available')
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: property.status == 'booked'
                                  ? AppColors.warning.withOpacity(0.1)
                                  : AppColors.error.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              property.status.toUpperCase(),
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: property.status == 'booked'
                                    ? AppColors.warning
                                    : AppColors.error,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
