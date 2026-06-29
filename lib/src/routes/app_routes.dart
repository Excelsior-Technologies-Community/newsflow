part of 'app_pages.dart';

abstract class Routes {
  Routes._();
  static const splash = _Paths.splash;
  static const dashboard = _Paths.dashboard;
  static const home = _Paths.home;
  static const login = _Paths.login;
  static const register = _Paths.register;
  static const forgotPassword = _Paths.forgotPassword;
  static const otpVerify = _Paths.otpVerify;
  static const resetPassword = _Paths.resetPassword;
  static const bookmarks = _Paths.bookmarks;
  static const sources = _Paths.sources;
  static const profile = _Paths.profile;
  static const editProfile = _Paths.editProfile;
  static const changePassword = _Paths.changePassword;
  static const history = _Paths.history;
  static const newsDetail = _Paths.newsDetail;
  static const about = _Paths.about;
}

abstract class _Paths {
  _Paths._();
  static const splash = '/splash';
  static const dashboard = '/dashboard';
  static const home = '/home';
  static const login = '/login';
  static const register = '/register';
  static const forgotPassword = '/forgot-password';
  static const otpVerify = '/otp-verify';
  static const resetPassword = '/reset-password';
  static const bookmarks = '/bookmarks';
  static const sources = '/sources';
  static const profile = '/profile';
  static const editProfile = '/edit-profile';
  static const changePassword = '/change-password';
  static const history = '/history';
  static const newsDetail = '/news-detail';
  static const about = '/about';
}
