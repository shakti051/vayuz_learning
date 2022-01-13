import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vlcc/resources/assets_path.dart';
import 'package:vlcc/resources/dimensions.dart';

class SearchLocation extends StatelessWidget {
  final String sublocality;
  final String locality;
  const SearchLocation(
      {Key? key, required this.locality, required this.sublocality})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SvgPicture.asset(SVGAsset.locator, width: 14, height: 16),
        Container(
          margin: EdgeInsets.only(left: 8, right: 16),
          child: Text(
            "$sublocality, $locality",
            style: TextStyle(
                color: Colors.grey,
                fontFamily: 'Mulish',
                fontWeight: FontWeight.w400,
                fontSize: FontSize.normal),
          ),
        ),
        SvgPicture.asset(SVGAsset.dropdown),
      ],
    );
  }
}
