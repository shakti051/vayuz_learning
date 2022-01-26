import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String? inputText;
  final double? height;
  CustomButton({this.inputText, this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width / 1.4,
      height: height,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          color: const Color(0xff9450e7)),
      child: MaterialButton(
        onPressed: () {},
        child: Text(
          inputText!,
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
