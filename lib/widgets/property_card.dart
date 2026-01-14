import 'dart:io';
import 'package:flutter/material.dart';
import '../models/property.dart';
import '../utils/constants.dart';

class PropertyCard extends StatelessWidget {
  final Property property;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final VoidCallback? onRent; // tombol sewa untuk tenant

  const PropertyCard({
    Key? key,
    required this.property,
    this.onTap,
    this.onDelete,
    this.onRent,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        shadowColor: Colors.grey.withOpacity(0.3),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            property.imagePath != null
                ? ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: Image.file(
                      File(property.imagePath!),
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  )
                : Container(
                    height: 120,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    ),
                    child: const Icon(Icons.home, size: 50, color: Colors.grey),
                  ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(property.title,
                      style: AppTextStyles.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text('Rp ${property.price}', style: AppTextStyles.body),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (onDelete != null)
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: onDelete,
                        ),
                      if (onRent != null)
                        ElevatedButton(
                          onPressed: onRent,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            textStyle: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          child: const Text('Sewa'),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
