// ignore_for_file: unrelated_type_equality_checks
import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vlcc/models/appointment_expert_model.dart';
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
import 'package:vlcc/screens/appointments/reshedule_appointment.dart';
import 'package:vlcc/screens/enable_x/video_call.dart';
import 'package:vlcc/widgets/appointment_widgets/cancel_dialouge.dart';
import 'package:vlcc/widgets/gradient_button.dart';

class ExpertViewDetails extends StatefulWidget {
  int index;
  final bool isVideoCall;
  final AppointmentExpertModel? appointmentExpertModel;

  ExpertViewDetails(
      {Key? key,
      this.index = 0,
      this.appointmentExpertModel,
      this.isVideoCall = false})
      : super(key: key);

  @override
  _ExpertViewDetailsState createState() => _ExpertViewDetailsState();
}

class _ExpertViewDetailsState extends State<ExpertViewDetails> {
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

  String _url = 'Attached Documents';
  void _launchURL() async {
    String url = widget.appointmentExpertModel!
        .appointmentexpertDetails![widget.index].appointmentAttDoc!;
    _url = url.replaceAll(r'\', '\\');
    if (!await launch(_url)) throw 'Could not launch $_url';
  }

  var header = kTry
      ? {
          "x-app-id": kAppId,
          "x-app-key": kAppkey,
          "Content-Type": "application/json"
        }
      : {"Content-Type": "application/json"};

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

  Future<void> updateRoomID(
      {required String roomID, required String token}) async {
    var body = {
      "appointment_token": token,
      "appointment_room": "61cae93c742a2609a7896d40",
      "auth_token": sharedPrefs.authToken,
      "device_id": sharedPrefs.deviceId,
      "client_mobile": sharedPrefs.mobileNum,
      "appointment_id": widget.appointmentExpertModel!
          .appointmentexpertDetails![widget.index].appointmentId,
    };
    services.callApi(body, ApiUrl.videoAppointmentTokenUpdate);
  }

  Future<void> createToken() async {
//     var roomId = await getRoomID();

    var value = {
      'user_ref': "22362",
      "roomId": "61caee4c8f9c400b2c3d8a1e",
      "role": "participant",
      "name": "kanishaka",
      "desc": "hello",
    };
    // log(jsonEncode(value).toString());
    var response = await http.post(
        Uri.parse(
          "${kBaseURL}createToken",
        ), // replace FQDN with Your Server API URL
        headers: header,
        body: jsonEncode(value));
    log(response.body.toString());
//     if (response.statusCode == 200) {
//       print(response.body);
    Map<String, dynamic> user = jsonDecode(response.body);
    setState(() => token = user['token'].toString());

    print(token);
//       if (sharedPrefs.employeCode.isEmpty) {
//         await updateRoomID(roomID: roomId, token: token);
//       }
// //      await updateRoomID(roomID: roomId, token: token);
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
//       return response.body;
//     } else {
//       throw Exception('Failed to load post');
//     }
  }

  final TextEditingController _problemDesc = TextEditingController();
  final Services _services = Services();
  CancelAppointmentModel? cancelAppointmentModel;
  DateTime _currentDate = DateTime.now();
  TimeOfDay? time;
  TimeOfDay? picked;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteShodow,
      appBar: PreferredSize(
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
                  widget.appointmentExpertModel!
                      .appointmentexpertDetails![widget.index].appointmentStatus
                      .toString(),
                  style: TextStyle(
                      color: widget
                                  .appointmentExpertModel!
                                  .appointmentexpertDetails![widget.index]
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
                child: SvgPicture.asset(SVGAsset.notifyOutline)),
          ],
        ),
      ),
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
                    padding: const EdgeInsets.only(top: PaddingSize.normal),
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
                            //  height: 56,
                            width: 56,
                            margin: EdgeInsets.all(MarginSize.middle),
                            child: Image.asset("assets/images/rounded.png")),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin:
                                    EdgeInsets.only(right: MarginSize.middle),
                                child: Text(
                                    widget
                                        .appointmentExpertModel!
                                        .appointmentexpertDetails![widget.index]
                                        .clientname!,
                                    style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: FontSize.defaultFont)),
                              ),
                              Container(
                                margin: EdgeInsets.symmetric(
                                    vertical: MarginSize.small),
                                child: Text(
                                  widget
                                      .appointmentExpertModel!
                                      .appointmentexpertDetails![widget.index]
                                      .centerCode!,
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: FontSize.normal),
                                ),
                              ),
                              RichText(
                                text: TextSpan(
                                  text: widget
                                      .appointmentExpertModel!
                                      .appointmentexpertDetails![widget.index]
                                      .centerName,
                                  style: TextStyle(
                                      color: Colors.grey,
                                      fontWeight: FontWeight.w600,
                                      fontSize: FontSize.normal),
                                ),
                              ),
                              SizedBox(height: 15)
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
                          child: Text("Booking Number",
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
                                          .appointmentExpertModel!
                                          .appointmentexpertDetails![
                                              widget.index]
                                          .bookingNumber!,
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
                          child: Text("Center Name",
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
                                      .appointmentExpertModel!
                                      .appointmentexpertDetails![widget.index]
                                      .centerName!,
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
                                                widget
                                                    .appointmentExpertModel!
                                                    .appointmentexpertDetails![
                                                        widget.index]
                                                    .appointmentDate!,
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
                                                    .appointmentExpertModel!
                                                    .appointmentexpertDetails![
                                                        widget.index]
                                                    .appointmentStartTime
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
                      ],
                    )),
                SizedBox(height: 24),
                Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  shadowColor: AppColors.whiteShodow,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        margin: EdgeInsets.only(left: 12, top: 12),
                        child: Text("Problem description (Optional)",
                            style: TextStyle(
                                fontFamily: FontName.frutinger,
                                fontWeight: FontWeight.w600,
                                fontSize: FontSize.normal)),
                      ),
                      SizedBox(height: 4),
                      Visibility(
                        visible: widget
                                    .appointmentExpertModel!
                                    .appointmentexpertDetails![widget.index]
                                    .appointmentRemark ==
                                ""
                            ? false
                            : true,
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 12),
                          padding: EdgeInsets.all(12),
                          width: double.infinity,
                          decoration: BoxDecoration(
                              border: Border.all(
                                  width: 1, color: AppColors.backBorder),
                              borderRadius: BorderRadius.circular(12)),
                          child: Text(
                              widget
                                  .appointmentExpertModel!
                                  .appointmentexpertDetails![widget.index]
                                  .appointmentRemark!,
                              style: TextStyle(
                                  height: 1.5,
                                  fontFamily: FontName.frutinger,
                                  fontWeight: FontWeight.w400,
                                  fontSize: FontSize.large)),
                        ),
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      Container(
                        margin: EdgeInsets.only(left: 12),
                        child: Text("Attachments (Optional)",
                            style: TextStyle(
                                fontFamily: FontName.frutinger,
                                fontWeight: FontWeight.w600,
                                fontSize: FontSize.normal)),
                      ),
                      SizedBox(height: 24),
                      GestureDetector(
                        onTap: () {
                          _launchURL();
                        },
                        child: Visibility(
                          visible: widget
                                      .appointmentExpertModel!
                                      .appointmentexpertDetails![widget.index]
                                      .appointmentAttDoc ==
                                  ""
                              ? false
                              : true,
                          child: Container(
                              margin: EdgeInsets.symmetric(
                                  horizontal: MarginSize.normal),
                              height: 56,
                              decoration: BoxDecoration(
                                  color: AppColors.greyBackground,
                                  borderRadius: BorderRadius.circular(4)),
                              child: Row(
                                children: [
                                  Container(
                                      margin: EdgeInsets.symmetric(
                                          horizontal: MarginSize.normal),
                                      child: Icon(Icons.picture_as_pdf,
                                          color: Colors.redAccent)),
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(_url,
                                            style: TextStyle(
                                                fontFamily: FontName.frutinger,
                                                fontWeight: FontWeight.w400,
                                                fontSize: FontSize.normal)),
                                        // Text("12 kb",
                                        //     style: TextStyle(
                                        //         color: Colors.grey,
                                        //         fontFamily: FontName.frutinger,
                                        //         fontWeight: FontWeight.w400,
                                        //         fontSize: FontSize.small)),
                                      ],
                                    ),
                                  ),
                                  // CircleAvatar(
                                  //     radius: 12,
                                  //     backgroundColor: Colors.grey,
                                  //     child: Icon(
                                  //       Icons.clear,
                                  //       color: Colors.white,
                                  //     )),
                                  SizedBox(width: 16)
                                ],
                              )),
                        ),
                      ),
                      SizedBox(height: 12)
                    ],
                  ),
                ),
                SizedBox(height: 24),
                GradientButton(
                    onPressed: () {
                      // Navigator.pop(context);
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //       builder: (context) => BookingAppointment()),
                      // );
                      // permissionAccess();
                      joinRoomValidations();
                      createToken();
                      if (widget.isVideoCall) {
                        // if (isAfterThisMoment(
                        //   DateTime.fromMillisecondsSinceEpoch(widget
                        //           .appointmentExpertModel!
                        //           .appointmentexpertDetails![widget.index]
                        //           .appointmentStartDateTime! *
                        //       1000),
                        // )) {
                        //   joinRoomValidations();
                        //   createToken();
                        // } else {

                        //   showToast(
                        //       "You will be allowed to join at the selected time duration only.");
                        // }
                      } else {
                        //  Navigator.pop(context);
                      }
                    },
                    child: Text("Continue",
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: FontSize.large,
                            color: Colors.white))),
                SizedBox(height: 42)
              ],
            ),
          ),
        ),
      )),
    );
  }
}
