import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:vlcc/resources/apiHandler/api_url/api_url.dart';
import 'package:vlcc/resources/app_colors.dart';
import 'package:vlcc/resources/assets_path.dart';
import 'package:vlcc/resources/common_strings.dart';
import 'package:vlcc/resources/dimensions.dart';
import 'package:vlcc/widgets/heading_title_text.dart';

class About extends StatelessWidget {
  const About({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    return Scaffold(
      // backgroundColor: AppColors.backgroundColor,
      // appBar: PreferredSize(
      //   preferredSize: Size.fromHeight(60),
      //   child: AppBar(
      //     backgroundColor: AppColors.backgroundColor,
      //     elevation: 0,
      //     centerTitle: true,
      //     automaticallyImplyLeading: false,
      //     leading: Transform.scale(
      //       scale: 1.4,
      //       child: Container(
      //         margin: EdgeInsets.only(left: 24, top: 12, bottom: 12),
      //         decoration: BoxDecoration(
      //             border: Border.all(width: 1, color: AppColors.backBorder),
      //             borderRadius: BorderRadius.circular(8)),
      //         child: IconButton(
      //           onPressed: () {
      //             Navigator.pop(context);
      //           },
      //           icon: SvgPicture.asset(SVGAsset.backButton),
      //         ),
      //       ),
      //     ),
      //   ),
      // ),
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return [
            SliverAppBar(
              // expandedHeight: 130,
              // flexibleSpace: FlexibleSpaceBar(
              //   titlePadding: EdgeInsets.only(left: 24),
              //   title: Text('Terms and Conditions'),
              // ),
              pinned: true,
              floating: true,
              backgroundColor: AppColors.backgroundColor,
              title: Text(
                'VLCC',
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: AppColors.logoOrange,
                  fontWeight: FontWeight.w700,
                  fontSize: FontSize.heading,
                  fontFamily: FontName.frutinger,
                ),
              ),
              centerTitle: false,
              leading: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(width: 14),
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: EdgeInsets.all(PaddingSize.small),
                      decoration: BoxDecoration(
                          border:
                              Border.all(width: 1, color: AppColors.backBorder),
                          borderRadius: BorderRadius.circular(8)),
                      child: Icon(
                        Icons.keyboard_backspace,
                        size: 24,
                        color: AppColors.profileEnabled,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ];
        },
        body: body(context),
      ),
    );
  }

  Widget body(BuildContext context) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HeadingTitleText(fontSize: FontSize.heading, title: 'About us'),
              SizedBox(
                height: 32,
              ),
              Text(ApiUrl.aboutSectionInfo)
            ],
          ),
        ),
      );
}
