import 'package:flutter/material.dart';
import 'package:lost_and_found_app/service/auth_service.dart';

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
              _navigate(context);
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

void _navigate(BuildContext context) {
  Navigator.of(context)
      .pushNamedAndRemoveUntil("/", (Route<dynamic> route) => false);

  if (AuthService().currentUser != null) {
    Navigator.of(context).pushNamed("/profile");
    return;
  }
  Navigator.of(context).pushNamed("/login");
}
