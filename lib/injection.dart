import 'package:get_it/get_it.dart';
import 'package:githubexplorer/core/network/dio_client.dart';
import 'package:githubexplorer/features/github/data/github_api.dart';
import 'package:githubexplorer/features/github/data/github_repository.dart';
import 'package:githubexplorer/features/github/presentation/bloc/github_bloc.dart';

final GetIt sl = GetIt.instance;

Future<void> init() async {
  sl.registerLazySingleton<DioClient>(DioClient.new);

  sl.registerLazySingleton<GithubApi>(() => GithubApi(sl<DioClient>()));

  sl.registerLazySingleton<GithubRepository>(
    () => GithubRepository(sl<GithubApi>()),
  );

  sl.registerFactory<GithubBloc>(() => GithubBloc(sl<GithubRepository>()));
}
