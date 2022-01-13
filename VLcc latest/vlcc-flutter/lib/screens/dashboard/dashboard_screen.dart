import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:vlcc/database/db_helper.dart';
import 'package:vlcc/providers/shared_pref.dart';
import 'package:vlcc/resources/app_colors.dart';
import 'package:vlcc/resources/assets_path.dart';
import 'package:vlcc/resources/dimensions.dart';
import 'package:vlcc/screens/packages/package_provider.dart';
import 'package:vlcc/screens/packages/package_routes.dart';
import 'package:vlcc/widgets/dashboard_widgets/dashboard_widgets.dart';

class DashboardScreen extends StatefulWidget {
  final String title;
  final Color titleColor;

  const DashboardScreen({
    Key? key,
    required this.title,
    this.titleColor = Colors.black,
  }) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final PackageProvider _packageProvider = PackageProvider();
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final DashboardProvider _dashboardProvider = DashboardProvider();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    apiCall();
  }

  Future<void> apiCall() async {
    await _packageProvider.getPackageModelData();
    await _packageProvider.getCashInvoice();
    _databaseHelper.getUniqueSpeciality();
    await _dashboardProvider.getAppointmentList();
    _dashboardProvider.getProfileDetails();
    await _dashboardProvider.getGeneralAppointmentList();
  }

  @override
  Widget build(BuildContext context) {
    final _sharedPrefs = context.watch<VlccShared>();
    final _packageProvider = context.watch<PackageProvider>();
    final dashboardProvider = context.watch<DashboardProvider>();
    final databaseHelper = context.watch<DatabaseHelper>();
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        elevation: 0,
        centerTitle: false,
        title: Text(
          widget.title,
          textAlign: TextAlign.left,
          style: TextStyle(
              color: widget.titleColor,
              fontWeight: FontWeight.w700,
              fontSize: FontSize.heading),
        ),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.pushNamed(context, PackageRoutes.notifications);
              },
              icon:
                  SvgPicture.asset(SVGAsset.notification, color: Colors.black)),
          InkWell(
            onTap: showMenuDialog,
            child: CircleAvatar(
              backgroundImage: Image.asset(PNGAsset.avatar).image,
              foregroundImage: NetworkImage(_sharedPrefs.profileImage),
            ),
          ),
          SizedBox(width: 16)
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          key: _refreshIndicatorKey,
          onRefresh: () async {
            apiCall();
          },
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 26),
                DashboardSlider(),
                Visibility(
                  visible: _packageProvider.inActivePackages.isNotEmpty,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: ViewPackages(),
                  ),
                ),
                SizedBox(height: 20),
                UpcomingAppointment(),
                SizedBox(height: 26),
                VideoConsultation(),
                SizedBox(height: 26),
              ],
            ),
          ),
        ),
      ),
    );
  }

  showMenuDialog() {
    return showDialog(
      context: context,
      builder: (BuildContext c) {
        return ProfileDialouge();
      },
    );
  }
}
