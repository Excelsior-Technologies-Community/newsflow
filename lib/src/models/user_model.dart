class UserModel {
  final int? id;
  final String firstName;
  final String lastName;
  final String email;
  final String? dob;
  final String? profilePhoto;

  UserModel({
    this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.dob,
    this.profilePhoto,
  });

  String get name => '$firstName $lastName';

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      email: json['email'] ?? '',
      dob: json['dob'],
      profilePhoto: json['profile_photo'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'dob': dob,
      'profile_photo': profilePhoto,
    };
  }
}
