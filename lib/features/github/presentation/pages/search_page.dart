import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:githubexplorer/core/storage/recent_search_storage.dart';
import 'package:githubexplorer/core/widgets/app_loader.dart';
import 'package:githubexplorer/core/widgets/empty_state.dart';
import 'package:githubexplorer/core/widgets/error_view.dart';
import 'package:githubexplorer/features/github/presentation/bloc/github_bloc.dart';
import 'package:githubexplorer/features/github/presentation/bloc/github_event.dart';
import 'package:githubexplorer/features/github/presentation/bloc/github_state.dart';
import 'package:githubexplorer/features/github/presentation/pages/repositories_page.dart';
import 'package:githubexplorer/features/github/presentation/widgets/profile_card.dart';
import 'package:githubexplorer/features/github/presentation/widgets/recent_searches.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _usernameController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final RecentSearchStorage _recentSearchStorage = RecentSearchStorage();

  List<String> _recentSearches = [];

  @override
  void initState() {
    super.initState();
    _loadRecentSearches();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadRecentSearches() async {
    final searches = await _recentSearchStorage.getRecentSearches();

    if (!mounted) {
      return;
    }

    setState(() {
      _recentSearches = searches;
    });
  }

  void _searchUser() {
    final username = _usernameController.text.trim();

    if (username.isEmpty) {
      _searchFocusNode.requestFocus();
      return;
    }

    context.read<GithubBloc>().add(SearchUser(username));

    _saveRecentSearch(username);

    FocusScope.of(context).unfocus();
  }

  Future<void> _saveRecentSearch(String username) async {
    await _recentSearchStorage.addSearch(username);

    if (!mounted) {
      return;
    }

    final searches = await _recentSearchStorage.getRecentSearches();

    if (!mounted) {
      return;
    }

    setState(() {
      _recentSearches = searches;
    });
  }

  void _searchRecentUser(String username) {
    _usernameController.text = username;

    context.read<GithubBloc>().add(SearchUser(username));

    FocusScope.of(context).unfocus();
  }

  Future<void> _clearRecentSearches() async {
    await _recentSearchStorage.clearSearches();

    if (!mounted) {
      return;
    }

    setState(() {
      _recentSearches = [];
    });
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        titleSpacing: 20,
        title: Row(
          children: [
            Icon(Icons.code_rounded, color: colorScheme.primary),
            const SizedBox(width: 10),
            const Text(
              'GitHub Explorer',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 44,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _SearchHeader(),

                    const SizedBox(height: 24),

                    _SearchField(
                      controller: _usernameController,
                      focusNode: _searchFocusNode,
                      onSubmitted: (_) => _searchUser(),
                      onSearch: _searchUser,
                    ),

                    if (_recentSearches.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      RecentSearches(
                        searches: _recentSearches,
                        onSearchTap: _searchRecentUser,
                        onClear: _clearRecentSearches,
                      ),
                    ],

                    const SizedBox(height: 24),

                    BlocBuilder<GithubBloc, GithubState>(
                      builder: (context, state) {
                        return _buildContent(state);
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildContent(GithubState state) {
    switch (state.status) {
      case GithubStatus.initial:
        return const Padding(
          padding: EdgeInsets.only(top: 20),
          child: EmptyState(
            icon: Icons.person_search_outlined,
            title: 'Find a GitHub Profile',
            message: 'Enter a GitHub username above to get started.',
          ),
        );

      case GithubStatus.loading:
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 48),
          child: AppLoader(message: 'Searching GitHub...'),
        );

      case GithubStatus.failure:
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 32),
          child: ErrorView(
            message: state.errorMessage ?? 'Something went wrong.',
            onRetry: _searchUser,
          ),
        );

      case GithubStatus.success:
        final user = state.user;

        if (user == null) {
          return const EmptyState(
            icon: Icons.person_search_outlined,
            title: 'Find a GitHub Profile',
            message: 'Enter a GitHub username above to get started.',
          );
        }

        return ProfileCard(
          user: user,
          onRepositoriesTap: () {
            _openRepositories(user.username);
          },
        );
    }
  }
}

class _SearchHeader extends StatelessWidget {
  const _SearchHeader();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Explore GitHub',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Search for a GitHub username to explore their '
          'profile and repositories.',
          style: theme.textTheme.bodyMedium?.copyWith(
            height: 1.5,
            color: colorScheme.onSurfaceVariant,
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        textInputAction: TextInputAction.search,
        textCapitalization: TextCapitalization.none,
        autocorrect: false,
        onSubmitted: onSubmitted,
        decoration: InputDecoration(
          hintText: 'Enter GitHub username',
          hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: colorScheme.onSurfaceVariant,
          ),
          suffixIcon: Padding(
            padding: const EdgeInsets.all(6),
            child: IconButton.filled(
              onPressed: onSearch,
              tooltip: 'Search',
              icon: const Icon(Icons.arrow_forward_rounded, size: 20),
            ),
          ),
          filled: true,
          fillColor: colorScheme.surface,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: colorScheme.outlineVariant),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: colorScheme.outlineVariant),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: colorScheme.primary, width: 2),
          ),
        ),
      ),
    );
  }
}
