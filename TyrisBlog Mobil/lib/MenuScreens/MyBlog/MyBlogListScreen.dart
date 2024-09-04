import 'package:flutter/material.dart';
import 'package:tyrisblog/ApiClasses/blogAPI.dart';
import 'package:tyrisblog/model/Blog.dart';
import 'package:tyrisblog/Const/DeviceInfo.dart';
import 'package:tyrisblog/Const/AppColors.dart';
import '../../CustomWidgets/MyBlogCard.dart';

class MyBlogListScreen extends StatefulWidget {
  final int userId;

  const MyBlogListScreen({super.key, required this.userId});

  @override
  State<MyBlogListScreen> createState() => _MyBlogListScreenState();
}

class _MyBlogListScreenState extends State<MyBlogListScreen> {
  late Future<List<Blog>> futureBlogs;

  @override
  void initState() {
    super.initState();
    _fetchBlogs();
  }

  Future<void> _fetchBlogs() async {
    var api = blogAPI();
    setState(() {
      futureBlogs = api.fetchBlogsByUser(widget.userId);
    });
  }

  Future<void> _refreshData() async {
    await _fetchBlogs();
  }

  @override
  Widget build(BuildContext context) {
    DeviceInfo.setDeviceInfo(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Yazılmış Yazılar',
          style: TextStyle(color: AppColors.white),
        ),
        backgroundColor: AppColors.DarkBlueLogo,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.white),
      ),
      backgroundColor: AppColors.DarkBlueLogo,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshData,
          child: FutureBuilder<List<Blog>>(
            future: futureBlogs,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(AppColors.Greenlogo),
                  ),
                );
              } else if (snapshot.hasError) {
                return Center(
                    child: Text('Bir hata oluştu: ${snapshot.error}',
                        style: TextStyle(color: AppColors.white)));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                    child: Text('Gösterilecek blog bulunamadı.',
                        style: TextStyle(color: AppColors.white)));
              } else {}
              {
                final blogs = snapshot.data!;
                return ListView.builder(
                  itemCount: blogs.length,
                  itemBuilder: (context, index) {
                    final blog = blogs[index];
                    return MyBlogCard(
                      blog: blog,
                      onBlogDeleted: () async {
                        var api = blogAPI();
                        setState(() {
                          _fetchBlogs();
                        });
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                MyBlogListScreen(userId: widget.userId),
                          ),
                        );
                      },
                    );
                  },
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
