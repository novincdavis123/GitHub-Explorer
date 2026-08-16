import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:githubexplorer/core/widgets/app_loader.dart';
import 'package:githubexplorer/core/widgets/empty_state.dart';
import 'package:githubexplorer/core/widgets/error_view.dart';
import 'package:githubexplorer/features/github/data/models/github_repo_model.dart';
import 'package:githubexplorer/features/github/presentation/bloc/github_bloc.dart';
import 'package:githubexplorer/features/github/presentation/bloc/github_event.dart';
import 'package:githubexplorer/features/github/presentation/bloc/github_state.dart';
import 'package:githubexplorer/features/github/presentation/widgets/repo_card.dart';

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

  void _loadRepositories() {
    context.read<GithubBloc>().add(LoadRepositories(widget.username));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            Icon(
              Icons.folder_copy_outlined,
              color: colorScheme.primary,
              size: 22,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '${widget.username}\'s Repositories',
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
      body: BlocBuilder<GithubBloc, GithubState>(
        builder: (context, state) {
          switch (state.status) {
            case GithubStatus.initial:
            case GithubStatus.loading:
              return const AppLoader(message: 'Loading repositories...');

            case GithubStatus.failure:
              return ErrorView(
                message: state.errorMessage ?? 'Unable to load repositories.',
                onRetry: _loadRepositories,
              );

            case GithubStatus.success:
              return _RepositoryContent(
                repositories: state.repositories,
                sortType: state.sortType,
              );
          }
        },
      ),
    );
  }
}

class _RepositoryContent extends StatelessWidget {
  const _RepositoryContent({
    required this.repositories,
    required this.sortType,
  });

  final List<GithubRepoModel> repositories;
  final SortType sortType;

  @override
  Widget build(BuildContext context) {
    if (repositories.isEmpty) {
      return const EmptyState(
        icon: Icons.folder_open_outlined,
        title: 'No public repositories',
        message: 'This user does not have any public repositories.',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _RepositoryHeader(
          repositoryCount: repositories.length,
          sortType: sortType,
        ),

        const Divider(height: 1),

        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            itemCount: repositories.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return RepositoryCard(repository: repositories[index]);
            },
          ),
        ),
      ],
    );
  }
}

class _RepositoryHeader extends StatelessWidget {
  const _RepositoryHeader({
    required this.repositoryCount,
    required this.sortType,
  });

  final int repositoryCount;
  final SortType sortType;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Repositories',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '$repositoryCount public '
                  '${repositoryCount == 1 ? 'repository' : 'repositories'}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          _SortSelector(
            selectedType: sortType,
            onChanged: (type) {
              context.read<GithubBloc>().add(SortRepositories(type));
            },
          ),
        ],
      ),
    );
  }
}

class _SortSelector extends StatelessWidget {
  const _SortSelector({required this.selectedType, required this.onChanged});

  final SortType selectedType;
  final ValueChanged<SortType> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<SortType>(
          value: selectedType,
          isDense: true,
          borderRadius: BorderRadius.circular(12),
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          items: const [
            DropdownMenuItem(
              value: SortType.stars,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.star_outline_rounded, size: 18),
                  SizedBox(width: 6),
                  Text('Stars'),
                ],
              ),
            ),
            DropdownMenuItem(
              value: SortType.recentlyUpdated,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.update_rounded, size: 18),
                  SizedBox(width: 6),
                  Text('Recently Updated'),
                ],
              ),
            ),
          ],
          onChanged: (value) {
            if (value != null) {
              onChanged(value);
            }
          },
        ),
      ),
    );
  }
}
