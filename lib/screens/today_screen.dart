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

import 'package:cal_room/controller/room_controller.dart';
import 'package:cal_room/screens/reservation_detail_screen.dart';
import 'package:cal_room/utils/color_utils.dart';
import 'package:cal_room/utils/string_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/reservation_controller.dart';
import 'package:intl/intl.dart';

import '../model/reservation_model.dart';
import '../widgets/choose_add_calendar_bottom_sheet.dart';

class TodayScreen extends StatefulWidget {
  const TodayScreen({super.key});

  @override
  State<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen>
    with SingleTickerProviderStateMixin {
  final ReservationController reservationController =
      Get.find<ReservationController>();
  final tabLabels = [
    StringUtils.checkInTab,
    StringUtils.checkOutTab,
  ];
  late TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);

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
      appBar: AppBar(
        title: const Text(StringUtils.todaysReservations),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: ColorUtils.white,
          labelColor: ColorUtils.white,
          unselectedLabelColor: ColorUtils.white70,
          labelStyle: TextStyle(fontWeight: FontWeight.bold),
          // Selected tab bold
          unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal),
          // Unselected tab normal
          tabs: tabLabels.map((label) => Tab(text: label)).toList(),
          onTap: (value) {
            setState(() {});
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => chooseAddCalendarBottomSheet(),
        child: Icon(Icons.add),
      ),
      body: Obx(() {
        if (reservationController.reservationList.isEmpty) {
          return const Center(
              child: Text(StringUtils.noReservationsMessage));
        }

        final now = DateFormat("yyyy-MM-dd").parse(DateTime.now().toString());

        final checkInReservationList =
            reservationController.reservationList.where(
          (ele) {
            final checkin = DateTime.parse(ele.checkin);
            return now.isAtSameMomentAs(checkin);
          },
        ).toList();

        final checkOutReservationList =
            reservationController.reservationList.where(
          (ele) {
            final checkout = DateTime.parse(ele.checkout);
            return now.isAtSameMomentAs(checkout);
          },
        ).toList();

        return TabBarView(
            physics: NeverScrollableScrollPhysics(),
            controller: _tabController,
            children: [
              checkInReservationList.isEmpty
                  ? Center(child: Text(StringUtils.noCheckInReservations))
                  : ReservationList(
                      reservationList: checkInReservationList,
                    ),
              checkOutReservationList.isEmpty
                  ? Center(child: Text(StringUtils.noCheckOutReservations))
                  : ReservationList(
                      reservationList: checkOutReservationList,
                    ),
            ]);
      }),
    );
  }
}

class ReservationList extends StatelessWidget {
  const ReservationList({super.key, required this.reservationList});

  final List<ReservationModel> reservationList;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: WidgetStateProperty.all(ColorUtils.grey.shade200),
        showCheckboxColumn: false, // 👈 removes the checkbox

        columns: const [
          DataColumn(label: Text(StringUtils.guestName)),
          DataColumn(label: Text(StringUtils.room)),
          DataColumn(label: Text(StringUtils.checkIn)),
          DataColumn(label: Text(StringUtils.checkOut)),
          DataColumn(label: Text(StringUtils.pendingPrice)),
        ],
        rows: reservationList.map((reservation) {
          return DataRow(
              onSelectChanged: (value) {
                Get.to(() => ReservationDetailScreen(reservation: reservation));
              },
              cells: [
                DataCell(Text(reservation.fullname)),
                DataCell(Text(reservation.roomName)),
                DataCell(Text(DateFormat('yyyy-MM-dd')
                    .format(DateTime.parse(reservation.checkin)))),
                DataCell(Text(DateFormat('yyyy-MM-dd')
                    .format(DateTime.parse(reservation.checkout)))),
                DataCell(Text('${reservation.balance}')),
              ]);
        }).toList(),
      ),
    );
  }
}
