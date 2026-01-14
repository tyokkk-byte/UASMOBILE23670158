import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import '../models/property.dart';
import '../services/db_helper.dart';
import '../utils/constants.dart';

class AddEditPropertyScreen extends StatefulWidget {
  final Property? property;
  const AddEditPropertyScreen({Key? key, this.property}) : super(key: key);

  @override
  State<AddEditPropertyScreen> createState() => _AddEditPropertyScreenState();
}

class _AddEditPropertyScreenState extends State<AddEditPropertyScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final DBHelper _db = DBHelper();
  String? _imagePath;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.property != null) {
      _titleController.text = widget.property!.title;
      _locationController.text = widget.property!.location;
      _priceController.text = widget.property!.price.toString();
      _descriptionController.text = widget.property!.description;
      _imagePath = widget.property!.imagePath;
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _imagePath = image.path);
    }
  }

  Future<void> _saveProperty() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final ownerId = prefs.getInt('session_user_id') ?? 0;

      final property = Property(
        id: widget.property?.id,
        title: _titleController.text.trim(),
        location: _locationController.text.trim(),
        price: double.parse(_priceController.text.trim()),
        description: _descriptionController.text.trim(),
        imagePath: _imagePath,
        ownerId: ownerId,
        status: widget.property?.status ?? 'available',
        createdAt: widget.property?.createdAt ?? DateTime.now().toIso8601String(),
      );

      if (widget.property == null) {
        await _db.insertProperty(property);
      } else {
        await _db.updateProperty(property);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.property == null ? 'Property added!' : 'Property updated!'),
            backgroundColor: AppColors.success,
          ),
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

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.property != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Property' : 'Add Property'),
        backgroundColor: AppColors.black,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image Picker
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(color: AppColors.gray300, width: 2),
                    boxShadow: AppShadows.small,
                  ),
                  child: _imagePath != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          child: Stack(
                            children: [
                              Image.file(
                                File(_imagePath!),
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.cover,
                              ),
                              Positioned(
                                top: 12,
                                right: 12,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.edit, color: Colors.white, size: 20),
                                ),
                              ),
                            ],
                          ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_photo_alternate_outlined,
                                size: 60, color: AppColors.gray500),
                            const SizedBox(height: 12),
                            Text(
                              'Tap to add photo',
                              style: TextStyle(color: AppColors.gray600, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 24),

              // Title
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Property Title',
                  hintText: 'e.g., Modern Apartment',
                  prefixIcon: Icon(Icons.home, color: AppColors.gray600),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    borderSide: BorderSide(color: AppColors.gray300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    borderSide: BorderSide(color: AppColors.primary, width: 2),
                  ),
                ),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              // Location
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(
                  labelText: 'Location',
                  hintText: 'e.g., Jakarta Selatan',
                  prefixIcon: Icon(Icons.location_on, color: AppColors.gray600),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    borderSide: BorderSide(color: AppColors.gray300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    borderSide: BorderSide(color: AppColors.primary, width: 2),
                  ),
                ),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              // Price
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Price per Day',
                  hintText: 'e.g., 500000',
                  prefixIcon: Icon(Icons.payments, color: AppColors.gray600),
                  prefixText: 'Rp ',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    borderSide: BorderSide(color: AppColors.gray300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    borderSide: BorderSide(color: AppColors.primary, width: 2),
                  ),
                ),
                validator: (value) {
                  if (value!.isEmpty) return 'Required';
                  if (double.tryParse(value) == null) return 'Invalid number';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Description',
                  hintText: 'Describe your property...',
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(bottom: 60),
                    child: Icon(Icons.description, color: AppColors.gray600),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    borderSide: BorderSide(color: AppColors.gray300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    borderSide: BorderSide(color: AppColors.primary, width: 2),
                  ),
                ),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 32),

              // Save Button
              ElevatedButton(
                onPressed: _isLoading ? null : _saveProperty,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
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
                    : Text(
                        isEditing ? 'Update Property' : 'Add Property',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
