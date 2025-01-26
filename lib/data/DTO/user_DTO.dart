class UserDto {
  bool contactEmail;
  bool contactPhone;
  String email;
  String fullName;
  String phoneNumber;

  UserDto({
    required this.contactEmail,
    required this.contactPhone,
    required this.email,
    required this.fullName,
    required this.phoneNumber,
  });

  factory UserDto.fromJson(Map<String, dynamic> json) {
    return UserDto(
      contactEmail: json['contactEmail'],
      contactPhone: json['contactPhone'],
      email: json['email'],
      fullName: json['fullName'],
      phoneNumber: json['phoneNumber'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'contactEmail': contactEmail,
      'contactPhone': contactPhone,
      'email': email,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
    };
  }
}
