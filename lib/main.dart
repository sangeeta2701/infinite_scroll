import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Infinite Scrolling',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool loading = false;
  final ScrollController _scrollController = ScrollController();
  List urlData = [];
  void getApiData() async {
    loading = true;
    var url = Uri.parse(
        "https://api.unsplash.com/photos/?per_page=10&client_id=x-zuRHTNXRklv9mEMnp90i3U2cY586y0SZrOAJbBJkw");
    final response = await http.get(url);

    setState(() {
      urlData = jsonDecode(response.body);
      loading = false;
    });
  }

  @override
  void initState() {
    getApiData();
    super.initState();

    _scrollController.addListener(() async {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent) {
        print(urlData);
        // CircularProgressIndicator();
        try {
          loading = true;
          var url = Uri.parse(
              "https://api.unsplash.com/photos/?per_page=10&client_id=x-zuRHTNXRklv9mEMnp90i3U2cY586y0SZrOAJbBJkw");
          final response = await http.get(url);
          if (response.statusCode == 200) {
            var list = [];

            setState(() {
              list = jsonDecode(response.body).toList();
              urlData.addAll(list);
              loading = false;
            });
          }
        } catch (e) {
          print(e);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Infinite Scrolling'),
      ),
      body: Center(
        child: Container(
          height: 400,
          width: double.infinity,
          child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                mainAxisSpacing: 6,
                crossAxisCount: 2,
                crossAxisSpacing: 6,
              ),
              controller: _scrollController,
              itemCount: urlData.length,
              itemBuilder: (context, i) {
                return InkWell(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => FullImageView(
                                  url: urlData[i]['urls']['full'],
                                )));
                  },
                  child: Hero(
                    tag: 'full',
                    child: Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(urlData[i]['urls']['full']),
                        ),
                      ),
                    ),
                  ),
                );
              }),
        ),
      ),
    );
  }
}

class FullImageView extends StatelessWidget {
  var url;
  FullImageView({this.url});
  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'full',
      child: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
          image: NetworkImage(url),
          fit: BoxFit.cover,
        )),
      ),
    );
  }
}
