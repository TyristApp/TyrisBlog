import 'dart:async';
import 'package:tyrisblog/Const/AppColors.dart';
import 'package:flutter/material.dart';
import '../ApiClasses/blogAPI.dart';
import '../CustomWidgets/BlogCard.dart';
import '../model/Blog.dart';
import '../Const/DeviceInfo.dart';

class BloglistScreen extends StatefulWidget {
  const BloglistScreen({super.key});

  @override
  State<BloglistScreen> createState() => _BloglistScreenState();
}

class _BloglistScreenState extends State<BloglistScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Blog> _blogs = [];
  int _currentPage = 1;
  bool _isLoading = false;
  bool _hasMore = true;
  String _searchTerm = '';
  final StreamController<List<Blog>> _blogStreamController =
      StreamController<List<Blog>>();

  @override
  void initState() {
    super.initState();
    _fetchBlogs();
    _searchController.addListener(_performSearch);
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      if (!_isLoading && _hasMore) {
        _loadMoreBlogs();
      }
    }
  }

  Future<void> _fetchBlogs() async {
    var api = blogAPI();
    setState(() {
      _isLoading = true;
    });
    try {
      final blogs =
          await api.fetchBlogsByTitle(_searchTerm, page: _currentPage);
      setState(() {
        _blogs.clear();
        _blogs.addAll(blogs);
        _blogStreamController.add(_blogs);
        _isLoading = false;
        _hasMore = blogs.isNotEmpty;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _performSearch() async {
    setState(() {
      _searchTerm = _searchController.text;
      _currentPage = 1;
      _fetchBlogs();
    });
  }

  Future<void> _loadMoreBlogs() async {
    var api = blogAPI();
    if (_isLoading || !_hasMore) return;

    setState(() {
      _isLoading = true;
      _currentPage++;
    });

    try {
      final newBlogs =
          await api.fetchBlogsByTitle(_searchTerm, page: _currentPage);
      if (newBlogs.isEmpty) {
        setState(() {
          _hasMore = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _blogs.addAll(newBlogs);
          _blogStreamController.add(_blogs);
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _blogStreamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    DeviceInfo.setDeviceInfo(context);

    return Scaffold(
      backgroundColor: AppColors.DarkBlueLogo,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _fetchBlogs,
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  vertical: DeviceInfo.height * 0.01,
                  horizontal: DeviceInfo.width * 0.04,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        style: TextStyle(color: AppColors.white),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: AppColors.SoftGray.withOpacity(0.3),
                          hintText: 'Blog ara...',
                          hintStyle: TextStyle(color: AppColors.white),
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(DeviceInfo.width * 0.025),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onChanged: (text) {
                          setState(() {
                            _performSearch();
                          });
                        },
                      ),
                    ),
                    SizedBox(width: DeviceInfo.width * 0.02),
                    IconButton(
                      icon: Icon(Icons.search, color: AppColors.white),
                      onPressed: _performSearch,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: StreamBuilder<List<Blog>>(
                  stream: _blogStreamController.stream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(
                          child: Text('Bir hata oluştu: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(
                          child: Text('Gösterilecek blog bulunamadı.'));
                    } else {
                      final blogs = snapshot.data!;
                      return ListView.builder(
                        controller: _scrollController,
                        itemCount: blogs.length + (_isLoading ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index < blogs.length) {
                            final blog = blogs[index];
                            return BlogCard(blog: blog);
                          } else {
                            return Center(child: CircularProgressIndicator());
                          }
                        },
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
