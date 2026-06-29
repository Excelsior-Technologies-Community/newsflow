import 'package:get/get.dart';
import '../controllers/bookmarks_controller.dart';

class BookmarksBinding extends Bindings {
  @override
  void dependencies() {
    // Controller is already initialized in HomeBinding, but lazyPut handles re-injection if needed
    if (!Get.isRegistered<BookmarksController>()) {
      Get.lazyPut<BookmarksController>(() => BookmarksController());
    }
  }
}
