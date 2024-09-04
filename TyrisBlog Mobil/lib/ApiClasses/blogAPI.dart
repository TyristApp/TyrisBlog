import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../model/Blog.dart';
import '../model/Comment.dart';

class blogAPI {
  String maindomain = "http://10.0.2.2:8000/api"; //andorid
  //String maindomain = "http://127.0.0.1:8000/api"; //ios


  Future<void> saveblog2(String blogTitle, String blogContent) async {
    final apiUrl = '$maindomain/blog/create/';

    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('access_token');

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
        if (accessToken != null) 'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode({
        'blog_title': blogTitle,
        'blog_content': blogContent,
        'is_active': true,
      }),
    );

    if (response.statusCode == 201) {
      print('Blog başarıyla kaydedildi.');
    } else {
      print('Blog kaydedilemedi: ${response.body}');
    }
  }

  Future<void> saveblog(
      String blogTitle, String blogContent, File? blogImage) async {
    final apiUrl = '$maindomain/blog/create/';

    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('access_token');

    final request = http.MultipartRequest('POST', Uri.parse(apiUrl))
      ..fields['blog_title'] = blogTitle
      ..fields['blog_content'] = blogContent
      ..fields['is_active'] = 'true';

    if (accessToken != null) {
      request.headers['Authorization'] = 'Bearer $accessToken';
    }

    if (blogImage != null) {
      final stream = http.ByteStream(blogImage.openRead());
      final length = await blogImage.length();
      final multipartFile = http.MultipartFile('blog_image', stream, length,
          filename: blogImage.path.split('/').last);
      request.files.add(multipartFile);
    }

    final response = await request.send();

    if (response.statusCode == 201) {
      print('Blog başarıyla kaydedildi.');
    } else {
      final responseBody = await response.stream.bytesToString();
      print('Blog kaydedilemedi: $responseBody');
    }
  }

  Future<List<Blog>> fetchBlogs({int page = 1}) async {
    final response = await http.get(
      Uri.parse('$maindomain/blogs/?page=$page'),
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body)['results'];
      return data.map((json) => Blog.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load blogs');
    }
  }

  Future<List<Blog>> fetchBlogs2() async {
    final response = await http.get(Uri.parse('$maindomain/blogs/'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Blog.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load blogs');
    }
  }

  Future<List<Blog>> fetchBlogsByUser(int userId) async {
    final response =
        await http.get(Uri.parse('$maindomain/blogs-by-user/?user_id=$userId'));

    if (response.statusCode == 200) {
      List<dynamic> jsonData = jsonDecode(response.body);
      return jsonData.map((data) => Blog.fromJson(data)).toList();
    } else {
      throw Exception('Bloglar alınamadı');
    }
  }

  Future<List<Blog>> fetchBlogsByTitle2(String title) async {
    final response =
        await http.get(Uri.parse('$maindomain/blogs-by-title/?title=$title'));

    if (response.statusCode == 200) {
      List<dynamic> jsonData = jsonDecode(response.body);

      return jsonData.map((data) => Blog.fromJson(data)).toList();
    } else {
      throw Exception('Bloglar alınamadı');
    }
  }

  Future<List<Blog>> fetchBlogsByTitle(String title,
      {int page = 1, int pageSize = 20}) async {
    final response = await http.get(Uri.parse(
        '$maindomain/blogs-by-title/?title=$title&page=$page&page_size=$pageSize'));

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      final blogs = jsonData['results'] as List<dynamic>;

      return blogs.map((data) => Blog.fromJson(data)).toList();
    } else {
      throw Exception('Bloglar alınamadı');
    }
  }

  Future<void> commentOnBlog(int blogId, String commentContent) async {
    final apiUrl = '$maindomain/comment-blog/';

    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('access_token');

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
        if (accessToken != null) 'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode({
        'blog_id': blogId,
        'comment_content': commentContent,
      }),
    );

    if (response.statusCode == 201) {
      print('yorum başarıyla kaydedildi.');
    } else {
      print('yorum kaydedilemedi: ${response.body}');
    }
  }

  Future<List<Comment>> fetchComments(int blogId) async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('access_token');
    final url = Uri.parse('${maindomain}/get-comments-by-blog/');

    final response = await http.get(
      url.replace(queryParameters: {'blog_id': blogId.toString()}),
      headers: {
        'Content-Type': 'application/json',
        if (accessToken != null) 'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> responseBody = json.decode(response.body);
      return responseBody.map((json) => Comment.fromJson(json)).toList();
    } else {
      throw Exception('Yorumlar alınırken bir hata oluştu: ${response.body}');
    }
  }

  Future<void> likeBlog(int blogId, bool isLike) async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('access_token');

    final endpoint = isLike ? '/like-blog/' : '/unlike-blog/';
    final fullUrl = Uri.parse('${maindomain}$endpoint');

    final response = await http.post(
      fullUrl,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: json.encode({'blog_id': blogId}),
    );

    if (response.statusCode != 200) {
      final errorMessage = json.decode(response.body)['error'];
      throw Exception(
          'Failed to ${isLike ? 'like' : 'unlike'} blog: $errorMessage');
    }
  }

  Future<Map<String, dynamic>> getBlogLikeStatus(int blogId) async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('access_token');

    final url = Uri.parse('$maindomain/blog-likes-status/$blogId/');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        if (accessToken != null) 'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return {
        'user_liked': data['user_liked'],
        'total_likes': data['total_likes'],
      };
    } else {
      throw Exception(
          'Blog beğeni durumu alınırken bir hata oluştu: ${response.body}');
    }
  }

  Future<void> deleteBlog(int blogId) async {
    final url = Uri.parse('${maindomain}/delete-blog/');

    final prefs = await SharedPreferences.getInstance();
    final authToken = prefs.getString('access_token');

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'blog_id': blogId,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == 'Blog başarıyla silindi') {
          print('Blog başarıyla silindi.');
        } else {
          print('Beklenmedik bir hata oluştu.');
        }
      } else {
        final responseData = json.decode(response.body);
        throw Exception('Hata: ${responseData['error']}');
      }
    } catch (error) {
      throw Exception('Silme işlemi sırasında bir hata oluştu: $error');
    }
  }

  Future<Map<String, dynamic>> fetchUserLikes(int userId) async {
    final url = Uri.parse('${maindomain}/user-likes-status/$userId/');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load user likes');
    }
  }

  Future<Map<String, dynamic>> fetchUserComments(int userId) async {
    final url = Uri.parse('${maindomain}/user-comment-status/$userId/');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load user comments');
    }
  }

  Future<String?> uploadImage(File imageFile) async {
    final String apiUrl = '${maindomain}/upload-image/';

    var request = http.MultipartRequest('POST', Uri.parse(apiUrl));

    request.files.add(
      http.MultipartFile(
        'image',
        imageFile.readAsBytes().asStream(),
        imageFile.lengthSync(),
        filename: imageFile.uri.pathSegments.last,
      ),
    );

    var response = await request.send();

    if (response.statusCode == 201) {
      print('Image uploaded successfully');
      final responseData = await response.stream.bytesToString();
      print(responseData);

      final Map<String, dynamic> jsonResponse = jsonDecode(responseData);

      return jsonResponse['file_url'] as String?;
    } else {
      print('Failed to upload image');
      final responseData = await response.stream.bytesToString();
      print(responseData);
      return null;
    }
  }

  Future<List<Blog>> fetchFavoriteBlogsOfMonth() async {
    final response =
        await http.get(Uri.parse('$maindomain/favorite-blogs-of-month/'));

    if (response.statusCode == 200) {
      List<dynamic> jsonData = jsonDecode(response.body);
      return jsonData.map((data) => Blog.fromJson(data)).toList();
    } else {
      throw Exception('Favori bloglar alınamadı');
    }
  }
}
