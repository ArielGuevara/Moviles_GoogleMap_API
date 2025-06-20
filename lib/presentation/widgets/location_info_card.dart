import 'dart:ui';
import 'package:flutter/material.dart';

class LocationInfoCard extends StatelessWidget {
  final double? latitude;
  final double? longitude;
  final String? address;

  const LocationInfoCard({
    Key? key,
    this.latitude,
    this.longitude,
    this.address,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (latitude == null || longitude == null) {
      return const SizedBox.shrink();
    }
    return Positioned(
      top: 140,
      left: 16,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            padding: const EdgeInsets.all(12),
            color: Colors.white.withOpacity(0.8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Lat: ${latitude!.toStringAsFixed(6)}',
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Lng: ${longitude!.toStringAsFixed(6)}',
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (address != null)
                  Text(
                    address!,
                    style: const TextStyle(color: Colors.black),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}