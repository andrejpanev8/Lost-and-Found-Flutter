import 'package:flutter/material.dart';

import '../../utils/color_constants.dart';

// Fix left right paddings
Widget pageTitleWidget({
  required String title,
}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Expanded(
        child: Container(
          margin: const EdgeInsets.only(right: 8),
          height: 2,
          color: blackColor,
        ),
      ),
      Text(title),
      Expanded(
        child: Container(
          margin: const EdgeInsets.only(left: 8),
          height: 2,
          color: blackColor,
        ),
      ),
    ],
  );
}
