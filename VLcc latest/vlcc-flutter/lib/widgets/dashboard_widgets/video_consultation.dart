import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:vlcc/database/db_helper.dart';
import 'package:vlcc/models/appointment_expert_model.dart';
import 'package:vlcc/models/appointment_list_model.dart';
import 'package:vlcc/models/vlcc_reminder_model.dart';
import 'package:vlcc/resources/app_colors.dart';
import 'package:vlcc/resources/dimensions.dart';
import 'package:vlcc/screens/appointments/upcoming_video_consultation.dart';
import 'package:vlcc/screens/dashboard/videocall_details.dart';
import 'package:vlcc/widgets/appointment_widgets/add_reminder.dart';
import 'package:vlcc/widgets/appointment_widgets/view_reminder.dart';
import 'package:vlcc/widgets/dashboard_widgets/dashboard_provider.dart';

class VideoConsultation extends StatefulWidget {
  AppointmentExpertModel? appointmentExpertModel;
  VideoConsultation({Key? key,this.appointmentExpertModel}) : super(key: key);

  @override
  State<VideoConsultation> createState() => _VideoConsultationState();
}

class _VideoConsultationState extends State<VideoConsultation> {
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

  int convertToTime({required DateTime temp}) {
    var seconds = temp.difference(DateTime.now()).inSeconds;
    return seconds;
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
    final dashBoardProvider = context.watch<DashboardProvider>();
    final databaseHelper = context.watch<DatabaseHelper>();
    var videoAppointment = dashBoardProvider.videoAppointmentList;
    return videoAppointment.isNotEmpty
        ? Column(
            children: [
              Container(
                margin: EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Text(
                      "Upcoming video consultation",
                      style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w700,
                          fontSize: FontSize.large),
                    ),
                    Spacer(),
                    Visibility(
                      visible: videoAppointment.isEmpty ||
                          videoAppointment.length != 1,
                      child: InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                PageTransition(
                                    type: PageTransitionType.rightToLeft,
                                    child: UpcomingVideoConsultation()));
                          },
                          child: Icon(Icons.arrow_forward)),
                    )
                  ],
                ),
              ),
              SizedBox(
                height: 20,
              ),
              upcomingVideoConsultationCard(
                  databaseHelper: databaseHelper,
                  videoAppointment: videoAppointment,
                  dashBoardProvider: dashBoardProvider),
            ],
          )
        : SizedBox();
  }

  List<int> getAppointmentDate({required int milliseconds}) {
    var date = DateTime.fromMillisecondsSinceEpoch(milliseconds * 1000);
    var appointmentLeftMinutes = date.difference(DateTime.now()).inMinutes;
    var finalHours = minutesToHoursDays(appointmentLeftMinutes);
    return finalHours;
  }

  List<int> minutesToHoursDays(int minutes) {
    int days = (minutes / 1440).floor();
    int hours = ((minutes % 1440) / 60).floor();
    int minutesLeft = (minutes % 60).floor();
    return [days, hours, minutesLeft];
  }

  Widget upcomingVideoConsultationCard(
      {required List<AppointmentDetail> videoAppointment,
      required DashboardProvider dashBoardProvider,
      required DatabaseHelper databaseHelper}) {
    return FutureBuilder<List<VlccReminderModel>>(
        future: databaseHelper.getReminders(),
        builder: (context, snapshot) {
          List<VlccReminderModel> snap = [];
          if (snapshot.hasData) {
            snap = snapshot.data!
                .where(
                  (element) =>
                      element.appointmentId ==
                      int.parse(videoAppointment.first.appointmentId),
                )
                .toList();
          }
          var date = getAppointmentDate(
              milliseconds: videoAppointment.first.appointmentStartDateTime);
          return Container(
            margin: EdgeInsets.symmetric(horizontal: 24),
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
                SizedBox(
                    width: 52,
                    child: SvgPicture.asset("assets/images/beauty_brush.svg")),
                SizedBox(
                  width: 8,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        videoAppointment.first.serviceName,
                        style: TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.w700,
                            fontSize: FontSize.large),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(
                            vertical: MarginSize.small),
                        child: Text(
                          titleCase(videoAppointment.first.addressLine1
                              .toLowerCase()),
                          style: TextStyle(
                              color: AppColors.orange,
                              fontWeight: FontWeight.w600,
                              fontSize: FontSize.normal),
                        ),
                      ),
                      Text(
                        'In ${date[0]} days ${date[1]} hours ${date[2]} mins',
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
                                    builder: (context) => VideoCallDetails(
                                        videoAppointment: videoAppointment,
                                        dashboardProvider: dashBoardProvider)),
                              );
                            },
                            child: Container(
                                margin: const EdgeInsets.symmetric(
                                    vertical: MarginSize.middle),
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        color: AppColors.orangeProfile,
                                        width: 1.0),
                                    borderRadius: BorderRadius.circular(10)),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: PaddingSize.extraLarge,
                                    vertical: 8),
                                child: Text(
                                  "Video Call",
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
                                    addressLine1:
                                        videoAppointment.first.addressLine1,
                                    addressLine2:
                                        videoAppointment.first.addressLine2,
                                    appointmentId:
                                        videoAppointment.first.appointmentId,
                                    appointmentDate: videoAppointment
                                            .first.appointmentDate ??
                                        DateTime.now(),
                                    title: videoAppointment.first.serviceName,
                                    appointmentSeconds: convertToTime(
                                      temp: videoAppointment
                                              .first.appointmentDate ??
                                          DateTime.now(),
                                    ));
                              } else {
                                viewReminderDialog(
                                  vlccReminderModel:
                                      snapshot.data![findSnapshotIndex(
                                    appointmentId: int.parse(
                                        videoAppointment.first.appointmentId),
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
        });
  }
}
