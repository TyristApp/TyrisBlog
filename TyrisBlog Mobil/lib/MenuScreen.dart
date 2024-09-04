import 'package:tyrisblog/MenuScreens/BlogListScreen.dart';
import 'package:tyrisblog/MenuScreens/FavOfMonths.dart';
import 'package:tyrisblog/MenuScreens/MyBlog/MyBlogsScreen.dart';
import 'package:tyrisblog/MenuScreens/SettingsScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../Const/AppColors.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: AppColors.DarkBlueLogo,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    // Menü items
    final List<Widget> _pages = [
      Center(child: BloglistScreen()),
      Center(child: MyBlogScreen()),
      Center(child: SettingsScreen()),
      Center(child: Favofmonths()),
    ];

    return Scaffold(
      body: SafeArea(child: _pages[_selectedIndex]),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Blog Keşfet',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.border_color_outlined),
            label: 'Benim Bloğum',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Ayarlar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'En Sevilenler',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: AppColors.Greenlogo,
        unselectedItemColor: AppColors.SoftGray,
        backgroundColor: AppColors.DarkBlueLogo,
        onTap: _onItemTapped,
        selectedLabelStyle: TextStyle(
          color: AppColors.Greenlogo,
        ),
        unselectedLabelStyle: TextStyle(
          color: AppColors.SoftGray,
        ),
        type: BottomNavigationBarType.fixed, // fix menu
      ),
    );
  }
}
