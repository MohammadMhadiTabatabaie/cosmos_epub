import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../show_epub.dart';

// ignore: must_be_immutable
class CircleButton extends StatelessWidget {
  Color backColor, fontColor, accentColor;
  int id;

  CircleButton(
      {super.key,
      required this.accentColor,
      required this.backColor,
      required this.fontColor,
      required this.id});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(1.h),
      decoration: BoxDecoration(
          //   shape: BoxShape.circle,
          border: Border.all(
              width: 1,
              color: staticThemeId == id ? Color(0xffB0276D) : Colors.grey),
          borderRadius: BorderRadius.circular(8)),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
            color: backColor, borderRadius: BorderRadius.circular(8)
            //  shape: BoxShape.circle,
            ),
        child: Center(
          child: Text(
            "ب",
            style: TextStyle(
                color: fontColor, fontSize: 24, fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }
}
