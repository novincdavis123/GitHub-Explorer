import 'package:flutter/material.dart';
import 'package:githubexplorer/features/github/data/models/github_user_model.dart';

class ProfileCard extends StatelessWidget {
  const ProfileCard({
    super.key,
    required this.user,
    required this.onRepositoriesTap,
  });

  final GithubUserModel user;
  final VoidCallback onRepositoriesTap;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 20),
      child: Card(
        elevation: 0,
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              _ProfileAvatar(avatarUrl: user.avatarUrl),

              const SizedBox(height: 20),

              _ProfileName(name: user.name, username: user.username),

              if (user.bio?.trim().isNotEmpty == true) ...[
                const SizedBox(height: 16),
                _Bio(bio: user.bio!),
              ],

              const SizedBox(height: 28),

              _ProfileStats(
                followers: user.followers,
                following: user.following,
                repositories: user.publicRepos,
              ),

              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: onRepositoriesTap,
                  icon: const Icon(Icons.folder_outlined),
                  label: const Text('View Repositories'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({required this.avatarUrl});

  final String avatarUrl;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (avatarUrl.isEmpty) {
      return CircleAvatar(
        radius: 52,
        backgroundColor: colorScheme.surfaceContainerHighest,
        child: Icon(
          Icons.person,
          size: 52,
          color: colorScheme.onSurfaceVariant,
        ),
      );
    }

    return CircleAvatar(
      radius: 52,
      backgroundColor: colorScheme.surfaceContainerHighest,
      child: ClipOval(
        child: Image.network(
          avatarUrl,
          width: 104,
          height: 104,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) {
            return Icon(
              Icons.person,
              size: 52,
              color: colorScheme.onSurfaceVariant,
            );
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) {
              return child;
            }

            return const SizedBox(
              width: 104,
              height: 104,
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            );
          },
        ),
      ),
    );
  }
}

class _ProfileName extends StatelessWidget {
  const _ProfileName({required this.name, required this.username});

  final String? name;
  final String username;

  @override
  Widget build(BuildContext context) {
    final displayName = name?.trim().isNotEmpty == true
        ? name!.trim()
        : username;

    return Column(
      children: [
        Text(
          displayName,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 4),

        Text(
          '@$username',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _Bio extends StatelessWidget {
  const _Bio({required this.bio});

  final String bio;

  @override
  Widget build(BuildContext context) {
    return Text(
      bio.trim(),
      textAlign: TextAlign.center,
      maxLines: 5,
      overflow: TextOverflow.ellipsis,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.4),
    );
  }
}

class _ProfileStats extends StatelessWidget {
  const _ProfileStats({
    required this.followers,
    required this.following,
    required this.repositories,
  });

  final int followers;
  final int following;
  final int repositories;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatItem(value: _formatCount(followers), label: 'Followers'),
        ),
        Expanded(
          child: _StatItem(value: _formatCount(following), label: 'Following'),
        ),
        Expanded(
          child: _StatItem(
            value: _formatCount(repositories),
            label: 'Repositories',
          ),
        ),
      ],
    );
  }

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    }

    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }

    return count.toString();
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 4),

        Text(
          label,
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }
}
