import 'package:equatable/equatable.dart';
import 'package:githubexplorer/features/github/data/models/github_repo_model.dart';
import 'package:githubexplorer/features/github/data/models/github_user_model.dart';

enum GithubStatus { initial, loading, success, failure }

enum SortType { stars, recentlyUpdated }

class GithubState extends Equatable {
  final GithubStatus status;
  final GithubUserModel? user;
  final List<GithubRepoModel> repositories;
  final String? errorMessage;
  final SortType sortType;

  const GithubState({
    this.status = GithubStatus.initial,
    this.user,
    this.repositories = const [],
    this.errorMessage,
    this.sortType = SortType.stars,
  });

  static const _undefined = Object();

  GithubState copyWith({
    GithubStatus? status,
    Object? user = _undefined,
    List<GithubRepoModel>? repositories,
    Object? errorMessage = _undefined,
    SortType? sortType,
  }) {
    return GithubState(
      status: status ?? this.status,
      user: identical(user, _undefined) ? this.user : user as GithubUserModel?,
      repositories: repositories ?? this.repositories,
      errorMessage: identical(errorMessage, _undefined)
          ? this.errorMessage
          : errorMessage as String?,
      sortType: sortType ?? this.sortType,
    );
  }

  @override
  List<Object?> get props => [
    status,
    user,
    repositories,
    errorMessage,
    sortType,
  ];
}
