import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rte/flutter_rte.dart';
import 'package:image_picker/image_picker.dart';
import '../../ApiClasses/blogAPI.dart';
import '../../Const/AppColors.dart';
import '../../Const/DeviceInfo.dart';
import '../../CustomWidgets/CustomButton.dart';
import '../../CustomWidgets/InputText.dart';
import '../../MenuScreen.dart';

class CreateBlogScreen extends StatefulWidget {
  const CreateBlogScreen({super.key});

  @override
  _CreateBlogScreenState createState() => _CreateBlogScreenState();
}

class _CreateBlogScreenState extends State<CreateBlogScreen> {
  final TextEditingController _titleController = TextEditingController();
  final HtmlEditorController cont = HtmlEditorController();
  String url = "";

  File? _image;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _pickImagetoHtml() async {

    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      var api = blogAPI();
      String? url = await api.uploadImage(File(pickedFile.path));

      if (url != null) {

        String html = "<br><img src=\"${"http://10.0.2.2:8000/"+url}\" style=\"max-width: ${DeviceInfo.width}px; height: auto;\" />";

        cont.setText(cont.content + html);
      } else {
        print('Resim yükleme başarısız.');
      }
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Blog Oluştur', style: TextStyle(color: AppColors.white)),
        backgroundColor: AppColors.DarkBlueLogo,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.white),
        toolbarHeight: DeviceInfo.height * 0.1,
      ),
      backgroundColor: AppColors.SoftBeige,
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: DeviceInfo.width * 0.05,
          vertical: DeviceInfo.height * 0.03,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Başlık',
              style: TextStyle(
                color: AppColors.DarkBlueLogo,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: DeviceInfo.height * 0.01),

            InputText(
              placeholder: "Başlık",
              controller: _titleController,
              hintColor: AppColors.SoftGray,
              borderColor: AppColors.SoftGray,
            ),
            SizedBox(height: DeviceInfo.height * 0.02),

            Text(
              'İçerik',
              style: TextStyle(
                color: AppColors.DarkBlueLogo,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: DeviceInfo.height * 0.01),
            CustomButton(text: "Resim Ekle",
                color: AppColors.secondgreen,
                onPressed: (){
                  _pickImagetoHtml();
                },
                width: DeviceInfo.width / 4),

            Container(
              child: HtmlEditor(controller: cont,
                hint: "İçerik girin...",
                height: DeviceInfo.height /  2,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(color: Colors.grey),
              ),
            ),
            SizedBox(height: DeviceInfo.height * 0.02),

            Text(
              'Kapak Resmi',
              style: TextStyle(
                color: AppColors.DarkBlueLogo,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: DeviceInfo.height * 0.01),

            GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: double.infinity,
                height: DeviceInfo.height * 0.2,
                decoration: BoxDecoration(
                  color: AppColors.SoftGray.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: _image == null
                    ? Center(child: Text('Resim Seçin', style: TextStyle(color: AppColors.DarkBlueLogo)))
                    : Image.file(_image!, fit: BoxFit.cover),
              ),
            ),
            SizedBox(height: DeviceInfo.height * 0.02),

            Center(
              child: CustomButton(
                text: "Yayınla",
                color: AppColors.Greenlogo,
                onPressed: () async {
                  var api = blogAPI();
                  await api.saveblog(_titleController.text, cont.content, _image);

                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => MenuScreen()),
                  );
                },
                width: DeviceInfo.width * 0.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
