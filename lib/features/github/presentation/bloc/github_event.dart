import 'package:equatable/equatable.dart';
import 'package:githubexplorer/features/github/presentation/bloc/github_state.dart';

sealed class GithubEvent extends Equatable {
  const GithubEvent();

  @override
  List<Object?> get props => [];
}

/// Searches for a GitHub user by username.
final class SearchUser extends GithubEvent {
  const SearchUser(this.username);

  final String username;

  @override
  List<Object?> get props => [username];
}

/// Fetches repositories for the selected GitHub user.
final class LoadRepositories extends GithubEvent {
  const LoadRepositories(this.username);

  final String username;

  @override
  List<Object?> get props => [username];
}

/// Sorts the already-fetched repositories locally.
final class SortRepositories extends GithubEvent {
  const SortRepositories(this.type);

  final SortType type;

  @override
  List<Object?> get props => [type];
}
