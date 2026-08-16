import 'package:githubexplorer/features/github/data/github_api.dart';
import 'package:githubexplorer/features/github/data/models/github_repo_model.dart';
import 'package:githubexplorer/features/github/data/models/github_user_model.dart';

class GithubRepository {
  GithubRepository(this._api);

  final GithubApi _api;

  Future<GithubUserModel> getUser(String username) {
    return _api.getUser(username);
  }

  Future<List<GithubRepoModel>> getRepositories(String username) {
    return _api.getRepositories(username);
  }
}
