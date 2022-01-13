import 'package:blog_app/home_page.dart';
import 'package:blog_app/user.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'blog_post.dart';

final theme = ThemeData(
  primarySwatch: Colors.blue,
  textTheme: const TextTheme(
    bodyText2: TextStyle(fontSize: 22, height: 1.4),
    caption: TextStyle(fontSize: 18, height: 1.4),
    headline1: TextStyle(
      fontSize: 45,
      fontWeight: FontWeight.w800,
      color: Colors.black,
    ),
    headline2: TextStyle(
      fontSize: 27,
      fontWeight: FontWeight.w700,
      color: Colors.black,
    ),
  ),
  appBarTheme: const AppBarTheme(
    color: Colors.transparent,
    elevation: 0,
    iconTheme: IconThemeData(color: Colors.black),
  ),
);

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    
    return MultiProvider(
      providers: [
        Provider<List<BlogPost>>(create: (context) => _blogPosts),
        Provider<User>(
            create: (context) => User(
                name: 'Vikas Tripathi',
                profilePicture: 'https://i.ibb.co/ZKkSW4H/profile-image.png')),
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        debugShowCheckedModeBanner: false,
        theme: theme,
        home: HomePage(),
      ),
    );
  }
}

final _blogPosts = [
  BlogPost(
    title: 'Kangan - Ranjit Bawa?',
    publishedDate: DateTime(2022, 1, 11),
    body:
        'Ranjit Bawa - Kangan | New Punjabi Songs 2018 | Full Video | Latest Punjabi Song 2018 | Jass RecordsSubscribe To Our Channel',
  ),
  BlogPost(
    title: 'SHEESHA : Pari Pandher?',
    publishedDate: DateTime(2022, 1, 11),
    body:
        'Brand B Presents Latest Punjabi Songs "SHEESHA" Sung By Pari Pandher Ft Jordan Sandhu, Penned Down & Composed By Bunty.',
  ),
];
