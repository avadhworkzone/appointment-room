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
    updateBadgeCounts();

    // Automatically update badges whenever the lists change
    ever(reservationController.reservationList, (_) => updateBadgeCounts());
    ever(userController.userList, (_) => updateBadgeCounts());
    ever(roomController.roomList, (_) => updateBadgeCounts());
  }

  void updateBadgeCounts() {
    reservationController.fetchReservations();
    userController.fetchUsers();
    roomController.fetchRooms();

    Future.delayed(Duration(milliseconds: 500), () {
      calendarBadge.value = reservationController.reservationList.length;
      roomsBadge.value = roomController.roomList.length;
      reservationsBadge.value = reservationController.reservationList
          .where((res) => res.checkin == DateTime.now().toString())
          .length;
      usersBadge.value = userController.userList.length;
      settingsBadge.value = 0; // Reserved for future updates
    });
  }
}
