import 'dart:convert';
import 'dart:developer';
import 'package:flutter/cupertino.dart';
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

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  late Services _services;
  final VlccShared _sharedPreferences = VlccShared();
  late Future<List<NotificationDetailModel>> notifications;

  @override
  void initState() {
    super.initState();
    _services = Services();
    notifications = getNotifications();
    //  .then((value) {
    //     setState(() {
    //       notifications = value;
    //     });
    //   });
  }

  Future<List<NotificationDetailModel>> getNotifications() async {
    var body = {
      'auth_token': _sharedPreferences.authToken,
      'client_mobile': _sharedPreferences.mobileNum,
      'device_id': _sharedPreferences.deviceId
    };
    var response = await _services.callApi(
        body, '/api/api_notification_list.php?request=notification_list');
    // var jsonResponse = jsonDecode(response);
    List<NotificationDetailModel> _notifications = [];
    // log('${_notifications.toList()}', name: 'notificaiton');
    // try {
    //   if (jsonResponse['Status'] == 2000) {
    //     _notifications = jsonResponse['NotificationDetails'];
    //   }
    // } catch (e) {
    //   log('message', error: e);
    // }

    // List<dynamic> list = jsonResponse['NotificationDetails'];

    try {
      NotificationsModel notificationsModel =
          NotificationsModel.fromJson(jsonDecode(response));
      // _notifications = notificationsModel.notificationDetails
      // as List<NotificationDetailModel>;
      // log('${notificationsModel.notificationDetails()}',
      //     name: 'notificaiton details');
      // log('${notificationsModel.notificationDetails?.length}',
      // name: 'notificaiton details');
      for (var element in notificationsModel.notificationDetails) {
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
        // log('${element['NotificationMobileNo']}', name: 'notificaiton details');
      }
    } catch (e) {
      log('Error', error: e, name: ' Error notificaiton');
    }

    // log('${_notifications.last.toString()}', name: 'notificaiton');
    // NotificationsModel notificationsModel =
    //     NotificationsModel.fromJson(jsonDecode(response));
    // try {
    //   _notifications = notificationsModel.notificationDetails;
    // } catch (e) {
    //   log('Error', error: e, name: ' Error notificaiton');
    // }

    // NotificationsModel.fromRawJson(str)

    // log('message \n \n $notificationsModel \n \n hello');
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
          padding: EdgeInsets.all(PaddingSize.small),
          decoration: BoxDecoration(
              border: Border.all(width: 1, color: AppColors.backBorder),
              borderRadius: BorderRadius.circular(16)),
          child: Icon(
            Icons.keyboard_backspace,
            size: 24,
            color: AppColors.profileEnabled,
          ),
        ),
      ),
      // actions: [
      // SvgPicture.asset(SVGAsset.mailOutline),
      // TextButton(
      //   onPressed: () {},
      //   child: HeadingTitleText(
      //     fontSize: FontSize.normal,
      //     title: 'Mark all as read',
      //   ),
      // )
      // ],
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
                      itemCount: 10,
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
              // Badge(
              //   badgeColor: AppColors.orange,
              // ),
              SizedBox(
                width: 10,
              ),
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
