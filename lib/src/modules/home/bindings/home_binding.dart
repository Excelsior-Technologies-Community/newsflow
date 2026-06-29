import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../../bookmarks/controllers/bookmarks_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(() => HomeController());
    // Initialize BookmarksController so it's available for the news cards
    Get.put<BookmarksController>(BookmarksController(), permanent: true);
  }
}
