import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:dio_demo/get_method.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const GetMethod(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Dio dio = Dio();
  Map<String, dynamic>? dataModel;
  String? mocData;
  String title = '',body = '',id = '',userId = '';

  Future postData() async {
    const String postUrl = 'https://jsonplaceholder.typicode.com/posts';
    dynamic data = {
      'title': 'hello flutter',
      'body': 'how are you',
      'userId': 3,
    };
    var response = await dio.post(postUrl,
        data: data,
        options: Options(headers: {
          'Content-type': 'application/json; charset=UTF-8',
        }));
      setState(() {
      mocData = response.toString();
    });
    return response.data;
  }

  Future decodeData() async {
    final Map parcedData = await json.decode(mocData!);
    print(parcedData['body']);
    setState(() {
      title = parcedData['title'];
      body = parcedData['body'];
      userId = parcedData['userId'].toString();
      id = parcedData['id'].toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(backgroundColor: Colors.black),
      body: Column(
        children: [
          MaterialButton(
            color: Colors.deepOrangeAccent,
            child: const Text(
              "Post",
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () async {
              print('posting data');
              await postData().then((value) {
                print(value);
              }).whenComplete(() async {
                await decodeData();
              });
            },
          ),
          Text('This is title $title , body is $body , the userId $userId'),
        ],
      ),
    );
  }
}
