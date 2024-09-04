import 'package:flutter/material.dart';
import '../Const/AppColors.dart';
import '../Const/DeviceInfo.dart';
import '../CustomWidgets/CustomButton.dart';
import '../ApiClasses/userAPI.dart';
import '../LoginScreens/MainMenuScreen.dart';
import '../model/User.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isEmailExpanded = false;
  bool _isPasswordExpanded = false;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  void _toggleExpand(String option) {
    setState(() {
      if (option == 'email') {
        _isEmailExpanded = !_isEmailExpanded;
        _isPasswordExpanded = false;
      } else if (option == 'password') {
        _isPasswordExpanded = !_isPasswordExpanded;
        _isEmailExpanded = false;
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    DeviceInfo.setDeviceInfo(context);

    return Scaffold(
      backgroundColor: AppColors.DarkBlueLogo,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(DeviceInfo.width * 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // E-mail change
              _buildExpandableOption(
                title: 'E-mail Değiştir',
                isExpanded: _isEmailExpanded,
                onTap: () => _toggleExpand('email'),
                child: _buildEmailChangeForm(),
              ),
              Divider(color: AppColors.SoftGray),
              // pass update
              _buildExpandableOption(
                title: 'Şifre Güncelle',
                isExpanded: _isPasswordExpanded,
                onTap: () => _toggleExpand('password'),
                child: _buildPasswordUpdateForm(),
              ),
              Divider(color: AppColors.SoftGray),
              SizedBox(height: DeviceInfo.height * 0.02),
              // sign out
              CustomButton(
                text: 'Çıkış Yap',
                color: AppColors.secondred,
                onPressed: () {
                  var api = UserApi();
                  api.logout();

                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => MainMenuScreen()),

                    (route) => false, // clear past screens
                  );
                },
                width: DeviceInfo.width * 0.9,
              ),
              SizedBox(height: DeviceInfo.height * 0.02),
              // delete account
              CustomButton(
                text: 'Hesap Sil',
                color: AppColors.secondred,
                onPressed: () async {
                  var api = UserApi();
                  User? user = await api.getUser();

                  if (user != null) {
                    showDeleteAccountDialog(context, () async {
                      String userId = 'user_id';
                      String result = await api.deleteUser(user.id);

                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                            builder: (context) => MainMenuScreen()),
                        (route) => false,
                      );
                    });
                  }
                },
                width: DeviceInfo.width * 0.9,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExpandableOption({
    required String title,
    required bool isExpanded,
    required VoidCallback onTap,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          title: Text(
            title,
            style: TextStyle(color: AppColors.white),
          ),
          trailing: Icon(
            isExpanded ? Icons.expand_less : Icons.expand_more,
            color: AppColors.white,
          ),
          onTap: onTap,
        ),
        if (isExpanded) child,
      ],
    );
  }

  Widget _buildEmailChangeForm() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: DeviceInfo.width * 0.05),
      child: Column(
        children: [
          SizedBox(height: DeviceInfo.height / 30),
          TextField(
            controller: _emailController, // Controller ekleyin
            style: TextStyle(color: AppColors.white),
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.SoftGray.withOpacity(0.3),
              hintText: 'Yeni E-mail',
              hintStyle: TextStyle(color: AppColors.white),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(DeviceInfo.width * 0.025),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          SizedBox(height: DeviceInfo.height * 0.02),
          ElevatedButton(
              onPressed: () async {
                var api = UserApi();
                String newEmail = _emailController.text;

                try {
                  User? user = await api.getUser();
                  if (user != null) {
                    await api.updateEmail(user.id, newEmail);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('E-mail başarıyla güncellendi')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Kullanıcı bilgileri bulunamadı')),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Bir hata oluştu: $e')),
                  );
                }
                _emailController.clear();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.LightBlue,
              ),
              child: Text(
                'E-mail Güncelle',
                style: TextStyle(color: AppColors.white),
              )),
        ],
      ),
    );
  }

  Widget _buildPasswordUpdateForm() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: DeviceInfo.width * 0.05),
      child: Column(
        children: [
          SizedBox(height: DeviceInfo.height / 30),
          TextField(
            controller: _oldPasswordController,
            style: TextStyle(color: AppColors.white),
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.SoftGray.withOpacity(0.3),
              hintText: 'Eski Şifre',
              hintStyle: TextStyle(color: AppColors.white),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(DeviceInfo.width * 0.025),
                borderSide: BorderSide.none,
              ),
            ),
            obscureText: true,
          ),
          SizedBox(height: DeviceInfo.height * 0.02),
          TextField(
            controller: _newPasswordController,
            style: TextStyle(color: AppColors.white),
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.SoftGray.withOpacity(0.3),
              hintText: 'Yeni Şifre',
              hintStyle: TextStyle(color: AppColors.white),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(DeviceInfo.width * 0.025),
                borderSide: BorderSide.none,
              ),
            ),
            obscureText: true,
          ),
          SizedBox(height: DeviceInfo.height * 0.02),
          TextField(
            controller: _confirmPasswordController,
            style: TextStyle(color: AppColors.white),
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.SoftGray.withOpacity(0.3),
              hintText: 'Yeni Şifre Tekrar',
              hintStyle: TextStyle(color: AppColors.white),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(DeviceInfo.width * 0.025),
                borderSide: BorderSide.none,
              ),
            ),
            obscureText: true,
          ),
          SizedBox(height: DeviceInfo.height * 0.02),
          ElevatedButton(
            onPressed: () async {
              var api = UserApi();
              String oldPassword = _oldPasswordController.text;
              String newPassword = _newPasswordController.text;
              String confirmPassword = _confirmPasswordController.text;
              if (newPassword == confirmPassword) {
                User? user = await api.getUser();
                if (user != null) {
                  api.updatePassword(oldPassword, newPassword, user.id);
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Şifreler eşleşmiyor')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.LightBlue,
            ),
            child: Text(
              'Şifre Güncelle',
              style: TextStyle(color: AppColors.white),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> showDeleteAccountDialog(
      BuildContext context, VoidCallback onConfirm) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Hesap Silme Onayı'),
          content: Text(
            'Hesap silmek istediğinize emin misiniz? Yazdığınız tüm bloglar, yorumlar ve beğenileriniz silinecektir.',
          ),
          actions: <Widget>[
            TextButton(
              child: Text('İptal'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Sil'),
              onPressed: () {
                Navigator.of(context).pop();
                onConfirm();
              },
            ),
          ],
        );
      },
    );
  }
}
