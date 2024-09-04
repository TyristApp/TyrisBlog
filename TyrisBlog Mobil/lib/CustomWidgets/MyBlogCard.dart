import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../MenuScreens/BlogDetailScreen.dart';
import '../model/Blog.dart';
import '../ApiClasses/blogAPI.dart';
import '../Const/AppColors.dart';
import '../Const/DeviceInfo.dart';

class MyBlogCard extends StatelessWidget {
  final Blog blog;
  final VoidCallback onBlogDeleted;

  const MyBlogCard({Key? key, required this.blog, required this.onBlogDeleted})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: AppColors.DarkBlueLogo,
        statusBarIconBrightness: Brightness.light,
      ),
    );
    DeviceInfo.setDeviceInfo(context);

    return Card(
      color: AppColors.Greenlogo,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DeviceInfo.width * 0.025),
      ),
      margin: EdgeInsets.symmetric(
        vertical: DeviceInfo.height * 0.01,
        horizontal: DeviceInfo.width * 0.04,
      ),
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BlogDetailScreen(blog: blog),
                  ),
                );
              },
              child: Padding(
                padding: EdgeInsets.all(DeviceInfo.width * 0.02),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius:
                          BorderRadius.circular(DeviceInfo.width * 0.025),
                      child: blog.imageUrl.isNotEmpty
                          ? Image.network(
                              "http://10.0.2.2:8000" + blog.imageUrl,
                              width: DeviceInfo.width * 0.2,
                              height: DeviceInfo.height * 0.1,
                              fit: BoxFit.cover,
                            )
                          : Image.asset(
                              'assets/images/tyristapp.jpg',
                              width: DeviceInfo.width * 0.2,
                              height: DeviceInfo.height * 0.1,
                              fit: BoxFit.cover,
                            ),
                    ),
                    SizedBox(width: DeviceInfo.width * 0.03),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            blog.title,
                            style: TextStyle(
                              color: AppColors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: DeviceInfo.width * 0.06,
                              fontFamily: "Poppins",
                            ),
                          ),
                          SizedBox(height: DeviceInfo.height * 0.005),
                          Text(
                            "Yazar: ${blog.author}",
                            style: TextStyle(
                              fontSize: DeviceInfo.width * 0.05,
                              color: AppColors.LightBlue,
                              fontWeight: FontWeight.bold,
                              fontFamily: "Poppins",
                            ),
                          ),
                          SizedBox(height: DeviceInfo.height * 0.005),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: Text(
                              '${blog.dateTime.day}/${blog.dateTime.month}/${blog.dateTime.year} ${blog.dateTime.hour}:${blog.dateTime.minute}',
                              style: TextStyle(
                                fontSize: DeviceInfo.width * 0.04,
                                color: AppColors.DarkBlueLogo,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            color: Colors.red,
            width: DeviceInfo.width * 0.2,
            child: IconButton(
              icon: Icon(Icons.delete, color: Colors.white),
              onPressed: () async {
                _showDeleteDialog(context, 5);
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, int blogId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Blog Silme'),
          content: const Text('Bu blogu silmek istediğinizden emin misiniz?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Hayır'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Evet'),
              onPressed: () async {
                Navigator.of(context).pop();
                await _deleteBlog(blog.blogid);
                onBlogDeleted();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteBlog(int blogId) async {
    var api = blogAPI();
    api.deleteBlog(blogId);
  }
}
