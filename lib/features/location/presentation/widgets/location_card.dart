import 'package:flutter/material.dart';

import '../../domain/entities/location.dart';

class LocationCard extends StatelessWidget {
  const LocationCard({super.key, required this.location, this.onTap});

  final Location location;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        onTap: onTap,
        leading: const CircleAvatar(child: Icon(Icons.location_on)),
        title: Text(
          location.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text('${location.type} · ${location.dimension}'),
        trailing: _ResidentsBadge(count: location.residentCount),
      ),
    );
  }
}

class _ResidentsBadge extends StatelessWidget {
  const _ResidentsBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '$count',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const Text('hab.', style: TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }
}
