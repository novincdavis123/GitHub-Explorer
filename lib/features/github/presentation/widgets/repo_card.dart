import 'package:flutter/material.dart';
import 'package:githubexplorer/features/github/data/models/github_repo_model.dart';

class RepositoryCard extends StatelessWidget {
  const RepositoryCard({super.key, required this.repository});

  final GithubRepoModel repository;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _RepositoryHeader(name: repository.name),

            if (_hasDescription) ...[
              const SizedBox(height: 8),
              Text(
                repository.description!,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],

            const SizedBox(height: 16),

            _RepositoryInfo(
              stars: repository.stars,
              language: repository.language,
              updatedAt: repository.updatedAt,
            ),
          ],
        ),
      ),
    );
  }

  bool get _hasDescription {
    return repository.description != null &&
        repository.description!.trim().isNotEmpty;
  }
}

class _RepositoryHeader extends StatelessWidget {
  const _RepositoryHeader({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.folder_outlined,
          size: 22,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            name,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}

class _RepositoryInfo extends StatelessWidget {
  const _RepositoryInfo({
    required this.stars,
    required this.language,
    required this.updatedAt,
  });

  final int stars;
  final String? language;
  final DateTime? updatedAt;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 10,
      children: [
        _InfoItem(icon: Icons.star_border, label: '$stars'),
        if (language != null && language!.trim().isNotEmpty)
          _InfoItem(icon: Icons.code, label: language!),
        _InfoItem(icon: Icons.update, label: _formatDate(updatedAt)),
      ],
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) {
      return 'Unknown';
    }

    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}

class _InfoItem extends StatelessWidget {
  const _InfoItem({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 17, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 5),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
