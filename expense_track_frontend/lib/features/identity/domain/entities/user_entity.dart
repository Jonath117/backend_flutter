class UserEntity {
  final String id;
  final String firstName;
  final String lastName;
  final String email;

  UserEntity({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
  });

  factory UserEntity.fromJwtPayload(Map<String, dynamic> payload) {
    return UserEntity(
      id: payload['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier'] ?? payload['sub'] ?? '',
      firstName: payload['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/givenname'] ?? payload['given_name'] ?? payload['name'] ?? '',
      lastName: payload['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/surname'] ?? payload['family_name'] ?? '',
      email: payload['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress'] ?? payload['email'] ?? '',
    );
  }
}
