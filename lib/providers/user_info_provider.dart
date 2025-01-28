import 'package:flutter/material.dart';
import 'package:lost_and_found_app/providers/items_provider.dart';
import 'package:lost_and_found_app/service/api_service.dart';
import 'package:lost_and_found_app/service/auth_service.dart';
import 'package:lost_and_found_app/utils/image_constants.dart';

import '../data/DTO/user_DTO.dart';

class UserProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  String _fullName = "Failed to fetch name";
  String _email = "Failed to fetch email";
  String _phoneNumber = "";
  String _profilePicture = defaultProfileImage;
  bool _displayEmail = true;
  bool _displayPhoneNumber = false;

  bool _displayEmailTransient = true;
  bool _displayPhoneNumberTransient = false;

  String get fullName => _fullName;
  String get email => _email;
  String get phoneNumber => _phoneNumber;
  String get profilePicture => _profilePicture;
  bool get displayEmail => _displayEmail;
  bool get displayPhoneNumber => _displayPhoneNumber;
  bool get displayEmailTransient => _displayEmailTransient;
  bool get displayPhoneTransient => _displayPhoneNumberTransient;

  UserProvider() {
    initializeUserInfo();
  }
  Future<void> initializeUserInfo() async {
    try {
      UserDto user = await _authService.getUserData();
      _fullName = user.fullName;
      _email = user.email;
      _phoneNumber = user.phoneNumber;
      _profilePicture = user.profilePicture;
      _displayEmail = _displayEmailTransient = user.contactEmail;
      _displayPhoneNumber = _displayPhoneNumberTransient = user.contactPhone;
      notifyListeners();
    } catch (e) {
      print("Failed to fetch user info: $e");
    }
  }

  void updateFullName(String newFullName) {
    _fullName = newFullName;
    notifyListeners();
  }

  void updateEmail(String newEmail) {
    _email = newEmail;
    notifyListeners();
  }

  void updatePhoneNumber(String newPhoneNumber) {
    _phoneNumber = newPhoneNumber;
    notifyListeners();
  }

  void updateProfilePicture(String profilePicturePath) async {
    _profilePicture = profilePicturePath;
    notifyListeners();
    String urlToImage =
        await ApiService().uploadImageToSupabase(profilePicturePath);
    _profilePicture = urlToImage;
    saveUserInfo();
  }

  void toggleDisplayEmail(bool value) {
    _displayEmail = value;
    notifyListeners();
  }

  void toggleDisplayPhoneNumber(bool value) {
    _displayPhoneNumber = value;
    notifyListeners();
  }

  void updateTransients(
      {required bool emailTransient, required bool phoneTransient}) {
    _displayEmailTransient = emailTransient;
    _displayPhoneNumberTransient = phoneTransient;
    notifyListeners();
  }

  String getContactInfo() {
    String contact = "";

    if (_displayEmail && _displayPhoneNumber) {
      contact = "$_email\n$_phoneNumber";
    } else if (_displayEmail) {
      contact = _email;
    } else if (_displayPhoneNumber) {
      contact = _phoneNumber;
    }

    return contact;
  }

  void saveUserInfo() {
    AuthService().updateUserProfile(
        fullName: _fullName,
        phoneNumber: _phoneNumber,
        contactEmail: _displayEmail,
        contactPhone: _displayPhoneNumber,
        profilePictureUrl: _profilePicture);
  }

  void navigate(BuildContext context, String path) {
    Navigator.of(context)
        .pushNamedAndRemoveUntil("/", (Route<dynamic> route) => false);

    if (AuthService().currentUser != null) {
      Navigator.of(context).pushNamed(path);
      return;
    }
    Navigator.of(context).pushNamed("/login");
  }

  void logOutUser() {
    AuthService().logOut();
    ItemsProvider().resetUserItems();
    _fullName = "Failed to fetch name";
    _email = "Failed to fetch email";
    _phoneNumber = "";
    _profilePicture = "";
    _displayEmail = true;
    _displayPhoneNumber = false;
    _displayEmailTransient = true;
    _displayPhoneNumberTransient = false;
    notifyListeners();
  }
}
