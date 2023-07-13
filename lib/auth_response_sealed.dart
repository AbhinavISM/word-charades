sealed class AuthResponse<T> {
  final String? message;
  AuthResponse({this.message});
}

class AuthFail<T> extends AuthResponse<T> {
  AuthFail({super.message});
}

class AuthPass<T> extends AuthResponse<T> {
  final T thisEmployee;
  AuthPass(this.thisEmployee, {super.message});
}
