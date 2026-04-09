class User {
  final int id;
  final String email;
  final String fullName;
  final String? phoneNumber;
  final int? householdId;
  final bool isHouseholdAdmin; // Matches backend's householdAdmin
  final String? profilePicture; // NEW: Added Profile Picture field

  User({
    required this.id,
    required this.email,
    required this.fullName,
    this.phoneNumber,
    this.householdId,
    this.isHouseholdAdmin = false,
    this.profilePicture,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    int? parsedHouseholdId;
    if (json['householdId'] != null) {
      parsedHouseholdId = json['householdId'] as int;
    } else if (json['household'] != null && json['household'] is Map) {
      parsedHouseholdId = json['household']['id'] as int?;
    }

    return User(
      id: json['id'] as int,
      email: json['email'] as String,
      fullName: json['fullName'] as String,
      phoneNumber: json['phoneNumber'] as String?,
      householdId: parsedHouseholdId,
      isHouseholdAdmin: json['householdAdmin'] as bool? ?? false,
      profilePicture: json['profilePicture'] as String?, // Map from backend
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'fullName': fullName,
        'phoneNumber': phoneNumber,
        'householdId': householdId,
        'householdAdmin': isHouseholdAdmin,
        'profilePicture': profilePicture,
      };
}