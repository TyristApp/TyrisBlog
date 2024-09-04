import 'package:tyrisblog/Const/AppColors.dart';
import 'package:tyrisblog/Const/DeviceInfo.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../MenuScreens/BlogDetailScreen.dart';
import '../model/Blog.dart';

class BlogCard extends StatelessWidget {
  final Blog blog;

  const BlogCard({Key? key, required this.blog}) : super(key: key);

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
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BlogDetailScreen(
                blog: blog,
              ),
            ),
          );
        },
        child: Padding(
          padding: EdgeInsets.all(DeviceInfo.width * 0.02),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(DeviceInfo.width * 0.025),
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
    );
  }
}
