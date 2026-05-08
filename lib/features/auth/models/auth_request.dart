class LoginRequest {
  final String email;
  final String password;

  LoginRequest({required this.email, required this.password});

  Map<String, dynamic> toJson() => {
    'email': email,
    'password': password,
  };
}

class RegisterRequest {
  final String email;
  final String password;
  final String fullName;
  final DateTime? dateOfBirth;
  final bool createHousehold;
  final String householdName;
  final String? country;
  final String? currencySymbol;

  RegisterRequest({
    required this.email,
    required this.password,
    required this.fullName,
    this.dateOfBirth,
    required this.createHousehold,
    required this.householdName,
    this.country,
    this.currencySymbol,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'email': email,
      'password': password,
      'fullName': fullName,
      'dateOfBirth': dateOfBirth?.toIso8601String().split('T').first,
      'createHousehold': createHousehold,
      'householdName': householdName,
    };
    if (country != null) map['country'] = country;
    if (currencySymbol != null) map['currencySymbol'] = currencySymbol;
    return map;
  }
}
