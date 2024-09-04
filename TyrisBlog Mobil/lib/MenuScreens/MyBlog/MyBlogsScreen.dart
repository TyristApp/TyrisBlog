import 'package:tyrisblog/ApiClasses/blogAPI.dart';
import 'package:tyrisblog/ApiClasses/userAPI.dart';
import 'package:tyrisblog/Const/AppColors.dart';
import 'package:tyrisblog/Const/DeviceInfo.dart';
import 'package:tyrisblog/MenuScreens/MyBlog/CreateBlogScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../CustomWidgets/CustomButton.dart';
import 'MyBlogListScreen.dart';

class MyBlogScreen extends StatefulWidget {
  const MyBlogScreen({super.key});

  @override
  State<MyBlogScreen> createState() => _MyBlogScreenState();
}

class _MyBlogScreenState extends State<MyBlogScreen> {
  Future<Map<String, dynamic>>? userLikes;
  Future<Map<String, dynamic>>? userComments;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final userApi = UserApi();
    var blogapi = blogAPI();
    final userId = await userApi.getUser();
    if (userId != null) {
      setState(() {
        userLikes = blogapi.fetchUserLikes(userId.id);
        userComments = blogapi.fetchUserComments(userId.id);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Kullanıcı ID alınamadı')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: AppColors.DarkBlueLogo,
        statusBarIconBrightness: Brightness.light,
      ),
    );


    DeviceInfo.setDeviceInfo(context);

    return Scaffold(
      backgroundColor: AppColors.DarkBlueLogo,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                vertical: DeviceInfo.height * 0.01,
                horizontal: DeviceInfo.width * 0.04,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomButton(
                    text: 'Blog Oluştur',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => CreateBlogScreen()),
                      );
                    },
                    color: AppColors.Greenlogo,
                    width: DeviceInfo.width / 3,
                  ),
                  CustomButton(
                    text: 'Yazılmış Bloglar',
                    onPressed: () async {
                      final userApi = UserApi();
                      final userId = await userApi.getUser();
                      if (userId != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                MyBlogListScreen(userId: userId.id),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Kullanıcı ID alınamadı')),
                        );
                      }
                    },
                    color: AppColors.Greenlogo,
                    width: DeviceInfo.width / 3,
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      height: DeviceInfo.height * 0.4,
                      child: FutureBuilder<Map<String, dynamic>>(
                        future: userLikes,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return Center(
                                child: Text('Hata: ${snapshot.error}',
                                    style: TextStyle(color: AppColors.white)));
                          } else if (!snapshot.hasData ||
                              snapshot.data!.isEmpty) {
                            return Center(
                                child: Text('Beğeni bildirimi bulunamadı.',
                                    style: TextStyle(color: AppColors.white)));
                          } else {
                            final likes =
                                snapshot.data!['likes'] as List<dynamic>;
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: DeviceInfo.width * 0.04),
                                  child: Text(
                                    'Beğeni Bildirimleri',
                                    style: TextStyle(
                                        color: AppColors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Expanded(
                                  child: ListView(
                                    shrinkWrap: true,
                                    children: likes.map<Widget>((like) {
                                      return ListTile(
                                        title: Text(
                                            'Blog: ${like['blog_title']}',
                                            style: TextStyle(
                                                color: AppColors.white)),
                                        subtitle: Text(
                                            'Beğenildi: ${like['liker']}',
                                            style: TextStyle(
                                                color: AppColors.white)),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ],
                            );
                          }
                        },
                      ),
                    ),
                    Container(
                      height: DeviceInfo.height * 0.4,
                      child: FutureBuilder<Map<String, dynamic>>(
                        future: userComments,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return Center(
                                child: Text('Hata: ${snapshot.error}',
                                    style: TextStyle(color: AppColors.white)));
                          } else if (!snapshot.hasData ||
                              snapshot.data!.isEmpty) {
                            return Center(
                                child: Text('Yorum bildirimi bulunamadı.',
                                    style: TextStyle(color: AppColors.white)));
                          } else {
                            final comments =
                                snapshot.data!['comments'] as List<dynamic>;
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: DeviceInfo.width * 0.04),
                                  child: Text(
                                    'Yorum Bildirimleri',
                                    style: TextStyle(
                                        color: AppColors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Expanded(
                                  child: ListView(
                                    shrinkWrap: true,
                                    children: comments.map<Widget>((comment) {
                                      return ListTile(
                                        title: Text(
                                            'Blog: ${comment['blog_title']}',
                                            style: TextStyle(
                                                color: AppColors.white)),
                                        subtitle: Text(
                                            'Yorum: ${comment['commenter']} - ${comment['comment_time']} - ${comment['comment_content']}',
                                            style: TextStyle(
                                                color: AppColors.white)),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ],
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
