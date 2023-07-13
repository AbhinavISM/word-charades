import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yayscribbl/Screens/home_screen.dart';
import 'package:yayscribbl/Screens/login/auth_service.dart';
import 'package:yayscribbl/main.dart';

import '../../auth_response_sealed.dart';
import 'current_user_state.dart';
import 'login_page_state.dart';

final loginPageVMProvider =
    ChangeNotifierProvider.autoDispose<LoginPageVM>((ref) => LoginPageVM(
          ref.watch(scaffoldMessengerKeyProvider),
          ref.watch(navigatorKeyProvider),
          ref.watch(authServiceProvider),
          ref.watch(loginPageStateProvider),
          ref.watch(currentUserStateProvider),
        ));

class LoginPageVM extends ChangeNotifier {
  final LoginPageState _loginPageState;
  final CurrentUserState _currentUserState;
  final GlobalKey<ScaffoldMessengerState> _rootScaffoldMessengerKey;
  final GlobalKey<NavigatorState> _navigatorKey;
  final AuthService _authService;
  final emailTextController = TextEditingController();
  final passwordTextController = TextEditingController();

  bool get isLoading {
    return _loginPageState.getIsLoading;
  }

  LoginPageVM(
    this._rootScaffoldMessengerKey,
    this._navigatorKey,
    this._authService,
    this._loginPageState,
    this._currentUserState,
  );

  void employeeLogin(String employeeId, String password) async {
    _loginPageState.setIsLoading = true;
    AuthResponse authResponse =
        await _authService.logInwithIDAndPassword(employeeId, password);
    switch (authResponse) {
      case AuthPass():
        _currentUserState.setCurrentUser = authResponse.thisEmployee;
        _rootScaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(
            content: Text(authResponse.message!),
          ),
        );
        _navigatorKey.currentState?.pushReplacement(
          MaterialPageRoute(builder: (BuildContext context) {
            return const MyHomePage();
          }),
        );
      case AuthFail():
        _rootScaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(
            content: Text(authResponse.message!),
          ),
        );
    }
    _loginPageState.setIsLoading = false;
  }
}
