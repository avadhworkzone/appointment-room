import 'package:get/get.dart';

import '../database/db_helper.dart';
import '../model/reservation_model.dart';

class ReservationController extends GetxController {
  var reservationList = <ReservationModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchReservations();
  }

   fetchReservations() async {
    final reservations = await DBHelper.getReservations();
    reservationList.value = reservations.map((e) => ReservationModel.fromMap(e)).toList();
  }

  Future<void> addReservation(ReservationModel reservation) async {
    await DBHelper.insertReservation(reservation.toMap());
    fetchReservations();
  }

  Future<void> updateReservation(ReservationModel reservation) async {
    await DBHelper.updateReservation(reservation.toMap(), reservation.id!);
    fetchReservations();
  }

  Future<void> deleteReservation(int id) async {
    await DBHelper.deleteReservation(id);
    fetchReservations();
  }
}
