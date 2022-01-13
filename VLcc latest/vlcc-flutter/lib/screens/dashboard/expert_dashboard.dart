import 'package:flutter/material.dart';

class ExpertDashboard extends StatefulWidget {
  const ExpertDashboard({Key? key}) : super(key: key);

  @override
  _ExpertDashboardState createState() => _ExpertDashboardState();
}

class _ExpertDashboardState extends State<ExpertDashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text("expert dashboard"),
      ),
    );
  }
}
