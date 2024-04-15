
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
    this.online,
    this.lastSeen
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['userId'],
      screenName: json['screenName'],
      avatarUrl: json['avatar'],
      email: json['email'],
      metadata: json['metadata'],
      lastSeen: json['lastSeen'],
      online: json['online'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'screenName': screenName,
      'avatar': avatarUrl,
      'email': email,
      'metadata': metadata,
      'lastSeen': lastSeen,
      'online': online,
    };
  }
}
