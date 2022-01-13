import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:vlcc/database/db_helper.dart';
import 'package:vlcc/models/vlcc_reminder_model.dart';
import 'package:vlcc/resources/app_colors.dart';
import 'package:vlcc/resources/assets_path.dart';
import 'package:vlcc/resources/dimensions.dart';
import 'package:vlcc/screens/appointments/upcoming_general.dart';
import 'package:vlcc/screens/appointments/view_details.dart';
import 'package:vlcc/screens/dashboard/vew_details_appoint.dart';
import 'package:vlcc/widgets/appointment_widgets/add_reminder.dart';
import 'package:vlcc/widgets/appointment_widgets/view_reminder.dart';
import 'package:vlcc/widgets/dashboard_widgets/dashboard_widgets.dart';
import 'package:vlcc/widgets/nodata.dart';

class UpcomingAppointment extends StatefulWidget {
  const UpcomingAppointment({Key? key}) : super(key: key);

  @override
  State<UpcomingAppointment> createState() => _UpcomingAppointmentState();
}

class _UpcomingAppointmentState extends State<UpcomingAppointment> {
  final DateFormat _dateFormatter = DateFormat('MMM dd, yyyy');

  viewReminderDialog({required VlccReminderModel vlccReminderModel}) {
    return showDialog(
        context: context,
        builder: (BuildContext c) {
          return ViewReminder(
            vlccReminderModel: vlccReminderModel,
          );
        });
  }

  String titleCase(String text) {
    if (text.length <= 1) return text.toUpperCase();
    var words = text.split(' ');
    var capitalized = words.map((word) {
      var first = word.substring(0, 1).toUpperCase();
      var rest = word.substring(1);
      return '$first$rest';
    });
    return capitalized.join(' ');
  }

  addReminderDialog(
      {required int index,
      int appointmentType = 0,
      required String addressLine1,
      required String addressLine2,
      required String appointmentId,
      required DateTime appointmentDate,
      required String title,
      required int appointmentSeconds}) {
    return showDialog(
        context: context,
        builder: (BuildContext c) {
          return AddReminder(
            appointmentType: appointmentType,
            addressLine1: addressLine1,
            appointmentseconds: appointmentSeconds,
            index: index,
            serviceName: title,
            addressLine2: addressLine2,
            appointmentDate: appointmentDate,
            appointmentId: appointmentId,
          );
        });
  }

