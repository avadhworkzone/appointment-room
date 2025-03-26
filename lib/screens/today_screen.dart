// import 'dart:developer';
//
// import 'package:cal_room/controller/room_controller.dart';
// import 'package:cal_room/widgets/reservation_card_view.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../controller/reservation_controller.dart';
// import 'package:intl/intl.dart';
//
// class TodayScreen extends StatefulWidget {
//   const TodayScreen({super.key});
//
//   @override
//   State<TodayScreen> createState() => _TodayScreenState();
// }
//
// class _TodayScreenState extends State<TodayScreen> {
//   final ReservationController reservationController =
//       Get.find<ReservationController>();
//
//   @override
//   void initState() {
//     initMethod();
//     RoomController.to.fetchRooms();
//     super.initState();
//   }
//
//   initMethod() async {
//     await reservationController.fetchReservations();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Today")),
//       body: Obx(() {
//         if (reservationController.reservationList.isEmpty) {
//           return Center(
//               child: Text("No reservations found. Add a new reservation!"));
//         }
//         final now = DateFormat('yyyy-MM-dd').parse(DateTime.now().toString());
//       final  reservationList= reservationController.reservationList
//             .where(
//               (ele) =>
//                   now.isAtSameMomentAs(DateTime.parse(ele.checkin)) ||
//                   now.isAtSameMomentAs(DateTime.parse(ele.checkout)) ||
//                   (now.isAfter(DateTime.parse(ele.checkin)) &&
//                       now.isBefore(DateTime.parse(ele.checkout))),
//             )
//             .toList();
//
//         return ListView.builder(
//           itemCount: reservationList.length,
//           itemBuilder: (context, index) {
//             final reservation = reservationList[index];
//             log("---reservation----$reservation");
//             return ReservationCardView(
//               reservation: reservation,
//               isFromToday: true,
//             );
//           },
//         );
//       }),
//     );
//   }
// }
import 'dart:developer';

import 'package:cal_room/controller/room_controller.dart';
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
  final ReservationController reservationController = Get.find<ReservationController>();

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
      appBar: AppBar(title: const Text("Today's Reservations")),
      body: Obx(() {
        if (reservationController.reservationList.isEmpty) {
          return const Center(child: Text("No reservations found. Add a new reservation!"));
        }

        final now = DateTime.now();
        final reservationList = reservationController.reservationList.where(
              (ele) {
            final checkin = DateTime.parse(ele.checkin);
            final checkout = DateTime.parse(ele.checkout);
            return now.isAtSameMomentAs(checkin) ||
                now.isAtSameMomentAs(checkout) ||
                (now.isAfter(checkin) && now.isBefore(checkout));
          },
        ).toList();

        if (reservationList.isEmpty) {
          return const Center(child: Text("No reservations for today."));
        }

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowColor: MaterialStateProperty.all(Colors.grey.shade200),
            columns: const [
              DataColumn(label: Text('Guest Name')),
              DataColumn(label: Text('Room')),
              DataColumn(label: Text('Check-in')),
              DataColumn(label: Text('Check-out')),
              DataColumn(label: Text('pending Price')),
            ],
            rows: reservationList.map((reservation) {
              return DataRow(cells: [
                DataCell(Text(reservation.fullname ?? 'N/A')),
                DataCell(Text(reservation.roomName ?? 'N/A')),
                DataCell(Text(DateFormat('yyyy-MM-dd').format(DateTime.parse(reservation.checkin)))),
                DataCell(Text(DateFormat('yyyy-MM-dd').format(DateTime.parse(reservation.checkout)))),
                DataCell(Text('${reservation.balance ?? 0}')),
              ]);
            }).toList(),
          ),
        );
      }),
    );
  }
}
