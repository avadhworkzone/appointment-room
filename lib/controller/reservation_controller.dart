import 'package:get/get.dart';
import '../database/db_helper.dart';
import '../model/reservation_model.dart';

class ReservationController extends GetxController {
  var reservationList = <ReservationModel>[].obs;
  var isProcessing = false.obs; // ✅ Prevents multiple writes at once

  @override
  void onInit() {
    super.onInit();
    fetchReservations();
  }

  /// ✅ **Optimized Fetch Method (No Excessive Reads)**
  fetchReservations() async {
    if (isProcessing.value) return; // ✅ Prevents multiple fetches at once
    isProcessing.value = true;

    final reservations = await DBHelper.getReservations();
    reservationList.assignAll(reservations.map((e) => ReservationModel.fromMap(e)).toList());

    isProcessing.value = false;
  }

  /// ✅ **Transaction-Based Insert**
  Future<void> addReservation(ReservationModel reservation) async {
    if (isProcessing.value) return;
    isProcessing.value = true;

    await DBHelper.database.then((db) async {
      await db.transaction((txn) async {
        await txn.insert('Reservations', reservation.toMap());
      });
    });

    await fetchReservations();
    isProcessing.value = false;
  }

  /// ✅ **Transaction-Based Update**
  Future<void> updateReservation(ReservationModel reservation) async {
    if (isProcessing.value) return;
    isProcessing.value = true;

    await DBHelper.database.then((db) async {
      await db.transaction((txn) async {
        await txn.update('Reservations', reservation.toMap(), where: 'id = ?', whereArgs: [reservation.id]);
      });
    });

    await fetchReservations();
    isProcessing.value = false;
  }

  /// ✅ **Transaction-Based Delete**
  Future<void> deleteReservation(int id) async {
    if (isProcessing.value) return;
    isProcessing.value = true;

    await DBHelper.database.then((db) async {
      await db.transaction((txn) async {
        await txn.delete('Reservations', where: 'id = ?', whereArgs: [id]);
      });
    });

    await fetchReservations();
    isProcessing.value = false;
  }
}