  int findSnapshotIndex(
      {required int appointmentId,
      required List<VlccReminderModel> listReminder}) {
    var result = listReminder
        .indexWhere((element) => element.appointmentId == appointmentId);
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final dashboardProvider = context.watch<DashboardProvider>();
    final databaseHelper = context.watch<DatabaseHelper>();
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                "Upcoming appointment",
                style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w700,
                    fontSize: FontSize.large),
              ),
              Spacer(),
              Visibility(
                visible: dashboardProvider.generalAppointmentList.isNotEmpty &&
                    dashboardProvider.generalAppointmentList.length != 1,
                child: InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          PageTransition(
                              type: PageTransitionType.rightToLeft,
                              child: UpcomingGeneralAppointment()));
                    },
                    child: Icon(Icons.arrow_forward)),
              )
            ],
          ),
          SizedBox(
            height: 20,
          ),
          consulationCard(
              dashboardProvider: dashboardProvider,
              databaseHelper: databaseHelper),
        ],
      ),
    );
  }

  int convertToTime({required DateTime temp}) {
    var seconds = temp.difference(DateTime.now()).inSeconds;
    return seconds;
  }

  Widget consulationCard(
      {required DashboardProvider dashboardProvider,
      required DatabaseHelper databaseHelper}) {
    var generalAppointment = dashboardProvider.generalAppointmentList;
    return generalAppointment.isNotEmpty
        ? FutureBuilder<List<VlccReminderModel>>(
            future: databaseHelper.getReminders(),
            builder: (context, snapshot) {
              List<VlccReminderModel> snap = [];
              if (snapshot.hasData) {
                snap = snapshot.data!
                    .where(
                      (element) =>
                          element.appointmentId ==
                          int.parse(generalAppointment.first.appointmentId),
                    )
                    .toList();
              }
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: const [
                      BoxShadow(
                        color: Color.fromRGBO(0, 64, 128, 0.04),
                        blurRadius: 10,
                        offset: Offset(0, 5), // changes position of shadow
                      )
                    ],
                    borderRadius: BorderRadius.circular(16)),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10)),
                        width: 52,
                        child: Image.asset(PNGAsset.clinicLogo)),
                    SizedBox(
                      width: 8,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  generalAppointment.first.serviceName,
                                  style: TextStyle(
                                      color: Colors.black87,
                                      fontWeight: FontWeight.w700,
                                      fontSize: FontSize.large),
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    generalAppointment.first.appointmentStatus,
                                    style: TextStyle(
                                        color: AppColors.orange,
                                        fontWeight: FontWeight.w600,
                                        fontSize: FontSize.small),
                                  ),
                                  Text(
                                    _dateFormatter.format(
                                      generalAppointment
                                              .first.appointmentDate ??
                                          DateTime.now(),
                                    ),
                                    style: TextStyle(
                                        color: AppColors.blue,
                                        fontWeight: FontWeight.w600,
                                        fontSize: FontSize.small),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          //       _nameController.text.split('')[0].toUpperCase() +
                          // _nameController.text.substring(1))
                          Container(
                            margin: const EdgeInsets.symmetric(
                                vertical: MarginSize.small),
                            child: Text(
                              titleCase(generalAppointment.first.addressLine1
                                  .toLowerCase()),
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: FontSize.normal),
                            ),
                          ),
                          Text(
                            titleCase(generalAppointment.first.addressLine2
                                .toLowerCase()),
                            style: TextStyle(
                                color: AppColors.grey,
                                fontWeight: FontWeight.w600,
                                fontSize: FontSize.normal),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ViewDetails(
                                            appointmentListModel:
                                                dashboardProvider
                                                    .allAppointmentList,
                                            isVideoCall: false)
                                        // AppointmentDetails(
                                        //     dashboardProvider:
                                        //         dashboardProvider,
                                        //     generalAppointment:
                                        //         generalAppointment)
                                        ),
                                  );
                                },
                                child: Container(
                                    margin: const EdgeInsets.symmetric(
                                        vertical: MarginSize.middle),
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            color: AppColors.orangeProfile,
                                            width: 1.0),
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: PaddingSize.extraLarge,
                                        vertical: 8),
                                    child: Text(
                                      "View Details",
                                      style: TextStyle(
                                          color: AppColors.orange,
                                          fontWeight: FontWeight.w600,
                                          fontSize: FontSize.large),
                                    )),
                              ),
                              InkWell(
                                onTap: () {
                                  if (snap.isEmpty) {
                                    addReminderDialog(
                                        index: 0,
                                        addressLine1: generalAppointment
                                            .first.addressLine1,
                                        addressLine2: generalAppointment
                                            .first.addressLine2,
                                        appointmentId: generalAppointment
                                            .first.appointmentId,
                                        appointmentDate: generalAppointment
                                                .first.appointmentDate ??
                                            DateTime.now(),
                                        title: generalAppointment
                                            .first.serviceName,
                                        appointmentSeconds: convertToTime(
                                          temp: generalAppointment
                                                  .first.appointmentDate ??
                                              DateTime.now(),
                                        ));
                                  } else {
                                    viewReminderDialog(
                                      vlccReminderModel:
                                          snapshot.data![findSnapshotIndex(
                                        appointmentId: int.parse(
                                            generalAppointment
                                                .first.appointmentId),
                                        listReminder: snapshot.data ?? [],
                                      )],
                                    );
                                  }
                                },
                                child: SvgPicture.asset(
                                  "assets/images/reminder.svg",
                                  color: snap.isEmpty
                                      ? AppColors.grey
                                      : AppColors.orange,
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              );
            })
        : NoDataScreen(noDataSelect: NoDataSelectType.upcomingAppointment);
  }
}
