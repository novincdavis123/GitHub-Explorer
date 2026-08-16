import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:githubexplorer/features/github/presentation/bloc/github_bloc.dart';
import 'package:githubexplorer/features/github/presentation/bloc/github_event.dart';
import 'package:githubexplorer/features/github/presentation/bloc/github_state.dart';

class RepositoriesPage extends StatefulWidget {
  const RepositoriesPage({super.key, required this.username});

  final String username;

  @override
  State<RepositoriesPage> createState() => _RepositoriesPageState();
}

class _RepositoriesPageState extends State<RepositoriesPage> {
  @override
  void initState() {
    super.initState();

    context.read<GithubBloc>().add(LoadRepositories(widget.username));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.username}\'s Repositories')),
      body: BlocBuilder<GithubBloc, GithubState>(
        builder: (context, state) {
          switch (state.status) {
            case GithubStatus.initial:
            case GithubStatus.loading:
              return const Center(child: CircularProgressIndicator());

            case GithubStatus.failure:
              return _ErrorView(
                message: state.errorMessage ?? 'Something went wrong.',
                onRetry: () {
                  context.read<GithubBloc>().add(
                    LoadRepositories(widget.username),
                  );
                },
              );

            case GithubStatus.success:
              return _RepositoryContent(state: state);
          }
        },
      ),
    );
  }
}

class _RepositoryContent extends StatelessWidget {
  const _RepositoryContent({required this.state});

  final GithubState state;

  @override
  Widget build(BuildContext context) {
    if (state.repositories.isEmpty) {
      return const _EmptyRepositoriesView();
    }

    return Column(
      children: [
        _SortSelector(
          selectedType: state.sortType,
          onChanged: (type) {
            context.read<GithubBloc>().add(SortRepositories(type));
          },
        ),
        const Divider(height: 1),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: state.repositories.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final repository = state.repositories[index];

              return _RepositoryCard(repository: repository);
            },
          ),
        ),
      ],
    );
  }
}

class _SortSelector extends StatelessWidget {
  const _SortSelector({required this.selectedType, required this.onChanged});

  final SortType selectedType;
  final ValueChanged<SortType> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          const Icon(Icons.sort),
          const SizedBox(width: 8),
          const Text('Sort by', style: TextStyle(fontWeight: FontWeight.w600)),
          const Spacer(),
          DropdownButtonHideUnderline(
            child: DropdownButton<SortType>(
              value: selectedType,
              items: const [
                DropdownMenuItem(value: SortType.stars, child: Text('Stars')),
                DropdownMenuItem(
                  value: SortType.recentlyUpdated,
                  child: Text('Recently Updated'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  onChanged(value);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _RepositoryCard extends StatelessWidget {
  const _RepositoryCard({required this.repository});

  final dynamic repository;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              repository.name,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            if (repository.description != null &&
                repository.description!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                repository.description!,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
            const SizedBox(height: 14),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                _InfoItem(
                  icon: Icons.star_border,
                  label: '${repository.stars}',
                ),
                if (repository.language != null &&
                    repository.language!.isNotEmpty)
                  _InfoItem(icon: Icons.code, label: repository.language!),
                _InfoItem(
                  icon: Icons.update,
                  label: _formatDate(repository.updatedAt),
                ),
              ],
            ),
          ],
        ),
      ),
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
        Text(label),
      ],
    );
  }
}

class _EmptyRepositoriesView extends StatelessWidget {
  const _EmptyRepositoriesView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.folder_open_outlined, size: 56),
            SizedBox(height: 16),
            Text(
              'No public repositories',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8),
            Text(
              'This user does not have any public repositories.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 56),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}
