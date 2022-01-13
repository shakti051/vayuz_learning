import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:jiffy/jiffy.dart';
import 'package:vlcc/models/notificaitons_model.dart';
import 'package:vlcc/providers/shared_pref.dart';
import 'package:vlcc/resources/apiHandler/api_call.dart';
import 'package:vlcc/resources/app_colors.dart';
import 'package:vlcc/resources/assets_path.dart';
import 'package:vlcc/resources/dimensions.dart';
import 'package:vlcc/widgets/heading_title_text.dart';
//https://www.lms.vlccwellness.com/api/api_notification_expert_list.php?request=notification_list

class NotificationExpertScreen extends StatefulWidget {
  const NotificationExpertScreen({Key? key}) : super(key: key);

  @override
  _NotificationExpertScreenState createState() =>
      _NotificationExpertScreenState();
}

class _NotificationExpertScreenState extends State<NotificationExpertScreen> {
  late Services _services;
  final VlccShared _sharedPreferences = VlccShared();
  late Future<List<NotificationDetailModel>> notifications;
  NotificationsModel? notificationsModel;
  @override
  void initState() {
    super.initState();
    _services = Services();
    notifications = getNotifications();
  }

  Future<List<NotificationDetailModel>> getNotifications() async {
    var body = {
      'auth_token': _sharedPreferences.authToken,
      'staff_mobile': _sharedPreferences.mobileNum,
      'device_id': _sharedPreferences.deviceId
    };
    var response = await _services.callApi(
        body, '/api/api_notification_expert_list.php?request=notification_list',
        apiName: 'expert notification');
    List<NotificationDetailModel> _notifications = [];
    try {
      notificationsModel = NotificationsModel.fromJson(jsonDecode(response));
      for (var element in notificationsModel!.notificationDetails) {
        NotificationDetailModel notificationDetailModel =
            NotificationDetailModel(
                notificationId: element['NotificationId'] ?? '',
                appointmentId: element['AppointmentId'] ?? '',
                notificationtoken: element['Notificationtoken'] ?? '',
                notificationtitle: element['Notificationtitle'] ?? '',
                notificationmessage: element['Notificationmessage'] ?? '',
                notificationMobileNo: element['NotificationMobileNo'] ?? '',
                notificationstatus: element['Notificationstatus'] ?? '',
                createdDate: element['CreatedDate'] ?? '',
                createdTime: element['CreatedTime'] ?? '',
                updatedDate: element['UpdatedDate'] ?? '',
                updatedTime: element['UpdatedTime'] ?? '');
        _notifications.add(notificationDetailModel);
      }
    } catch (e) {
      log('Error', error: e, name: ' Error notificaiton');
    }
    return _notifications.reversed.toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: _appBar(),
      body: _body(),
    );
  }

  AppBar _appBar() {
    return AppBar(
      backgroundColor: AppColors.backgroundColor,
      leading: InkWell(
        onTap: () {
          Navigator.pop(context);
        },
        child: Container(
         // padding: EdgeInsets.all(PaddingSize.small),
          decoration: BoxDecoration(
              border: Border.all(width: 1, color: AppColors.backBorder),
              borderRadius: BorderRadius.circular(8)),
          child: Icon(
            Icons.keyboard_backspace,
            size: 24,
            color: AppColors.profileEnabled,
          ),
        ),
      ),
    );
  }

  Widget _body() {
    return FutureBuilder<List<NotificationDetailModel>>(
      future: notifications,
      builder: (BuildContext context,
          AsyncSnapshot<List<NotificationDetailModel>> snapshot) {
        Widget child = SizedBox();
        switch (snapshot.connectionState) {
          case ConnectionState.active:
            break;
          case ConnectionState.done:
            List<NotificationDetailModel> notificationList =
                snapshot.data ?? [];

            child = SingleChildScrollView(
              physics: ScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: HeadingTitleText(
                      fontSize: FontSize.heading,
                      title: 'Notifications',
                    ),
                  ),
                  ListView.builder(
                      itemCount:
                          notificationsModel!.notificationDetails.length,
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        NotificationDetailModel notificationDetailModel =
                            notificationList[index];
                        return _notificationTile(
                          message: notificationDetailModel.notificationmessage,
                          time: notificationDetailModel.createdTime,
                          date: notificationDetailModel.createdDate,
                        );
                      })
                ],
              ),
            );
            break;
          case ConnectionState.waiting:
            child = Center(
                child: CircularProgressIndicator(color: AppColors.orange));
            break;
          default:
        }
        return child;
      },
    );
  }

  Widget _notificationTile({
    required String message,
    required String time,
    required String date,
  }) {
    DateTime dateTime = DateTime.parse('$date $time');
    // String formattedTime = DateFormat.jm().format(dateTime);
    // String formattedDate = DateFormat.yMMMd().format(dateTime);
    String fromNow = Jiffy(dateTime).fromNow();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Card(
        elevation: 3,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: ListTile(
          tileColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(horizontal: 8),
          leading: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(width: 10),
              SvgPicture.asset(SVGAsset.orangeTask),
            ],
          ),
          title: RichText(
            textAlign: TextAlign.start,
            text: TextSpan(
                text: message,
                style: TextStyle(
                  color: AppColors.profileEnabled,
                  fontWeight: FontWeight.w400,
                  fontSize: FontSize.normal,
                ),
                children: const [TextSpan(text: '\n')]),
          ),
          subtitle: Text(fromNow),
        ),
      ),
    );
  }
}
