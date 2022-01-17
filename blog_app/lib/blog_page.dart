import 'package:blog_app/user.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'blog_post.dart';
import 'blog_scaffold.dart';
import 'constrained_center.dart';

class BlogPage extends StatelessWidget {
  final BlogPost post;

  const BlogPage({Key key, @required this.post}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    return BlogScaffold(
      children: [
        ConstrainedCentre(
          child: Column(
            children: [
              const SizedBox(height: 18),
              CircleAvatar(
                radius: 54,
                backgroundImage: NetworkImage(user.profilePicture),
              ),
              Text(
                user.name,
                style: Theme.of(context).textTheme.headline5,
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),
        SelectableText(post.title,
            style:
                Theme.of(context).textTheme.headline1?.copyWith(fontSize: 36)),
        const SizedBox(height: 20),
        // ignore: prefer_const_constructors
        SizedBox(height: 20),
        SelectableText(
          post.date,
          style: Theme.of(context).textTheme.caption,
        ),
        SelectableText(post.body),
      ],
    );
  }
}
