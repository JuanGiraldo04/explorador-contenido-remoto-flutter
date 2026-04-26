import 'package:flutter/material.dart';

import '../../domain/entities/character.dart';

class CharacterDetailScreen extends StatelessWidget {
  const CharacterDetailScreen({super.key, required this.character});

  final Character character;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: character.image.isEmpty ? null : 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: character.id,
                child: character.image.isEmpty
                    ? SizedBox.shrink()
                    : Image.network(character.image, fit: BoxFit.cover),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    spacing: 10,
                    children: [
                      Expanded(
                        child: Text(
                          character.name,
                          style: const TextStyle(
                            fontSize: 30,
                            shadows: [
                              Shadow(blurRadius: 4, color: Colors.black54),
                            ],
                          ),
                          maxLines: 2,
                        ),
                      ),
                      _StatusRow(character: character),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _InfoRow(
                    icon: Icons.category,
                    label: 'Especie',
                    value: character.species,
                  ),
                  if (character.type.isNotEmpty)
                    _InfoRow(
                      icon: Icons.label,
                      label: 'Tipo',
                      value: character.type,
                    ),
                  _InfoRow(
                    icon: Icons.person,
                    label: 'Género',
                    value: _genderLabel(character.gender),
                  ),
                  const Divider(height: 32),
                  _InfoRow(
                    icon: Icons.home,
                    label: 'Origen',
                    value: character.origin.name,
                  ),
                  _InfoRow(
                    icon: Icons.location_on,
                    label: 'Última ubicación',
                    value: character.location.name,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _genderLabel(CharacterGender gender) => switch (gender) {
    CharacterGender.female => 'Femenino',
    CharacterGender.male => 'Masculino',
    CharacterGender.genderless => 'Sin género',
    CharacterGender.unknown => 'Desconocido',
  };
}

class _StatusRow extends StatelessWidget {
  const _StatusRow({required this.character});

  final Character character;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (character.status) {
      CharacterStatus.alive => ('Vivo', Colors.green),
      CharacterStatus.dead => ('Muerto', Colors.red),
      CharacterStatus.unknown => ('Desconocido', Colors.grey),
    };

    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(color: color, fontWeight: FontWeight.w600),
        ),
      ],
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
