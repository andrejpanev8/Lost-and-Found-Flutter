import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lost_and_found_app/presentation/widgets/custom_app_bar.dart';
import 'package:lost_and_found_app/utils/color_constants.dart';
import 'package:provider/provider.dart';
import '../../providers/user_info_provider.dart';

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var provider = context.watch<UserProvider>();
    return Scaffold(
        appBar: customAppBar(
            context: context,
            appBarText: "My Profile",
            provider: provider,
            userProfileScreen: true),
        body: SingleChildScrollView(
            child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: _buildInfo(context, provider),
        )));
  }

  Widget _buildInfo(BuildContext context, UserProvider userProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // User Profile Image
        GestureDetector(
          onTap: () => _pickImage(userProvider),
          child: CircleAvatar(
            radius: 50,
            backgroundColor: whiteColor,
            backgroundImage: _profilePic(userProvider),
          ),
        ),
        const SizedBox(height: 16),
        // User Info Section
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: yellowTransparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Full Name:',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(userProvider.fullName),
              const SizedBox(height: 8),
              const Text(
                'E-Mail:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(userProvider.email),
              const SizedBox(height: 8),
              const Text(
                'Phone Number:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(userProvider.phoneNumber),
              const SizedBox(height: 8),
              const Text(
                'Display for Contact:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: userProvider.displayEmail,
                        onChanged: null, // Disabled checkbox
                      ),
                      const Text('E-Mail'),
                    ],
                  ),
                  Row(
                    children: [
                      Checkbox(
                        value: userProvider.displayPhoneNumber,
                        onChanged: null, // Disabled checkbox
                      ),
                      const Text('Phone Number'),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      userProvider.logOutUser();
                      Navigator.of(context).pushNamedAndRemoveUntil(
                          "/", (Route<dynamic> route) => false);
                    },
                    child: Text(
                      'Log out',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _showEditProfileDialog(context, userProvider);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                    ),
                    child: const Text(
                      'Edit',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  ImageProvider<Object> _profilePic(UserProvider userProvider) {
    return _isNetworkImage(userProvider.profilePicture)
        ? NetworkImage(userProvider.profilePicture)
        : FileImage(File(userProvider.profilePicture)) as ImageProvider;
  }

  Future<void> _pickImage(UserProvider provider) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      provider.updateProfilePicture(image.path);
    }
  }
}

void _showEditProfileDialog(BuildContext context, UserProvider userProvider) {
  final TextEditingController nameController =
      TextEditingController(text: userProvider.fullName);
  final TextEditingController phoneController =
      TextEditingController(text: userProvider.phoneNumber);

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Consumer<UserProvider>(
        builder: (context, provider, child) {
          return AlertDialog(
            title: const Text('Edit Profile'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Full Name'),
                  ),
                  TextField(
                    controller: phoneController,
                    decoration:
                        const InputDecoration(labelText: 'Phone Number'),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Checkbox(
                        value: provider.displayEmailTransient,
                        onChanged: (value) {
                          provider.updateTransients(
                            emailTransient: value!,
                            phoneTransient: provider.displayPhoneTransient,
                          );
                        },
                      ),
                      const Text('Display E-Mail'),
                    ],
                  ),
                  Row(
                    children: [
                      Checkbox(
                        value: provider.displayPhoneTransient,
                        onChanged: (value) {
                          provider.updateTransients(
                            emailTransient: provider.displayEmailTransient,
                            phoneTransient: value!,
                          );
                        },
                      ),
                      const Text('Display Phone Number'),
                    ],
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  // Update the UserProvider state
                  userProvider.updateFullName(nameController.text);
                  userProvider.updatePhoneNumber(phoneController.text);
                  userProvider
                      .toggleDisplayEmail(provider.displayEmailTransient);
                  userProvider
                      .toggleDisplayPhoneNumber(provider.displayPhoneTransient);
                  userProvider.saveUserInfo();
                  // Close the dialog
                  Navigator.of(context).pop();
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      );
    },
  );
}

bool _isNetworkImage(String path) {
  final uri = Uri.tryParse(path);
  return uri != null &&
      uri.hasScheme &&
      (uri.scheme == 'http' || uri.scheme == 'https');
}
