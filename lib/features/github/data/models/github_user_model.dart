import 'package:equatable/equatable.dart';

class GithubUserModel extends Equatable {
  const GithubUserModel({
    required this.username,
    required this.avatarUrl,
    this.name,
    this.bio,
    required this.followers,
    required this.following,
    required this.publicRepos,
  });

  final String username;
  final String avatarUrl;
  final String? name;
  final String? bio;
  final int followers;
  final int following;
  final int publicRepos;

  factory GithubUserModel.fromJson(Map<String, dynamic> json) {
    return GithubUserModel(
      username: json['login'] as String? ?? '',
      avatarUrl: json['avatar_url'] as String? ?? '',
      name: json['name'] as String?,
      bio: json['bio'] as String?,
      followers: json['followers'] as int? ?? 0,
      following: json['following'] as int? ?? 0,
      publicRepos: json['public_repos'] as int? ?? 0,
    );
  }

  @override
  List<Object?> get props => [
    username,
    avatarUrl,
    name,
    bio,
    followers,
    following,
    publicRepos,
  ];
}
