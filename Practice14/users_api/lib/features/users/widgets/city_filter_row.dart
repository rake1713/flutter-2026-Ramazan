import 'package:flutter/material.dart';

class CityFilterRow extends StatelessWidget {
  const CityFilterRow({super.key, required this.city, this.onClear});

  final String city;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          InputChip(
            avatar: const Icon(Icons.location_city, size: 18),
            label: Text(city),
            onDeleted: onClear,
          ),
        ],
      ),
    );
  }
}
