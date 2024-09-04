import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../model/User.dart';

class UserApi {
  String maindomain = "http://10.0.2.2:8000"; //andorid
  //String maindomain = "http://127.0.0.1:8000"; //ios

  Future<void> saveToken(String accessToken, String refreshToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', accessToken);
    await prefs.setString('refresh_token', refreshToken);
  }

  Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  Future<void> saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user', jsonEncode(user.toJson()));
  }

  Future<User?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userString = prefs.getString('user');
    print(userString);
    if (userString != null) {
      return User.fromJson(jsonDecode(userString));
    }
    return null;
  }

  Future<sonuc> login(String email, String password) async {
    String apiUrl = '$maindomain/api/user/login/';
    Uri uri = Uri.parse(apiUrl);

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      // Başarılı giriş
      final responseData = jsonDecode(response.body);
      final accessToken = responseData['access'] ?? '';
      final refreshToken = responseData['refresh'] ?? '';
      final userData = responseData['user'];

      print(responseData);

      final user = User.fromJson(userData);

      await saveToken(accessToken, refreshToken);
      await saveUser(user);

      return sonuc(true, "Başarılı Giriş");
    } else {
      // Hata durumu
      return sonuc(false, "Başarısız Giriş");
    }
  }

  Future<String> register(String email, String firstname, String lastname,
      String username, String pass1) async {
    String apiUrl = '$maindomain/api/user/create/';
    Uri uri = Uri.parse(
        '$apiUrl?email=$email&password=$pass1&first_name=$firstname&last_name=$lastname&username=$username');

    try {
      var response = await http.post(uri);

      if (response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        final userData = jsonResponse['user'];
        final message = jsonResponse['message'];
        final accessToken = jsonResponse['access'] ?? '';
        final refreshToken = jsonResponse['refresh'] ?? '';

        final user = User.fromJson(userData);
        print("sonuc: " + user.id.toString());

        await saveToken(accessToken, refreshToken);
        await saveUser(user);

        return message.toString();
      } else {
        var jsonResponse = jsonDecode(response.body);
        var error = jsonResponse['error'];
        return error.toString();
      }
    } catch (e) {
      var error = 'Error: $e';
      return error.toString();
    }
  }

  Future<bool> autologin() async {
    final prefs = await SharedPreferences.getInstance();

    // Token'ları SharedPreferences'tan al
    final accessToken = prefs.getString('access_token');
    final refreshToken = prefs.getString('refresh_token');

    final User? user = await getUser();

    // Eğer accessToken veya refreshToken yoksa, kullanıcıyı giriş ekranına yönlendir
    if (accessToken == null || refreshToken == null) {
      return false;
    }

    // Token'ların geçerliliğini kontrol etmek için API'ye istek yapın
    final apiUrl = '$maindomain/api/user/check-token/';
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode({
        'user': user?.toJson(),
      }),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  Future<void> updateEmail(int userId, String newEmail) async {
    final apiUrl = '${maindomain}/api/update-email/';

    // SharedPreferences'dan token'ı al
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('access_token');

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
        if (accessToken != null) 'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode({
        'user_id': userId,
        'new_email': newEmail,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      print('E-mail başarıyla güncellendi.');
    } else {
      print('Hata: ${response.body}');
    }
  }

  Future<void> updatePassword(
      String oldPassword, String newPassword, int userId) async {
    final apiUrl = '${maindomain}/api/update_password/';

    // SharedPreferences'dan kullanıcı ID'sini al
    final prefs = await SharedPreferences.getInstance();

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${prefs.getString('access_token')}',
      },
      body: jsonEncode({
        'user_id': userId,
        'old_password': oldPassword,
        'new_password': newPassword,
      }),
    );

    if (response.statusCode == 200) {
      print('Şifre başarıyla güncellendi.');
    } else {
      final responseData = jsonDecode(response.body);
      throw Exception('Hata: ${responseData['error']}');
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
    await prefs.remove('user');
  }

  Future<String> deleteUser(int userId) async {
    String apiUrl = '$maindomain/api/delete-user/';
    Uri uri = Uri.parse('$apiUrl?user_id=$userId');

    try {
      var response = await http.delete(uri);

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        var message = jsonResponse['message'] ?? 'Hesap başarıyla silindi.';
        return message.toString();
      } else {
        var jsonResponse = jsonDecode(response.body);
        var error = jsonResponse['error'] ?? 'Bir hata oluştu.';
        return error.toString();
      }
    } catch (e) {
      return 'Hata: $e';
    }
  }
}

class sonuc {
  late bool girisMi;
  late String mesaj;

  sonuc(this.girisMi, this.mesaj);
}
