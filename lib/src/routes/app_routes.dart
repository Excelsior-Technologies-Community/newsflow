part of 'app_pages.dart';

abstract class Routes {
  Routes._();
  static const splash = _Paths.splash;
  static const home = _Paths.home;
  static const login = _Paths.login;
  static const register = _Paths.register;
  static const forgotPassword = _Paths.forgotPassword;
}

abstract class _Paths {
  _Paths._();
  static const splash = '/splash';
  static const home = '/home';
  static const login = '/login';
  static const register = '/register';
  static const forgotPassword = '/forgot-password';
}
