import 'dart:developer';

import 'package:cal_room/controller/room_controller.dart';
import 'package:cal_room/widgets/reservation_card_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/reservation_controller.dart';
import 'package:intl/intl.dart';

class TodayScreen extends StatefulWidget {
  const TodayScreen({super.key});

  @override
  State<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen> {
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
      appBar: AppBar(title: Text("Today")),
      body: Obx(() {
        if (reservationController.reservationList.isEmpty) {
          return Center(
              child: Text("No reservations found. Add a new reservation!"));
        }
        final now = DateFormat('yyyy-MM-dd').parse(DateTime.now().toString());
      final  reservationList= reservationController.reservationList
            .where(
              (ele) =>
                  now.isAtSameMomentAs(DateTime.parse(ele.checkin)) ||
                  now.isAtSameMomentAs(DateTime.parse(ele.checkout)) ||
                  (now.isAfter(DateTime.parse(ele.checkin)) &&
                      now.isBefore(DateTime.parse(ele.checkout))),
            )
            .toList();

        return ListView.builder(
          itemCount: reservationList.length,
          itemBuilder: (context, index) {
            final reservation = reservationList[index];
            log("---reservation----$reservation");
            return ReservationCardView(
              reservation: reservation,
              isFromToday: true,
            );
          },
        );
      }),
    );
  }
}
