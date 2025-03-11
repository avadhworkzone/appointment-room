import 'package:get/get.dart';
import '../controller/user_controller.dart';
import '../controller/room_controller.dart';
import '../controller/reservation_controller.dart';

class BadgeController extends GetxController {
  final UserController userController = Get.find();
  final RoomController roomController = Get.find();
  final ReservationController reservationController = Get.find();

  var calendarBadge = 0.obs;
  var roomsBadge = 0.obs;
  var reservationsBadge = 0.obs;
  var usersBadge = 0.obs;
  var settingsBadge = 0.obs;

  @override
  void onInit() {
    super.onInit();
    updateBadgeCounts(); // ✅ Initial update

    // ✅ Update badge counts when list updates (without triggering unnecessary fetches)
    ever(reservationController.reservationList, (_) => updateBadgeCounts());
    ever(userController.userList, (_) => updateBadgeCounts());
    ever(roomController.roomList, (_) => updateBadgeCounts());
  }

  /// ✅ **Optimized Badge Count Update**
  void updateBadgeCounts() {
    // 🔥 Do NOT call `fetchReservations()` inside this function, just use cached values
    calendarBadge.value = reservationController.reservationList.length;
    roomsBadge.value = roomController.roomList.length;
    reservationsBadge.value = reservationController.reservationList
       .length;
    usersBadge.value = userController.userList.length;
    settingsBadge.value = 0; // Reserved for future updates
  }
}
