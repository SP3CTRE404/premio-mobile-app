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

  RegisterRequest({
    required this.email,
    required this.password,
    required this.fullName,
    this.dateOfBirth,
    required this.createHousehold,
    required this.householdName,
  });

  Map<String, dynamic> toJson() => {
    'email': email,
    'password': password,
    'fullName': fullName,
    'dateOfBirth': dateOfBirth?.toIso8601String().split('T').first,
    'createHousehold': createHousehold,
    'householdName': householdName,
  };
}
