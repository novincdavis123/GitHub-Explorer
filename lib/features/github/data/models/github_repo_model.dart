class GithubRepoModel {
  final String name;
  final String? description;
  final int stars;
  final String? language;
  final DateTime? updatedAt;

  const GithubRepoModel({
    required this.name,
    this.description,
    required this.stars,
    this.language,
    this.updatedAt,
  });

  factory GithubRepoModel.fromJson(Map<String, dynamic> json) {
    return GithubRepoModel(
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      stars: json['stargazers_count'] as int? ?? 0,
      language: json['language'] as String?,
      updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? ''),
    );
  }
}
