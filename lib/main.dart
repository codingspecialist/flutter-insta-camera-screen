import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Instagram Camera Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Insta(),
    );
  }
}

class Insta extends StatefulWidget {
  @override
  _InstaState createState() => _InstaState();
}

class _InstaState extends State<Insta> {
  File? _image;
  final picker = ImagePicker();
  List<String> _picImageNames = [];
  String? mainImageFile;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SizedBox(
                width: double.infinity,
                child: mainImageFile != null
                    ? Image.file(File(mainImageFile!))
                    : FlutterLogo(),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: IconButton(
                      iconSize: 40,
                      onPressed: () {
                        _takePhoto();
                      },
                      icon: Icon(Icons.camera_alt_outlined)),
                ),
                Expanded(
                  child: IconButton(
                      iconSize: 40,
                      onPressed: () {
                        getPickImage();
                      },
                      icon: Icon(Icons.picture_in_picture_alt)),
                ),
              ],
            ),
            Expanded(
              child: FutureBuilder<List<File>>(
                  future: getFileImages(),
                  builder: (context, snapshot) {
                    return GridView.count(
                      crossAxisCount: 3,
                      children: snapshot.hasData
                          ? snapshot.data!
                              .map((e) => Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Image.file(e),
                                  ))
                              .toList()
                          : [],
                    );
                  }),
            )
          ],
        ),
      ),
    );
  }

  void _takePhoto() async {
    PickedFile? pickFile =
        await ImagePicker().getImage(source: ImageSource.camera);

    await GallerySaver.saveImage(pickFile!.path);
    print("사진 촬영이 완료되었고 저장되었습니다.");

    setState(() {
      // 파일 객체를 바로 추가하고 싶었는데 그렇게 하니까 자꾸 에러가나서 아래와 같이 경로만!!
      mainImageFile = pickFile.path;
    });
  }

  Future getPickImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);

        print("선택된 이미지 경로 : ${_image!.path}");
        _fileNameMemSave(_image!.path);
      } else {
        print('No image selected.');
      }
    });
  }

  _fileNameMemSave(String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print("이미지 경로 prefs에 저장 : ${value}");
    setState(() {
      _picImageNames = [..._picImageNames, "$value"];
      print(_picImageNames.toString());
    });
    await prefs.setStringList('picked', _picImageNames);
  }

  Future<List<String>> _fileNameMemSelect() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getStringList("picked")!;
  }

  Future<List<File>> getFileImages() async {
    List<String> imageFileList = await _fileNameMemSelect();
    List<File> files = imageFileList.map((e) => File("$e")).toList();
    print("가져올 이미지들 : ${files.first}");
    try {
      return files;
    } catch (e) {
      throw "파일 읽기 실패";
    }
  }
}
