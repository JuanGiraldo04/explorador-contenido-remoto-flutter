import 'package:flutter/material.dart';

import '../../domain/entities/episode.dart';

class EpisodeCard extends StatelessWidget {
  const EpisodeCard({super.key, required this.episode, this.onTap});

  final Episode episode;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Text(
            episode.code.split('E').last,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
        ),
        title: Text(
          episode.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text('${episode.code} · ${episode.airDate}'),
        trailing: _CharactersBadge(count: episode.characterCount),
      ),
    );
  }
}

class _CharactersBadge extends StatelessWidget {
  const _CharactersBadge({required this.count});

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
        const Text('pers.', style: TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }
}
