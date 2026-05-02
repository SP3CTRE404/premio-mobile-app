class User {
  final int id;
  final String email;
  final String fullName;
  final String? phoneNumber;
  final int? householdId;
  final bool isHouseholdAdmin; // Matches backend's householdAdmin
  final String? profilePicture; // NEW: Added Profile Picture field
  final String currencySymbol;
  final DateTime? dateOfBirth;

  User({
    required this.id,
    required this.email,
    required this.fullName,
    this.phoneNumber,
    this.householdId,
    this.isHouseholdAdmin = false,
    this.profilePicture,
    this.currencySymbol = '₹',
    this.dateOfBirth,
  });

  int get age => calculateAge(dateOfBirth);

  static int calculateAge(DateTime? dob) {
    if (dob == null) return -1;
    final now = DateTime.now();
    int age = now.year - dob.year;
    if (now.month < dob.month ||
        (now.month == dob.month && now.day < dob.day)) {
      age--;
    }
    return age;
  }

  static int getAgeFromJson(Map<String, dynamic> json) {
    // Check for direct age field first as it's the most explicit
    final ageRaw = json['age'];
    if (ageRaw != null) {
      if (ageRaw is int) return ageRaw;
      if (ageRaw is String) return int.tryParse(ageRaw) ?? -1;
    }

    // Fallback to parsing from various DOB keys
    final dobRaw = json['dateOfBirth'] ?? 
                 json['date_of_birth'] ?? 
                 json['dob'] ?? 
                 json['birthday'] ?? 
                 json['birthDate'] ??
                 json['birth_date'];
    if (dobRaw == null) return -1;
    try {
      return calculateAge(DateTime.parse(dobRaw.toString()));
    } catch (_) {
      return -1;
    }
  }

  factory User.fromJson(Map<String, dynamic> json) {
    int? parsedHouseholdId;
    if (json['householdId'] != null) {
      parsedHouseholdId = json['householdId'] as int;
    } else if (json['household'] != null && json['household'] is Map) {
      parsedHouseholdId = json['household']['id'] as int?;
    }

    // Robustly parse DOB from multiple possible key names (camelCase, snake_case, short)
    final dobRaw = json['dateOfBirth'] ?? json['date_of_birth'] ?? json['dob'];
    final parsedDob = dobRaw != null ? DateTime.parse(dobRaw.toString()) : null;

    return User(
      id: json['id'] as int,
      email: json['email'] as String,
      fullName: json['fullName'] as String,
      phoneNumber: json['phoneNumber'] as String?,
      householdId: parsedHouseholdId,
      isHouseholdAdmin: json['householdAdmin'] as bool? ?? false,
      profilePicture: json['profilePicture'] as String?, // Map from backend
      currencySymbol: json['currencySymbol'] as String? ?? '₹',
      dateOfBirth: parsedDob,
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
        'currencySymbol': currencySymbol,
        'dateOfBirth': dateOfBirth?.toIso8601String(),
      };

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User &&
        other.id == id &&
        other.email == email &&
        other.fullName == fullName &&
        other.phoneNumber == phoneNumber &&
        other.householdId == householdId &&
        other.isHouseholdAdmin == isHouseholdAdmin &&
        other.profilePicture == profilePicture &&
        other.dateOfBirth == dateOfBirth;
  }

  @override
  int get hashCode => Object.hash(
        id, email, fullName, phoneNumber,
        householdId, isHouseholdAdmin, profilePicture, dateOfBirth,
      );
}