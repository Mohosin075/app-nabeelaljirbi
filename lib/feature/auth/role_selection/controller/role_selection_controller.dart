import 'package:get/get.dart';

class RoleSelectionController extends GetxController {
  RxString? selectedRole = ''.obs;

  void selectRole(String role) {
    selectedRole?.value = role;
    update();
  }
}