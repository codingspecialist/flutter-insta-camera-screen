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
    print("?????? ????????? ??????????????? ?????????????????????.");

    setState(() {
      // ?????? ????????? ?????? ???????????? ???????????? ????????? ????????? ?????? ??????????????? ????????? ?????? ?????????!!
      mainImageFile = pickFile.path;
    });
  }

  Future getPickImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);

        print("????????? ????????? ?????? : ${_image!.path}");
        _fileNameMemSave(_image!.path);
      } else {
        print('No image selected.');
      }
    });
  }

  _fileNameMemSave(String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print("????????? ?????? prefs??? ?????? : ${value}");
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
    print("????????? ???????????? : ${files.first}");
    try {
      return files;
    } catch (e) {
      throw "?????? ?????? ??????";
    }
  }
}
