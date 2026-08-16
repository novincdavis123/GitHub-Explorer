import 'package:flutter/material.dart';

class RecentSearches extends StatelessWidget {
  const RecentSearches({
    super.key,
    required this.searches,
    required this.onSearchTap,
    this.onClear,
  });

  final List<String> searches;
  final ValueChanged<String> onSearchTap;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    if (searches.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Recent Searches',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            if (onClear != null)
              TextButton(onPressed: onClear, child: const Text('Clear')),
          ],
        ),
        const SizedBox(height: 8),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: searches.length,
          separatorBuilder: (_, __) => const SizedBox(height: 6),
          itemBuilder: (context, index) {
            final username = searches[index];

            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                radius: 20,
                child: Text(
                  username.isNotEmpty ? username[0].toUpperCase() : '?',
                ),
              ),
              title: Text(username),
              trailing: const Icon(Icons.north_west, size: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              onTap: () => onSearchTap(username),
            );
          },
        ),
      ],
    );
  }
}
