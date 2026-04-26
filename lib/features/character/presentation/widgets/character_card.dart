import 'package:flutter/material.dart';

import '../../domain/entities/character.dart';
import '../screens/character_detail_screen.dart';

class CharacterCard extends StatelessWidget {
  const CharacterCard({super.key, required this.character});

  final Character character;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CharacterDetailScreen(character: character),
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        leading: Hero(
          tag: character.id,
          child: character.image.isEmpty
              ? SizedBox.shrink()
              : CircleAvatar(
                  backgroundImage: NetworkImage(character.image),
                  radius: 28,
                ),
        ),
        title: Text(
          character.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text('${character.species} · ${character.location.name}'),
        trailing: _StatusBadge(status: character.status),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final CharacterStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      CharacterStatus.alive => ('Vivo', Colors.green),
      CharacterStatus.dead => ('Muerto', Colors.red),
      CharacterStatus.unknown => ('?', Colors.grey),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
