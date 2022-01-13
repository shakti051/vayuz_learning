import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';
import 'package:vlcc/models/appointment_list_model.dart';
import 'package:vlcc/models/cancel_appointment_model.dart';
import 'package:vlcc/models/enablex_model.dart';
import 'package:vlcc/providers/shared_pref.dart';
import 'package:vlcc/resources/apiHandler/api_call.dart';
import 'package:vlcc/resources/apiHandler/api_url/api_url.dart';
import 'package:vlcc/resources/app_colors.dart';
import 'package:vlcc/resources/assets_path.dart';
import 'package:vlcc/resources/common_strings.dart';
import 'package:vlcc/resources/dimensions.dart';
import 'package:vlcc/resources/string_extensions.dart';
import 'package:vlcc/resources/util_functions.dart';
import 'package:vlcc/screens/appointments/reshedule_appointment.dart';
import 'package:vlcc/screens/enable_x/video_call.dart';
import 'package:vlcc/widgets/appointment_widgets/appointment_widgets.dart';
import 'package:vlcc/widgets/gradient_button.dart';
// import 'permission_service.dart';

class ViewDetails extends StatefulWidget {
  final int index;
  final bool isVideoCall;
  final AppointmentListModel? appointmentListModel;

  const ViewDetails({
    Key? key,
    this.index = 0,
    required this.appointmentListModel,
    required this.isVideoCall,
  }) : super(key: key);

  @override
  _ViewDetailsState createState() => _ViewDetailsState();
}

class _ViewDetailsState extends State<ViewDetails> {
  static const String kBaseURL = "https://demo.enablex.io/";
  /* To try the app with Enablex hosted service you need to set the kTry = true */
  static bool kTry = true;
  /*Use enablec portal to create your app and get these following credentials*/

  static const String kAppId = "6103e7b97fdf83297328e394";
  static const String kAppkey = "UePy4yJugyYenutyJa8eSeVurunevyHadeAy";
  static String token = "";
  VlccShared sharedPrefs = VlccShared();
  final Services services = Services();
  final DateFormat _dateFormatter = DateFormat('MMM dd, yyyy');

  var header = kTry
      ? {
          "x-app-id": kAppId,
          "x-app-key": kAppkey,
          "Content-Type": "application/json"
        }
      : {
          "Content-Type": "application/json",
        };

  Future<void> _handleCameraAndMic() async {
    var cam = await Permission.camera.request();
    var mic = await Permission.microphone.request();
    var store = await Permission.storage.request();
    var result = cam.isGranted && mic.isGranted && store.isGranted;
  }

//   Future<void> permissionAccess() async {
//     var result =
//         await PermissionService().requestPermission(onPermissionDenied: () {
// //      print('Permission has been denied');
//     });

//     if (result) {
//       joinRoomValidations();
//     }
//   }

  bool permissionError = false;

  Future<void> joinRoomValidations() async {
    log('joinRoomValidations');
    await _handleCameraAndMic();
    if (permissionError) {
      Fluttertoast.showToast(
          msg: "Plermission denied",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
      return;
    }
    // if (nameController.text.isEmpty) {
    //   Fluttertoast.showToast(
    //       msg: "Please Enter your name",
    //       toastLength: Toast.LENGTH_SHORT,
    //       gravity: ToastGravity.BOTTOM,
    //       backgroundColor: Colors.red,
    //       textColor: Colors.white,
    //       fontSize: 16.0);
    //   isValidated = false;
    // } else if (roomIdController.text.isEmpty) {
    //   Fluttertoast.showToast(
    //       msg: "Please Enter your roomId",
    //       toastLength: Toast.LENGTH_SHORT,
    //       gravity: ToastGravity.BOTTOM,
    //       backgroundColor: Colors.red,
    //       textColor: Colors.white,
    //       fontSize: 16.0);
    //   isValidated = false;
    // } else {
    //   isValidated = true;
    // }
  }

  Future<String> getRoomID() async {
    var baseUrl = "https://enablextestserver.herokuapp.com/api/create-room";
    var response = await http.get(Uri.parse(baseUrl));
    var roomId = '';
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      final enableXModel = enableXModelFromJson(response.body);
      roomId = enableXModel.room!.roomId;
    }
    return roomId;
  }

