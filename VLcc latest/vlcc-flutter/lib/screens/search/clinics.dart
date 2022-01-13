import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/src/provider.dart';
import 'package:vlcc/components/components.dart';
import 'package:vlcc/database/db_helper.dart';
import 'package:vlcc/models/center_master_model.dart';
import 'package:vlcc/resources/app_colors.dart';
import 'package:vlcc/resources/assets_path.dart';
import 'package:vlcc/resources/common_strings.dart';
import 'package:vlcc/resources/dimensions.dart';
import 'package:vlcc/resources/string_extensions.dart';
import 'package:vlcc/screens/profile/clinic_profile.dart';
import 'package:vlcc/screens/search/search_speciality.dart';
import 'package:vlcc/widgets/heading_title_text.dart';
import 'package:vlcc/widgets/search_widgets/search_widgets.dart';

class Clinics extends StatefulWidget {
  final CenterMasterDatabase centerMasterDatabase;
  const Clinics({Key? key, required this.centerMasterDatabase})
      : super(key: key);

  @override
  State<Clinics> createState() => _ClinicsState();
}

class _ClinicsState extends State<Clinics> with SingleTickerProviderStateMixin {
  late TabController tabController;
  var indexAppointment = 1;
  var videoConsultation = 1;

  @override
  void initState() {
    tabController = TabController(initialIndex: 0, length: 2, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    final databaseProvider = context.watch<DatabaseHelper>();
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: NestedScrollView(
        controller: ScrollController(),
        floatHeaderSlivers: true,
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return [
            SliverAppBar(
              snap: true,
              bottom: TabBar(
                isScrollable: true,
                labelStyle: TextStyle(
                    fontSize: FontSize.heading,
                    fontWeight: FontWeight.bold,
                    fontFamily: FontName.frutinger),
                unselectedLabelStyle: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontFamily: FontName.frutinger,
                ),
                indicatorColor: AppColors.profileEnabled,
                controller: tabController,
                tabs: const <Widget>[
                  Tab(
                    child: Text(
                      'Appointments',
                    ),
                  ),
                  Tab(
                    child: Text(
                      'Video Consultations',
                    ),
                  ),
                ],
              ),
              backgroundColor: AppColors.backgroundColor,
              excludeHeaderSemantics: true,
              pinned: true,
              floating: true,
              leading: Transform.scale(
                scale: 1.4,
                child: Container(
                  margin: EdgeInsets.only(left: 24, top: 12, bottom: 12),
                  decoration: BoxDecoration(
                      border: Border.all(width: 1, color: AppColors.backBorder),
                      borderRadius: BorderRadius.circular(8)),
                  child: IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: SvgPicture.asset(SVGAsset.backButton),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    databaseProvider.serviceFilterList =
                        databaseProvider.serviceMasterDbList;
                    Navigator.push(
                        context,
                        PageTransition(
                            child: ClinicProfileBooking(
                              centerMasterDatabase: widget.centerMasterDatabase,
                            ),
                            type: PageTransitionType.bottomToTop));
                  },
                  child: Text(
                    'View clinic profile',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: FontSize.defaultFont,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: AppColors.backgroundColor,
                  ),
                )
              ],
              expandedHeight: 350,
              flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.pin,
                titlePadding: const EdgeInsets.symmetric(vertical: 70),
                background: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Column(
                      children: [
                        Expanded(child: SizedBox()),
                        Padding(
                          padding: const EdgeInsets.only(top: 60, bottom: 20),
                          child: clinicCard(),
                        ),
                        Expanded(child: SizedBox()),
                      ],
                    )),
              ),
            ),
          ];
        },
        body: body(
            databaseProvider: databaseProvider,
            centerMasterDatabase: widget.centerMasterDatabase),
      ),
    );
  }

  Widget body(
          {required DatabaseHelper databaseProvider,
          required CenterMasterDatabase centerMasterDatabase}) =>
      TabBarView(
        controller: tabController,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: servicesList(databaseProvider, centerMasterDatabase),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: videoService(databaseProvider, centerMasterDatabase),
          )
          // basicInformation(),
        ],
      );

  Column videoService(DatabaseHelper databaseProvider,
      CenterMasterDatabase centerMasterDatabase) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 30),
        HeadingTitleText(fontSize: FontSize.extraLarge, title: 'Services'),
        SizedBox(height: 4),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            child: ListView.builder(
              itemCount: databaseProvider.serviceMasterDbList.length,
              itemBuilder: (context, index) {
                // videoConsultation = 0;
                if (databaseProvider.serviceMasterDbList[index].serviceAppFor
                        .toLowerCase() ==
                    'video consultations') {
                  videoConsultation++;
                  return MedicalServices(
                    index: videoConsultation,
                    serviceMasterDatabase:
                        databaseProvider.serviceMasterDbList[index],
                    centerMasterDatabase: centerMasterDatabase,
                  );
                } else {
                  return SizedBox();
                }
              },
            ),
          ),
        )
      ],
    );
  }

  Widget servicesList(DatabaseHelper databaseProvider,
      CenterMasterDatabase centerMasterDatabase) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 30),
        HeadingTitleText(fontSize: FontSize.extraLarge, title: 'Services'),
        SizedBox(height: 4),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            child: ListView.builder(
              itemCount: databaseProvider.serviceMasterDbList.length,
              itemBuilder: (context, index) {
                // indexAppointment = 0;
                if (databaseProvider.serviceMasterDbList[index].serviceAppFor
                        .toLowerCase() !=
                    'video consultations') {
                  indexAppointment++;
                  return MedicalServices(
                    index: indexAppointment,
                    serviceMasterDatabase:
                        databaseProvider.serviceMasterDbList[index],
                    centerMasterDatabase: centerMasterDatabase,
                  );
                } else {
                  return SizedBox();
                }
              },
            ),
          ),
        )
      ],
    );
  }

  Widget clinicCard() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        elevation: 4.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        color: Colors.white,
        shadowColor: Colors.black26,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 24, 0),
              child: Container(
                clipBehavior: Clip.antiAlias,
                decoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(10)),
                child: Image.asset(
                  PNGAsset.clinicLogo,
                  width: 52,
                ),
              ),
            ),
            Expanded(
              child: SizedBox(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0, top: 8.0),
                        child: HeadingTitleText(
                          fontSize: FontSize.heading,
                          title: widget.centerMasterDatabase.centerName
                              .toLowerCase()
                              .toTitleCase,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: HeadingTitleText(
                          fontSize: FontSize.normal,
                          fontWeight: FontWeight.w600,
                          title: widget.centerMasterDatabase.areaName
                              .toLowerCase()
                              .toTitleCase,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: HeadingTitleText(
                          fontSize: FontSize.normal,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey,
                          title:
                              "${widget.centerMasterDatabase.areaName}, ${widget.centerMasterDatabase.cityName}"
                                  .toLowerCase()
                                  .toTitleCase,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          children: [
                            Icon(
                              Icons.star,
                              color: Colors.amber,
                            ),
                            RichText(
                              text: TextSpan(
                                text:
                                    ' ${widget.centerMasterDatabase.centerRatelist} ',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.profileEnabled,
                                ),
                                children: const <TextSpan>[
                                  // TextSpan(
                                  //   text: '(1387 Feedback)',
                                  //   style: TextStyle(
                                  //       color: Colors.grey,
                                  //       fontWeight: FontWeight.w400),
                                  // ),
                                ],
                              ),
                            )
                          ],
                        ),
                      )
                    ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// TabBarView(
//                   children: [
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         SizedBox(height: 32),
//                         Text("Services",
//                             style: TextStyle(
//                                 fontFamily: FontName.frutinger,
//                                 fontWeight: FontWeight.w700,
//                                 fontSize: FontSize.extraLarge)),
//                         SizedBox(height: 24),
//                         Column(
//                           children: List.generate(
//                             databaseProvider.centerMasterDbList.length,
//                             (index) => MedicalServices(
//                               index: index,
//                               serviceMasterDatabase:
//                                   databaseProvider.serviceMasterDbList[index],
//                               centerMasterDatabase: centerMasterDatabase,
//                             ),
//                           ),
//                         )
//                       ],
//                     ),
//                     Center(
//                       child: Text("Video Consultation",
//                           style: TextStyle(
//                               color: Colors.black54,
//                               fontFamily: FontName.frutinger,
//                               fontWeight: FontWeight.w600,
//                               fontSize: FontSize.heading)),
//                     ),
//                   ],
//                 ),
