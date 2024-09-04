class Comment {
  final String commentContent;
  final DateTime commentTime;
  final String username;

  Comment({
    required this.commentContent,
    required this.commentTime,
    required this.username,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      commentContent: json['comment_content'],
      commentTime: DateTime.parse(json['comment_time']),
      username: json['username'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'comment_content': commentContent,
      'comment_time': commentTime.toIso8601String(),
      // DateTime convert ISO 8601 format string
      'username': username,
    };
  }
}
