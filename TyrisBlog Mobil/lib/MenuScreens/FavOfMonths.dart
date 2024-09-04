import 'package:flutter/material.dart';
import '../ApiClasses/blogAPI.dart';
import '../CustomWidgets/BlogCard.dart';
import '../model/Blog.dart';
import '../Const/AppColors.dart';
import 'package:flutter/services.dart';

import '../Const/DeviceInfo.dart';

class Favofmonths extends StatefulWidget {
  const Favofmonths({super.key});

  @override
  State<Favofmonths> createState() => _FavofmonthsState();
}

class _FavofmonthsState extends State<Favofmonths> {
  late Future<List<Blog>> _favoriteBlogs;

  @override
  void initState() {
    super.initState();
    _fetchFavoriteBlogs();
  }

  Future<void> _fetchFavoriteBlogs() async {
    var api = blogAPI();
    setState(() {
      _favoriteBlogs = api.fetchFavoriteBlogsOfMonth();
    });
  }

  @override
  Widget build(BuildContext context) {
    DeviceInfo.setDeviceInfo(context);

    return Scaffold(
      backgroundColor: AppColors.DarkBlueLogo,
      appBar: AppBar(
        title:
            Text('Ayın Favorileri', style: TextStyle(color: AppColors.white)),
        backgroundColor: AppColors.DarkBlueLogo,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.white),
      ),
      body: SafeArea(
        child: FutureBuilder<List<Blog>>(
          future: _favoriteBlogs,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                  child: Text('Bir hata oluştu: ${snapshot.error}',
                      style: TextStyle(color: AppColors.white)));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                  child: Text('Bu ay için favori blog bulunamadı.',
                      style: TextStyle(color: AppColors.white)));
            } else {
              final blogs = snapshot.data!;
              return ListView.builder(
                itemCount: blogs.length,
                itemBuilder: (context, index) {
                  final blog = blogs[index];
                  return BlogCard(blog: blog);
                },
              );
            }
          },
        ),
      ),
    );
  }
}
