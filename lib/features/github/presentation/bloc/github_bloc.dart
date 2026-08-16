import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:githubexplorer/features/github/data/github_repository.dart';
import 'package:githubexplorer/features/github/presentation/bloc/github_event.dart';
import 'package:githubexplorer/features/github/presentation/bloc/github_state.dart';

class GithubBloc extends Bloc<GithubEvent, GithubState> {
  GithubBloc(this._repository) : super(const GithubState()) {
    on<SearchUser>(_onSearchUser);
    on<LoadRepositories>(_onLoadRepositories);
    on<SortRepositories>(_onSortRepositories);
  }

  final GithubRepository _repository;

  Future<void> _onSearchUser(
    SearchUser event,
    Emitter<GithubState> emit,
  ) async {
    final username = event.username.trim();

    if (username.isEmpty) {
      emit(
        state.copyWith(
          status: GithubStatus.failure,
          errorMessage: 'Please enter a GitHub username.',
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        status: GithubStatus.loading,
        errorMessage: null,
        user: null,
        repositories: const [],
      ),
    );

    try {
      final user = await _repository.getUser(username);

      emit(
        state.copyWith(
          status: GithubStatus.success,
          user: user,
          errorMessage: null,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: GithubStatus.failure,
          errorMessage: _getErrorMessage(error),
        ),
      );
    }
  }

  Future<void> _onLoadRepositories(
    LoadRepositories event,
    Emitter<GithubState> emit,
  ) async {
    final username = event.username.trim();

    if (username.isEmpty) {
      emit(
        state.copyWith(
          status: GithubStatus.failure,
          errorMessage: 'GitHub username is required.',
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        status: GithubStatus.loading,
        errorMessage: null,
        repositories: const [],
      ),
    );

    try {
      final repositories = await _repository.getRepositories(username);

      emit(
        state.copyWith(
          status: GithubStatus.success,
          repositories: repositories,
          errorMessage: null,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: GithubStatus.failure,
          errorMessage: _getErrorMessage(error),
        ),
      );
    }
  }

  void _onSortRepositories(SortRepositories event, Emitter<GithubState> emit) {
    final repositories = [...state.repositories];

    switch (event.type) {
      case SortType.stars:
        repositories.sort((a, b) => b.stars.compareTo(a.stars));

      case SortType.recentlyUpdated:
        repositories.sort((a, b) {
          final dateA = a.updatedAt ?? DateTime(1970);
          final dateB = b.updatedAt ?? DateTime(1970);

          return dateB.compareTo(dateA);
        });
    }

    emit(state.copyWith(repositories: repositories, sortType: event.type));
  }

  String _getErrorMessage(Object error) {
    if (error is DioException) {
      final statusCode = error.response?.statusCode;

      if (statusCode == 404) {
        return 'GitHub user not found.';
      }

      switch (error.type) {
        case DioExceptionType.connectionError:
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.receiveTimeout:
        case DioExceptionType.sendTimeout:
          return 'Unable to connect to GitHub. Please check your internet connection.';

        default:
          break;
      }
    }

    return 'Something went wrong. Please try again.';
  }
}
