import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:githubexplorer/features/github/presentation/bloc/github_bloc.dart';
import 'package:githubexplorer/features/github/presentation/bloc/github_event.dart';
import 'package:githubexplorer/features/github/presentation/bloc/github_state.dart';
import 'package:githubexplorer/features/github/presentation/pages/repositories_page.dart';
import 'package:githubexplorer/features/github/presentation/widgets/profile_card.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _usernameController = TextEditingController();

  final FocusNode _searchFocusNode = FocusNode();

  @override
  void dispose() {
    _usernameController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _searchUser() {
    final username = _usernameController.text.trim();

    if (username.isEmpty) {
      _searchFocusNode.requestFocus();
      return;
    }

    context.read<GithubBloc>().add(SearchUser(username));

    FocusScope.of(context).unfocus();
  }

  void _openRepositories(String username) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<GithubBloc>(),
          child: RepositoriesPage(username: username),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'GitHub Explorer',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SearchHeader(),

              const SizedBox(height: 24),

              _SearchField(
                controller: _usernameController,
                focusNode: _searchFocusNode,
                onSubmitted: (_) => _searchUser(),
                onSearch: _searchUser,
              ),

              const SizedBox(height: 24),

              Expanded(
                child: BlocBuilder<GithubBloc, GithubState>(
                  builder: (context, state) {
                    return _buildContent(state);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(GithubState state) {
    switch (state.status) {
      case GithubStatus.initial:
        return const _InitialView();

      case GithubStatus.loading:
        return const _LoadingView();

      case GithubStatus.failure:
        return _ErrorView(
          message: state.errorMessage ?? 'Something went wrong.',
          onRetry: _searchUser,
        );

      case GithubStatus.success:
        if (state.user == null) {
          return const _InitialView();
        }

        return ProfileCard(
          user: state.user!,
          onRepositoriesTap: () {
            _openRepositories(state.user!.username);
          },
        );
    }
  }
}

class _SearchHeader extends StatelessWidget {
  const _SearchHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Explore GitHub',
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Search for a GitHub username to explore their profile and repositories.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.focusNode,
    required this.onSubmitted,
    required this.onSearch,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onSearch;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      textInputAction: TextInputAction.search,
      textCapitalization: TextCapitalization.none,
      autocorrect: false,
      onSubmitted: onSubmitted,
      decoration: InputDecoration(
        hintText: 'Enter GitHub username',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: IconButton(
          onPressed: onSearch,
          icon: const Icon(Icons.arrow_forward),
          tooltip: 'Search',
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 2,
          ),
        ),
      ),
    );
  }
}

class _InitialView extends StatelessWidget {
  const _InitialView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.person_search_outlined,
              size: 72,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 20),
            Text(
              'Find a GitHub Profile',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Enter a GitHub username above to get started.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Searching GitHub...'),
        ],
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
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),
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
