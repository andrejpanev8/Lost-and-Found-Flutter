import 'package:flutter/material.dart';
import 'package:lost_and_found_app/providers/user_info_provider.dart';

import '../../utils/color_constants.dart';
import '../../utils/text_styles.dart';

PreferredSizeWidget customAppBar({
  required BuildContext context,
  final String? appBarText,
  final bool userCircleVisible = true,
  final UserProvider? provider,
  bool? userProfileScreen = false,
}) {
  return AppBar(
    title: Text(
      appBarText ?? "Lost And Found",
      style: StyledText().appBarText(),
    ),
    backgroundColor: greenPrimary,
    leading: userProfileScreen == true ? _backButton(context) : null,
    actions: [
      if (userCircleVisible)
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () {
              UserProvider().navigate(context, "/profile");
            },
            child: _profilePic(provider),
          ),
        ),
    ],
  );
}

Widget _profilePic(UserProvider? provider) {
  return CircleAvatar(
    backgroundColor: greenPrimary,
    radius: 25,
    child: ClipOval(
      child: Image.network(
        provider != null
            ? provider.profilePicture
            : UserProvider().profilePicture,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) {
            return child;
          } else {
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        (loadingProgress.expectedTotalBytes ?? 1)
                    : null,
              ),
            );
          }
        },
      ),
    ),
  );
}

Widget _backButton(BuildContext context) {
  return IconButton(
    icon: const Icon(Icons.arrow_back, color: Colors.white),
    onPressed: () {
      Navigator.pop(context);
    },
  );
}
