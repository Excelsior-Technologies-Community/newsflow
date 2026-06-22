import 'package:get/get.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

enum ViewState { initial, loading, success, empty, error, noInternet }

abstract class BaseController extends GetxController {
  final _state = ViewState.initial.obs;
  ViewState get state => _state.value;
  set state(ViewState value) => _state.value = value;

  final _errorMessage = ''.obs;
  String get errorMessage => _errorMessage.value;
  set errorMessage(String value) => _errorMessage.value = value;

  @override
  void onInit() {
    super.onInit();
    checkConnectivity();
  }

  Future<bool> checkConnectivity() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      state = ViewState.noInternet;
      return false;
    }
    return true;
  }
}