  Future<void> updateRoomID({
    required String roomID,
    required String token,
  }) async {
    var body = {
      "appointment_token": token,
      "appointment_room": roomID,
      "auth_token": sharedPrefs.authToken,
      "device_id": sharedPrefs.deviceId,
      "client_mobile": sharedPrefs.mobileNum,
      "appointment_id": widget.appointmentListModel!
          .appointmentDetails![widget.index].appointmentId,
    };
    var response =
        await services.callApi(body, ApiUrl.videoAppointmentTokenUpdate);
    log('$response', name: 'enable');
    //
  }

  Future<String> createToken() async {
    log('create room id');
    var roomId = await getRoomID();
    log('getRoomID $roomId');
    var value = {
      'user_ref': Uuid().v4.toString(),
      "roomId": roomId,
      "role": "participant",
      "name": sharedPrefs.name,
    };
    // log(jsonEncode(value).toString());
    log('create token');
    var response = await http.post(
        Uri.parse(
          "${kBaseURL}createToken",
        ), // replace FQDN with Your Server API URL
        headers: header,
        body: jsonEncode(value));

    if (response.statusCode == 200) {
      log(response.body, name: 'create token');
      Map<String, dynamic> user = jsonDecode(response.body);
      setState(() => token = user['token'].toString());

      if (sharedPrefs.employeCode.isEmpty) {
        // await updateRoomID(roomID: roomId, token: token);
      }

      log('updateRoomID token');
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) {
            return MyConfApp(
              token: token,
            );
          },
        ),
      );
      return response.body;
    } else {
      throw Exception('Failed to load post');
    }
  }

  final TextEditingController _problemDesc = TextEditingController();
  final Services _services = Services();
  CancelAppointmentModel? cancelAppointmentModel;
  DateTime _currentDate = DateTime.now();
  TimeOfDay? time;
  TimeOfDay? picked;

  void cancelAppointment() {
    var body = {
      'client_mobile': sharedPrefs.mobileNum,
      'auth_token': sharedPrefs.authToken,
      'device_id': sharedPrefs.deviceId,
      'appointment_cancel_date': _currentDate,
      'AppointmentId': widget.appointmentListModel!
          .appointmentDetails![widget.index].appointmentId,
      'cancellation_comment': "test",
    };
    _services
        .callApi(body,
            '/api/api_appointment_cancel_rbs.php?request=appointment_cancel',
            apiName: 'Cancel Appointment RBI')
        .then((value) {
      var testVal = value;

      cancelAppointmentModel = cancelAppointmentModelFromJson(testVal);
      if (cancelAppointmentModel!.status == 2000) {
        Fluttertoast.showToast(
            msg: "Appointment Cancelled",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: 16.0);
      } else {
        Fluttertoast.showToast(
            msg: "Something went wrong",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: 16.0);
      }
    });
  }

  Future<void> _selectedDate(BuildContext context) async {
    var today = DateTime.now();
    final DateTime? _selDate = await showDatePicker(
      context: context,
      initialDate: _currentDate,
      firstDate: DateTime(today.year - 1),
      lastDate: DateTime(today.year + 1),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.orange,
              onPrimary: Colors.white,
              surface: Colors.orange,
            ),
            dialogBackgroundColor: AppColors.backgroundColor,
          ),
          child: child ?? SizedBox(),
        );
      },
    );

    if (_selDate != null) {
      setState(() {
        _currentDate = _selDate;
      });
    }
  }

  bool isAfterThisMoment(DateTime date) {
    var now = DateTime.now();
    return now.isAfter(date);
  }

  @override
  void initState() {
    time = TimeOfDay.now();
    super.initState();
  }

  Future<void> selectTime(BuildContext context) async {
    picked = await showTimePicker(
        context: context, initialTime: TimeOfDay(hour: 09, minute: 00));

    if (picked != null) {
      setState(() {
        time = picked;
      });
    }
  }

  void showToast(String msg) {
    Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  bool isCancelled = false;
  @override
  Widget build(BuildContext context) {
//    final databaseProvider = context.watch<DatabaseHelper>();
    showCancelDialog() {
      return showDialog(
          context: context,
          builder: (BuildContext c) {
            return CancelDialouge(
              index: widget.index,
              appointmentListModel: widget.appointmentListModel,
            );
          }).then((value) {
        // Navigator.pop(context);
        isCancelled = value as bool;
        setState(() {});
      });
    }

    return Scaffold(
      backgroundColor: AppColors.whiteShodow,
      appBar: _appBar(),
      body: SafeArea(
          child: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.only(top: 8),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: PaddingSize.extraLarge),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 24),
                Container(
                    margin:
                        const EdgeInsets.symmetric(vertical: MarginSize.small),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: const [
                          BoxShadow(
                              color: Color.fromRGBO(0, 64, 128, 0.04),
                              blurRadius: 10,
                              offset: Offset(0, 5))
                        ],
                        borderRadius: BorderRadius.circular(10)),
                    child: Row(
                      children: [
                        Container(
                          height: 56,
                          width: 56,
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          margin: EdgeInsets.all(MarginSize.middle),
                          child: Image.asset(PNGAsset.clinicLogo),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 12),
                              Text(
                                  widget
                                      .appointmentListModel!
                                      .appointmentDetails![widget.index]
                                      .serviceName,
                                  style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: FontSize.defaultFont)),
                              SizedBox(height: 4),
                              Text(
                                widget
                                    .appointmentListModel!
                                    .appointmentDetails![widget.index]
                                    .centerName
                                    .toLowerCase()
                                    .toTitleCase,
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: FontSize.normal),
                              ),
                              SizedBox(height: 4),
                              RichText(
                                text: TextSpan(
                                  text: widget
                                      .appointmentListModel!
                                      .appointmentDetails![widget.index]
                                      .cityName
                                      .toString()
                                      .toLowerCase()
                                      .toTitleCase,
                                  style: TextStyle(
                                      color: Colors.grey,
                                      fontWeight: FontWeight.w600,
                                      fontSize: FontSize.normal),
                                ),
                              ),
                              SizedBox(height: 12)
                            ],
                          ),
                        )
                      ],
                    )), //Todo later
                SizedBox(height: 32),
                Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    shadowColor: AppColors.whiteShodow,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: EdgeInsets.only(left: 12, top: 12, bottom: 4),
                          child: Text("Service Name",
                              style: TextStyle(
                                  fontFamily: FontName.frutinger,
                                  fontWeight: FontWeight.w600,
                                  fontSize: FontSize.normal)),
                        ),
                        Container(
                          padding:
                              EdgeInsets.symmetric(vertical: MarginSize.middle),
                          margin: EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                              color: AppColors.greyBackground,
                              borderRadius: BorderRadius.circular(8)),
                          child: Row(
                            children: [
                              Container(
                                  margin: EdgeInsets.symmetric(horizontal: 14),
                                  child: SvgPicture.asset(
                                      "assets/images/category.svg")),
                              Flexible(
                                child: Container(
                                  margin:
                                      EdgeInsets.only(right: MarginSize.middle),
                                  child: Text(
                                      widget
                                          .appointmentListModel!
                                          .appointmentDetails![widget.index]
                                          .serviceName,
                                      style: TextStyle(
                                          fontFamily: FontName.frutinger,
                                          fontWeight: FontWeight.w600,
                                          fontSize: FontSize.large)),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 16),
                        Container(
                          margin: EdgeInsets.only(left: 12, top: 12, bottom: 4),
                          child: Text("City",
                              style: TextStyle(
                                  fontFamily: FontName.frutinger,
                                  fontWeight: FontWeight.w600,
                                  fontSize: FontSize.normal)),
                        ),
                        Container(
                          padding:
                              EdgeInsets.symmetric(vertical: MarginSize.middle),
                          margin: EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                              color: AppColors.greyBackground,
                              borderRadius: BorderRadius.circular(8)),
                          child: Row(
                            children: [
                              Container(
                                  margin: EdgeInsets.symmetric(horizontal: 14),
                                  child: SvgPicture.asset(
                                      "assets/images/health_clinic.svg")),
                              Text(
                                  widget
                                      .appointmentListModel!
                                      .appointmentDetails![widget.index]
                                      .cityName,
                                  style: TextStyle(
                                      fontFamily: FontName.frutinger,
                                      fontWeight: FontWeight.w600,
                                      fontSize: FontSize.large)),
                            ],
                          ),
                        ),
                        SizedBox(height: 30),
                        SizedBox(
                          height: 75,
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      margin: EdgeInsets.only(
                                          left: MarginSize.middle),
                                      child: Text("Appointment date",
                                          style: TextStyle(
                                              fontFamily: FontName.frutinger,
                                              fontWeight: FontWeight.w600,
                                              fontSize: FontSize.normal)),
                                    ),
                                    SizedBox(height: 4),
                                    InkWell(
                                      onTap: () {
                                        //  _selectedDate(context);
                                      },
                                      child: Container(
                                        height: 46,
                                        margin: EdgeInsets.only(
                                            left: MarginSize.middle),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              width: 1,
                                              color: AppColors.backBorder),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          children: [
                                            Container(
                                              margin: EdgeInsets.symmetric(
                                                  horizontal: 14),
                                              child: SvgPicture.asset(
                                                  "assets/images/invitation.svg",
                                                  color:
                                                      AppColors.calanderColor),
                                            ),
                                            Container(
                                              height: 45,
                                              padding: EdgeInsets.only(top: 15),
                                              child: Text(
                                                _dateFormatter.format(widget
                                                        .appointmentListModel!
                                                        .appointmentDetails![
                                                            widget.index]
                                                        .appointmentDate ??
                                                    DateTime.now()),
                                                textAlign: TextAlign.left,
                                                style: TextStyle(
                                                    color: Colors.black87,
                                                    fontFamily:
                                                        FontName.frutinger,
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: FontSize.normal),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 16),
                            ],
                          ),
                        ),
                        SizedBox(height: 12),
                        SizedBox(
                          height: 75,
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      margin: EdgeInsets.only(
                                          left: MarginSize.middle),
                                      child: Text("Appointment time",
                                          style: TextStyle(
                                              fontFamily: FontName.frutinger,
                                              fontWeight: FontWeight.w600,
                                              fontSize: FontSize.normal)),
                                    ),
                                    SizedBox(height: 4),
                                    InkWell(
                                      onTap: () {
                                        //  _selectTime(context);
                                      },
                                      child: Container(
                                        height: 46,
                                        margin: EdgeInsets.only(
                                            left: MarginSize.middle,
                                            right: MarginSize.middle),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              width: 1,
                                              color: AppColors.backBorder),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          children: [
                                            Container(
                                              margin: EdgeInsets.symmetric(
                                                  horizontal: 14),
                                              child: SvgPicture.asset(
                                                  "assets/images/clock.svg",
                                                  color:
                                                      AppColors.calanderColor),
                                            ),
                                            Container(
                                              height: 45,
                                              padding: EdgeInsets.only(top: 15),
                                              child: Text(
                                                widget
                                                    .appointmentListModel!
                                                    .appointmentDetails![
                                                        widget.index]
                                                    .appointmentTime
                                                    .toString(),
                                                textAlign: TextAlign.left,
                                                style: TextStyle(
                                                    color: Colors.black87,
                                                    fontFamily:
                                                        FontName.frutinger,
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: FontSize.normal),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        // SizedBox(
                        //   height: 75,
                        //   child: Row(
                        //     children: [
                        //       Expanded(
                        //         child: Column(
                        //           crossAxisAlignment: CrossAxisAlignment.start,
                        //           children: [
                        //             Container(
                        //               margin: EdgeInsets.only(
                        //                   left: MarginSize.middle),
                        //               child: Text("Contact number",
                        //                   style: TextStyle(
                        //                       fontFamily: FontName.frutinger,
                        //                       fontWeight: FontWeight.w600,
                        //                       fontSize: FontSize.normal)),
                        //             ),
                        //             SizedBox(height: 4),
                        //             InkWell(
                        //               onTap: () async {
                        //                 String phoneNumber = widget
                        //                     .appointmentListModel!
                        //                     .appointmentDetails![widget.index]
                        //                     .phoneNumber
                        //                     .toString()
                        //                     .split("/")
                        //                     .first;
                        //                 String url = "tel:$phoneNumber";
                        //                 if (await canLaunch(url)) {
                        //                   await launch(url);
                        //                 } else {
                        //                   throw 'Could not launch $url';
                        //                 }
                        //               },
                        //               child: Container(
                        //                 height: 46,
                        //                 margin: EdgeInsets.only(
                        //                     left: MarginSize.middle,
                        //                     right: MarginSize.middle),
                        //                 decoration: BoxDecoration(
                        //                   border: Border.all(
                        //                       width: 1,
                        //                       color: AppColors.backBorder),
                        //                   borderRadius:
                        //                       BorderRadius.circular(8),
                        //                 ),
                        //                 child: Row(
                        //                   children: [
                        //                     Container(
                        //                       margin: EdgeInsets.symmetric(
                        //                           horizontal: 14),
                        //                       child: Icon(
                        //                         Icons.phone,
                        //                         color: AppColors.calanderColor,
                        //                       ),
                        //                     ),
                        //                     Container(
                        //                       height: 45,
                        //                       padding: EdgeInsets.only(top: 15),
                        //                       child: Text(
                        //                         widget
                        //                             .appointmentListModel!
                        //                             .appointmentDetails![
                        //                                 widget.index]
                        //                             .phoneNumber
                        //                             .toString(),
                        //                         textAlign: TextAlign.left,
                        //                         style: TextStyle(
                        //                             color:
                        //                                 AppColors.calanderColor,
                        //                             fontFamily:
                        //                                 FontName.frutinger,
                        //                             fontWeight: FontWeight.w600,
                        //                             fontSize: FontSize.normal),
                        //                       ),
                        //                     ),
                        //                   ],
                        //                 ),
                        //               ),
                        //             ),
                        //           ],
                        //         ),
                        //       ),
                        //     ],
                        //   ),
                        // ),
                      ],
                    )),
                SizedBox(height: 24),
                GradientButton(
                  gradient: const LinearGradient(
                      begin: Alignment.bottomLeft,
                      end: Alignment.topRight,
                      colors: [
                        Colors.blue,
                        Colors.lightBlue,
                      ]),
                  child: Container(
                    height: 46,
                    margin: EdgeInsets.only(
                        left: MarginSize.middle, right: MarginSize.middle),
                    // decoration: BoxDecoration(
                    //   border: Border.all(width: 1, color: AppColors.backBorder),
                    //   borderRadius: BorderRadius.circular(8),
                    // ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Spacer(),
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 14),
                          child: Icon(
                            Icons.phone,
                            color: Colors.white,
                          ),
                        ),
                        Container(
                          height: 45,
                          padding: EdgeInsets.only(top: 15),
                          child: Text(
                            widget.appointmentListModel!
                                .appointmentDetails![widget.index].phoneNumber
                                .toString(),
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                color: Colors.white,
                                fontFamily: FontName.frutinger,
                                fontWeight: FontWeight.w600,
                                fontSize: FontSize.normal),
                          ),
                        ),
                        Spacer()
                      ],
                    ),
                  ),
                  onPressed: () async {
                    String phoneNumber = widget.appointmentListModel!
                        .appointmentDetails![widget.index].phoneNumber
                        .toString()
                        .split("/")
                        .first;
                    String url = "tel:$phoneNumber";
                    if (await canLaunch(url)) {
                      await launch(url);
                    } else {
                      throw 'Could not launch $url';
                    }
                  },
                ),
                SizedBox(height: 24),
                GradientButton(
                  onPressed: () {
                    if (widget.isVideoCall) {
                      joinRoomValidations();
                      createToken();
                      // if (isAfterThisMoment(
                      //   DateTime.fromMillisecondsSinceEpoch(widget
                      //           .appointmentListModel!
                      //           .appointmentDetails![widget.index]
                      //           .appointmentStartDateTime *
                      //       1000),
                      // )) {
                      //   joinRoomValidations();
                      //   createToken();
                      // } else {
                      //   showToast(
                      //       "You will be allowed to join at the selected time duration only.");
                      // }
                    } else {
                      double destinationLatitude = double.parse(widget
                          .appointmentListModel!
                          .appointmentDetails![widget.index]
                          .centerLatitude);
                      double destinationLongitude = double.parse(widget
                          .appointmentListModel!
                          .appointmentDetails![widget.index]
                          .centerLongitude);
                      UtilityFunctions.launchMapsUrl(
                        sourceLatitude: destinationLatitude,
                        sourceLongitude: destinationLongitude,
                        destinationLatitude: destinationLatitude,
                        destinationLongitude: destinationLongitude,
                      );
                    }
                  },
                  child: Row(
                    children: [
                      Spacer(),
                      Text(
                          widget.isVideoCall
                              ? 'Start Consultation'
                              : "Show Directions",
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: FontSize.large,
                              color: Colors.white)),
                      SizedBox(width: 8),
                      if (!widget.isVideoCall)
                        SvgPicture.asset(SVGAsset.mapIcon, color: Colors.white),
                      Spacer(),
                    ],
                  ),
                ),
                SizedBox(height: 24),
                !isCancelled
                    ? Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  builder: (BuildContext context) =>
                                      SingleChildScrollView(
                                    child: Container(
                                      padding: EdgeInsets.only(
                                          bottom: MediaQuery.of(context)
                                              .viewInsets
                                              .bottom),
                                      child: ResheduleAppointment(
                                        appointmentListModel:
                                            widget.appointmentListModel,
                                        index: widget.index,
                                      ),
                                    ),
                                  ),
                                );
                              },
                              child: Text("Reshedule",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: FontSize.large,
                                      color: AppColors.orange1)),
                            ),
                          ),
                          Container(height: 15, width: 2, color: Colors.grey),
                          Expanded(
                            child: GestureDetector(
                              onTap: showCancelDialog,
                              child: Text("Cancel",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: FontSize.large,
                                      color: AppColors.pink)),
                            ),
                          ),
                        ],
                      )
                    : SizedBox(),
                SizedBox(height: 42)
              ],
            ),
          ),
        ),
      )),
    );
  }

  PreferredSize _appBar() {
    return PreferredSize(
      preferredSize: Size.fromHeight(60),
      child: AppBar(
        backgroundColor: AppColors.backgroundColor,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
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
        title: Column(
          children: [
            Container(
              margin: EdgeInsets.only(top: 8),
              child: Text("Appointment Details",
                  style: TextStyle(
                      height: 1.5,
                      color: Colors.black87,
                      fontFamily: FontName.frutinger,
                      fontWeight: FontWeight.w700,
                      fontSize: FontSize.extraLarge)),
            ),
            Text(
                widget.appointmentListModel!.appointmentDetails![widget.index]
                    .appointmentStatus,
                style: TextStyle(
                    color: widget
                                .appointmentListModel!
                                .appointmentDetails![widget.index]
                                .appointmentStatus ==
                            'Approved'
                        ? AppColors.aquaGreen
                        : AppColors.orange,
                    fontFamily: FontName.frutinger,
                    fontWeight: FontWeight.w600,
                    fontSize: FontSize.normal)),
          ],
        ),
        actions: [
          Container(
              margin: EdgeInsets.only(right: 24, top: 8),
              child: SvgPicture.asset(SVGAsset.reminder, color: Colors.black)),
        ],
      ),
    );
  }
}
