import 'package:githubexplorer/core/network/dio_client.dart';
import 'package:githubexplorer/features/github/data/models/github_repo_model.dart';
import 'package:githubexplorer/features/github/data/models/github_user_model.dart';

class GithubApi {
  GithubApi(this._dioClient);

  final DioClient _dioClient;

  Future<GithubUserModel> getUser(String username) async {
    final response = await _dioClient.dio.get('/users/${username.trim()}');

    return GithubUserModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<GithubRepoModel>> getRepositories(String username) async {
    final response = await _dioClient.dio.get(
      '/users/${username.trim()}/repos',
      queryParameters: {'per_page': 100},
    );

    final data = response.data as List<dynamic>;

    return data
        .map((json) => GithubRepoModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
