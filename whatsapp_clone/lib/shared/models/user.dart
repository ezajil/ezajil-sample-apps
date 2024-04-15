
class User {
  final String userId;
  final String screenName;
  final String? avatarUrl;
  final String? email;
  final Map<String, String>? metadata;
  bool? online;
  int? lastSeen;

  User({
    required this.userId,
    required this.screenName,
    this.avatarUrl,
    this.email,
    this.metadata,
  });
}
