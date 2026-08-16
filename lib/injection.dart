import 'package:get_it/get_it.dart';
import 'package:githubexplorer/core/network/dio_client.dart';
import 'package:githubexplorer/features/github/data/github_api.dart';
import 'package:githubexplorer/features/github/data/github_repository.dart';
import 'package:githubexplorer/features/github/presentation/bloc/github_bloc.dart';

final GetIt sl = GetIt.instance;

Future<void> init() async {
  if (!sl.isRegistered<DioClient>()) {
    sl.registerLazySingleton<DioClient>(DioClient.new);
  }

  if (!sl.isRegistered<GithubApi>()) {
    sl.registerLazySingleton<GithubApi>(() => GithubApi(sl<DioClient>()));
  }

  if (!sl.isRegistered<GithubRepository>()) {
    sl.registerLazySingleton<GithubRepository>(
      () => GithubRepository(sl<GithubApi>()),
    );
  }

  if (!sl.isRegistered<GithubBloc>()) {
    sl.registerFactory<GithubBloc>(() => GithubBloc(sl<GithubRepository>()));
  }
}
