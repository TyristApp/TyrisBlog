class Blog {
  final String imageUrl;
  final int blogid;
  final String title;
  final String author;
  final DateTime dateTime;
  final String content;

  Blog({
    required this.imageUrl,
    required this.title,
    required this.author,
    required this.dateTime,
    required this.content,
    required this.blogid,
  });

  factory Blog.fromJson(Map<String, dynamic> json) {
    return Blog(
      imageUrl: json['blog_image'] ?? '',
      title: json['blog_title'] ?? 'Başlık Yok',
      author: json['username'] ?? 'Yazar Bilgisi Yok',
      blogid: json['blog_id'] ?? 0,
      content: json['blog_content'] ?? 'İçerik Bilgisi Yok',
      dateTime:
          DateTime.parse(json['blog_date'] ?? DateTime.now().toIso8601String()),
    );
  }
}
