import 'package:flutter/material.dart';
import 'package:lost_and_found_app/providers/user_info_provider.dart';

import '../../utils/color_constants.dart';
import '../../utils/text_styles.dart';

PreferredSizeWidget customAppBar({
  required BuildContext context,
  final String? appBarText,
  final bool userCircleVisible = true,
}) {
  return AppBar(
    title: Text(
      appBarText ?? "Lost And Found",
      style: StyledText().appBarText(),
    ),
    backgroundColor: greenPrimary,
    actions: [
      if (userCircleVisible)
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () {
              UserProvider().navigate(context, "/profile");
            },
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: const Icon(
                Icons.person,
                color: greenPrimary,
              ),
            ),
          ),
        ),
    ],
  );
}
