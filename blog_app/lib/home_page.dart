import 'package:blog_app/user.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'blog_page.dart';
import 'blog_post.dart';
import 'blog_scaffold.dart';
import 'constrained_center.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    final posts = Provider.of<List<BlogPost>>(context);
    return BlogScaffold(
      children: [
        ConstrainedCentre(
          child: CircleAvatar(
            backgroundImage: NetworkImage(user.profilePicture),
            radius: 72,
          ),
        ),
        const SizedBox(height: 18),
        ConstrainedCentre(
          child: SelectableText(
            user.name,
            style: Theme.of(context).textTheme.headline1,
          ),
        ),
        const SizedBox(height: 40),
        SelectableText(
          'Hello, I’m a human. I’m a Flutter developer and an avid human. Occasionally, I nap.',
          style: Theme.of(context).textTheme.bodyText2,
        ),
        const SizedBox(height: 40),
        SelectableText(
          'Meta Data',
          style: Theme.of(context).textTheme.headline2,
        ),
        for (var post in posts) BlogListTile(post: post),
      SizedBox(height: 50)
      ],
    );
  }
}

class BlogListTile extends StatelessWidget {
  final BlogPost post;
  BlogListTile({this.post});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        InkWell(
          child: Text(
            post.title,
            style: TextStyle(color: Colors.blueAccent.shade700),
          ),
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) {
                return BlogPage(post: post);
              },
            ));
          },
        ),
      const SizedBox(height: 10),
        SelectableText(
          post.date,
          style: Theme.of(context).textTheme.caption,
        ),
      ],
    );
  }
}