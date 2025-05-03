abstract class SignupEvent {}

class SignupSubmitted extends SignupEvent {
  final String username;
  final String password;
  final String fullname;

  SignupSubmitted({
    required this.username,
    required this.password,
    required this.fullname,
  });
}
