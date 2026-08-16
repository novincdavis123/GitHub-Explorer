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
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.username}\'s Repositories',
          overflow: TextOverflow.ellipsis,
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
      children: [
        _SortSelector(
          selectedType: sortType,
          onChanged: (type) {
            context.read<GithubBloc>().add(SortRepositories(type));
          },
        ),

        const Divider(height: 1),

        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
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
          Icon(Icons.sort, color: Theme.of(context).colorScheme.primary),
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
