import 'package:tyrisblog/ApiClasses/blogAPI.dart';
import 'package:flutter/material.dart';
import '../model/Blog.dart';
import '../model/Comment.dart';
import '../Const/AppColors.dart';
import '../Const/DeviceInfo.dart';
import 'package:webview_flutter/webview_flutter.dart';

class BlogDetailScreen extends StatefulWidget {
  final Blog blog;

  const BlogDetailScreen({super.key, required this.blog});

  @override
  _BlogDetailScreenState createState() => _BlogDetailScreenState();
}

class _BlogDetailScreenState extends State<BlogDetailScreen> {
  bool _isLiked = false;
  int _likeCount = 0;
  final TextEditingController commentController = TextEditingController();
  late Future<List<Comment>> _commentsFuture;

  WebViewController controller = WebViewController();

  @override
  void initState() {
    super.initState();
    _commentsFuture = fetchComments(widget.blog.blogid);
    _loadLikeStatus();
    controller.loadHtmlString(
        "<meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">" +
            widget.blog.content);
  }

  Future<List<Comment>> fetchComments(int blogId) async {
    var api = blogAPI();
    return await api.fetchComments(blogId);
  }

  Future<void> _loadLikeStatus() async {
    try {
      var api = blogAPI();
      final status = await api.getBlogLikeStatus(widget.blog.blogid);
      setState(() {
        _isLiked = status['user_liked'];
        _likeCount = status['total_likes'];
      });
    } catch (e) {
      print('Error loading like status: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    DeviceInfo.setDeviceInfo(context);

    return Scaffold(
      backgroundColor: AppColors.DarkBlueLogo,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(DeviceInfo.width * 0.04),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.blog.imageUrl.isNotEmpty)
                    ClipRRect(
                      borderRadius:
                          BorderRadius.circular(DeviceInfo.width * 0.03),
                      child: Image.network(
                        "http://10.0.2.2:8000" + widget.blog.imageUrl,
                        width: double.infinity,
                        height: DeviceInfo.height * 0.25,
                        fit: BoxFit.cover,
                      ),
                    ),
                  SizedBox(height: DeviceInfo.height * 0.02),
                  Text(
                    widget.blog.title,
                    style: TextStyle(
                      fontSize: DeviceInfo.width * 0.07,
                      fontWeight: FontWeight.bold,
                      color: AppColors.SoftBeige,
                    ),
                  ),
                  SizedBox(height: DeviceInfo.height * 0.01),
                  Text(
                    'Yazar: ${widget.blog.author}',
                    style: TextStyle(
                      fontSize: DeviceInfo.width * 0.045,
                      color: AppColors.Greenlogo,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: DeviceInfo.height * 0.01),

                  Text(
                    'Tarih: ${widget.blog.dateTime.day}/${widget.blog.dateTime.month}/${widget.blog.dateTime.year} ${widget.blog.dateTime.hour}:${widget.blog.dateTime.minute}',
                    style: TextStyle(
                      fontSize: DeviceInfo.width * 0.045,
                      color: AppColors.SoftGray,
                    ),
                  ),
                  SizedBox(height: DeviceInfo.height * 0.02),
                  Container(
                    height: DeviceInfo.height / 2,
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                        horizontal: DeviceInfo.width * 0.03,
                        vertical: DeviceInfo.width * 0.04),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius:
                          BorderRadius.circular(DeviceInfo.width * 0.03),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.SoftGray.withOpacity(0.5),
                          blurRadius: DeviceInfo.width * 0.02,
                          offset: Offset(0, DeviceInfo.height * 0.005),
                        ),
                      ],
                    ),
                    child: WebViewWidget(controller: controller),
                  ),

                  SizedBox(height: DeviceInfo.height * 0.2),
                  Text(
                    "Yorumlar",
                    style: TextStyle(color: AppColors.white, fontSize: 25),
                  ),
                  // COMMENTS
                  FutureBuilder<List<Comment>>(
                    future: _commentsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(
                            child: Text("HATA",
                                style: TextStyle(color: AppColors.white)));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(
                            child: Text('Henüz yorum yapılmamış.',
                                style: TextStyle(color: AppColors.white)));
                      } else {
                        return Column(
                          children: snapshot.data!.map((comment) {
                            return Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: DeviceInfo.height * 0.01),
                              child: Container(
                                padding:
                                    EdgeInsets.all(DeviceInfo.width * 0.03),
                                decoration: BoxDecoration(
                                  color: AppColors.PastBlack,
                                  borderRadius: BorderRadius.circular(
                                      DeviceInfo.width * 0.03),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          AppColors.SoftGray.withOpacity(0.5),
                                      blurRadius: DeviceInfo.width * 0.02,
                                      offset:
                                          Offset(0, DeviceInfo.height * 0.005),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          comment.username,
                                          style: TextStyle(
                                            color: AppColors.SoftBeige,
                                            fontWeight: FontWeight.bold,
                                            fontSize: DeviceInfo.width * 0.045,
                                          ),
                                        ),
                                        Text(
                                          '${comment.commentTime.day}/${comment.commentTime.month}/${comment.commentTime.year}',
                                          // Yorum tarihi
                                          style: TextStyle(
                                            color: AppColors.SoftGray,
                                            fontSize: DeviceInfo.width * 0.04,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: DeviceInfo.height * 0.01),
                                    Text(
                                      comment.commentContent,
                                      style: TextStyle(
                                        color: AppColors.white,
                                        fontSize: DeviceInfo.width * 0.04,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(DeviceInfo.width * 0.04), // Padding
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: commentController,
                    decoration: InputDecoration(
                      hintText: "Yorumunuzu buraya yazın...",
                      hintStyle: TextStyle(color: AppColors.SoftGray),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                            DeviceInfo.width * 0.03), // Border radius
                        borderSide: BorderSide(
                            color: AppColors.SoftGray), // Border rengi
                      ),
                      contentPadding:
                          EdgeInsets.all(DeviceInfo.width * 0.03), // Padding
                    ),
                    style: TextStyle(color: AppColors.white),
                    maxLines: 1,
                    minLines: 1,
                  ),
                ),
                SizedBox(width: DeviceInfo.width * 0.02),
                ElevatedButton(
                  onPressed: () async {
                    var api = blogAPI();
                    await api.commentOnBlog(
                        widget.blog.blogid, commentController.text);
                    setState(() {
                      _commentsFuture = fetchComments(widget.blog.blogid);
                      commentController.clear();
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.Greenlogo,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(DeviceInfo.width * 0.03),
                    ),
                    padding: EdgeInsets.symmetric(
                        horizontal: DeviceInfo.width * 0.05,
                        vertical: DeviceInfo.height * 0.015),
                  ),
                  child: Text(
                    "Yorum Yap",
                    style: TextStyle(color: AppColors.white),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(DeviceInfo.width * 0.04), // Padding
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(
                    _isLiked ? Icons.favorite : Icons.favorite_border,
                    color: _isLiked ? AppColors.Greenlogo : AppColors.white,
                  ),
                  onPressed: () {
                    var api = blogAPI();
                    setState(() {
                      if (_isLiked) {
                        api.likeBlog(widget.blog.blogid, false);
                        _isLiked = !_isLiked;
                        _likeCount -= 1;
                      } else {
                        api.likeBlog(widget.blog.blogid, true);
                        _isLiked = !_isLiked;
                        _likeCount += 1;
                      }
                    });
                  },
                ),
                SizedBox(width: DeviceInfo.width * 0.02),
                Text(
                  '$_likeCount Beğeni',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: DeviceInfo.width * 0.04,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
