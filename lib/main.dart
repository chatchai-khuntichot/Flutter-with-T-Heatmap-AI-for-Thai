import 'dart:convert';
import 'package:http_parser/http_parser.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.teal,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  String _image;

  Future<void> getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    //source: ImageSource.gallery เป็นเมธอดนำภาพจาก gallery ใน mobile
    //source: ImageSource.camera เป็นเมธอดนำภาพจาก การถ่ายภาพ
    String url = "https://api.aiforthai.in.th/person/heat_detect/";
    //สามารถเรียกใช้บริการ Person Detection โดยเปลี่ยน url ด้านล่างนี้
    //String url = "https://api.aiforthai.in.th/person/human_detect/";


    final String key = "YOUR API KEY";
    //เพิ่ม Apikey ของ AI for Thai
    var postUri = Uri.parse(url);
    var request = new http.MultipartRequest("POST", postUri);
    request.headers["Content-type"] = "application/x-www-form-urlencoded";
    request.headers["apikey"] = key;
    request.fields["json_export"] = "true";
    request.fields["img_export"] = "true";
    request.files.add(await http.MultipartFile.fromPath(
      'src_img',
      image.absolute.path,
      contentType: new MediaType("image", "jpg"),
    ));

    request.send().then((result) async {
      http.Response.fromStream(result)
          .then((response) {
        if (response.statusCode == 200)
        {
          print("Uploaded! ");
          print('response.body '+response.body);
          var resimage = json.decode(response.body);
          var haetimage = resimage['heat_img'];
          setState(() {
            _image = haetimage;
          });
        }
      });
    }).catchError((err) => print('error : '+err.toString()))
        .whenComplete(()
    {});
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Heat Map with Flutter'),
      ),
      body: Center(
        child: _image == null
            ? Text('ไม่มีรูปภาพ')
            : Image.network(_image),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: getImage,
        tooltip: 'เพิ่มรูป',
        child: Icon(Icons.add_a_photo),
      ),
    );
  }
}