import 'dart:developer';

import 'package:cal_room/controller/room_controller.dart';
import 'package:cal_room/widgets/add_edit_reservation_bottom_sheet.dart';
import 'package:cal_room/widgets/reservation_card_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/reservation_controller.dart';

class ReservationScreen extends StatefulWidget {
  const ReservationScreen({super.key});

  @override
  State<ReservationScreen> createState() => _ReservationScreenState();
}

class _ReservationScreenState extends State<ReservationScreen> {
  final ReservationController reservationController =
      Get.find<ReservationController>();

  @override
  void initState() {
    initMethod();
    RoomController.to.fetchRooms();
    super.initState();
  }

  initMethod() async {
    await reservationController.fetchReservations();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Reservations")),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await addEditReservationBottomSheet();
          await reservationController.fetchReservations(); // Refresh the list
        },
        child: Icon(Icons.add),
      ),
      body: Obx(() => reservationController.reservationList.isEmpty
          ? Center(child: Text("No reservations found. Add a new reservation!"))
          : ListView.builder(
              itemCount: reservationController.reservationList.length,
              itemBuilder: (context, index) {
                final reservation =
                    reservationController.reservationList[index];
                log("---reservation----$reservation");
                return ReservationCardView(reservation:reservation);
              },
            )),
    );
  }

}
