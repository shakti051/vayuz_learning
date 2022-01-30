import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class GetMethod extends StatefulWidget {
  const GetMethod({Key? key}) : super(key: key);
  @override
  _GetMethodState createState() => _GetMethodState();
}

class _GetMethodState extends State<GetMethod> {
  Dio dio = Dio();

  Future getData() async {
    final String pathUrl = 'https://jsonplaceholder.typicode.com/posts/';

    dio.interceptors.add(InterceptorsWrapper(onRequest:
        (RequestOptions options, RequestInterceptorHandler handlers) async {
      var header = {
        'Content-type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
        
      };
      options.headers.addAll(header);
      return handlers.next(options);
    }));

    Response response = await dio.get(pathUrl);
    return response.data;
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
              "Get Data",
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () async {
              print('getting data');
              await getData().then((value) {
                print(value);
              });
            },
          ),
        ],
      ),
    );
  }
}
