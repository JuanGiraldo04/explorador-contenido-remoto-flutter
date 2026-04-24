import 'package:flutter/material.dart';

import '../../domain/entities/location.dart';

class LocationDetailScreen extends StatelessWidget {
  const LocationDetailScreen({super.key, required this.location});

  final Location location;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(location.name), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              location.name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            _InfoRow(icon: Icons.category, label: 'Tipo', value: location.type),
            _InfoRow(
              icon: Icons.public,
              label: 'Dimensión',
              value: location.dimension,
            ),
            _InfoRow(
              icon: Icons.people,
              label: 'Residentes',
              value: '${location.residentCount}',
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }
}
