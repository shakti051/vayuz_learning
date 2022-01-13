import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';
import 'package:vlcc/expert/future_consultation.dart';
import 'package:vlcc/models/appointment_expert_model.dart';
import 'package:vlcc/resources/app_colors.dart';
import 'package:vlcc/resources/dimensions.dart';
import 'package:vlcc/screens/appointments/upcoming_general.dart';
import 'package:vlcc/widgets/nodata.dart';
import 'expert_view_details.dart';

class UpcomingConsultationExpert extends StatefulWidget {
  AppointmentExpertModel? appointmentExpertModel;
  int firstConsultation;
  bool consultationFound;
  UpcomingConsultationExpert(
      {Key? key,
      this.appointmentExpertModel,
      this.firstConsultation = 0,
      this.consultationFound = false})
      : super(key: key);

  @override
  _UpcomingConsultationExpertState createState() =>
      _UpcomingConsultationExpertState();
}

class _UpcomingConsultationExpertState
    extends State<UpcomingConsultationExpert> {
  final DateFormat _dateFormatter = DateFormat('MMM dd, yyyy');

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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: EdgeInsets.symmetric(horizontal: MarginSize.defaulty),
          child: Row(
            children: [
              Text(
                "Upcoming consultation",
                style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w700,
                    fontSize: FontSize.large),
              ),
              Spacer(),
              Visibility(
                visible: widget.appointmentExpertModel!
                            .appointmentexpertDetails!.length >
                        1
                    ? true
                    : false,
                child: InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          PageTransition(
                              type: PageTransitionType.rightToLeft,
                              child: FutureConsultaion(
                                  appointmentExpertModel:
                                      widget.appointmentExpertModel)));
                    },
                    child: Icon(Icons.arrow_forward)),
              )
            ],
          ),
        ),
        SizedBox(height: 20),
        widget.consultationFound
            ? Container(
                margin: EdgeInsets.only(
                    right: MarginSize.defaulty,
                    left: MarginSize.defaulty,
                    bottom: MarginSize.normal),
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
                        child: Image.asset("assets/images/rounded.png")),
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
                              Flexible(
                                child: Text(
                                  widget
                                      .appointmentExpertModel!
                                      .appointmentexpertDetails![
                                          widget.firstConsultation]
                                      .clientname!,
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
                                    _dateFormatter.format(DateTime.parse(widget
                                        .appointmentExpertModel!
                                        .appointmentexpertDetails![
                                            widget.firstConsultation]
                                        .appointmentDate!)),
                                    style: TextStyle(
                                        color: AppColors.orange,
                                        fontWeight: FontWeight.w600,
                                        fontSize: FontSize.small),
                                  ),
                                  Text(
                                    widget
                                        .appointmentExpertModel!
                                        .appointmentexpertDetails![
                                            widget.firstConsultation]
                                        .appointmentStartTime!,
                                    style: TextStyle(
                                        color: AppColors.orange,
                                        fontWeight: FontWeight.w600,
                                        fontSize: FontSize.small),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(
                                vertical: MarginSize.small),
                            child: Text(
                              widget
                                  .appointmentExpertModel!
                                  .appointmentexpertDetails![
                                      widget.firstConsultation]
                                  .bookingId!,
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: FontSize.normal),
                            ),
                          ),
                          Text(
                            widget
                                .appointmentExpertModel!
                                .appointmentexpertDetails![
                                    widget.firstConsultation]
                                .appointmentServiceexpertDtl![0]
                                .serviceName!,
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
                                        builder: (context) => ExpertViewDetails(
                                            appointmentExpertModel:
                                                widget.appointmentExpertModel,
                                            index: widget.firstConsultation)),
                                  );
                                },
                                child: Container(
                                    margin: const EdgeInsets.symmetric(
                                        vertical: MarginSize.small),
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
                              GestureDetector(
                                onTap: () {},
                                child: SvgPicture.asset(
                                  "assets/images/reminder.svg",
                                  color: Colors.grey,
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              )
            // ignore: prefer_const_constructors
            : NoDataScreen(noDataSelect: NoDataSelectType.upcomingAppointment),
      ],
    );
  }
}
