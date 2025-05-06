// import 'package:cal_room/controller/room_controller.dart';
// import 'package:cal_room/screens/reservation_detail_screen.dart';
// import 'package:cal_room/utils/color_utils.dart';
// import 'package:cal_room/utils/string_utils.dart';
// import 'package:flutter/material.dart';
// import '../controller/reservation_controller.dart';
// import 'package:intl/intl.dart';
// import '../model/reservation_model.dart';
// import '../widgets/choose_add_calendar_bottom_sheet.dart';
//
// class TodayScreen extends StatefulWidget {
//   const TodayScreen({super.key});
//
//   @override
//   State<TodayScreen> createState() => _TodayScreenState();
// }
//
// class _TodayScreenState extends State<TodayScreen>
//     with SingleTickerProviderStateMixin {
//   final ReservationController reservationController =
//       Get.find<ReservationController>();
//   final tabLabels = [
//     StringUtils.checkInTab,
//     StringUtils.checkOutTab,
//   ];
//   late TabController _tabController;
//
//   @override
//   void initState() {
//     _tabController = TabController(length: 2, vsync: this);
//
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
//       appBar: AppBar(
//         title: const Text(StringUtils.todaysReservations),
//         bottom: TabBar(
//           controller: _tabController,
//           indicatorColor: ColorUtils.white,
//           labelColor: ColorUtils.white,
//           unselectedLabelColor: ColorUtils.white70,
//           labelStyle: TextStyle(fontWeight: FontWeight.bold),
//           // Selected tab bold
//           unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal),
//           // Unselected tab normal
//           tabs: tabLabels.map((label) => Tab(text: label)).toList(),
//           onTap: (value) {
//             setState(() {});
//           },
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () => chooseAddCalendarBottomSheet(),
//         child: Icon(Icons.add),
//       ),
//       body: Obx(() {
//         if (reservationController.reservationList.isEmpty) {
//           return const Center(child: Text(StringUtils.noReservationsMessage));
//         }
//
//         final now = DateFormat("yyyy-MM-dd").parse(DateTime.now().toString());
//
//         final checkInReservationList =
//             reservationController.reservationList.where(
//           (ele) {
//             final checkin = DateTime.parse(ele.checkin);
//             return now.isAtSameMomentAs(checkin);
//           },
//         ).toList();
//
//         final checkOutReservationList =
//             reservationController.reservationList.where(
//           (ele) {
//             final checkout = DateTime.parse(ele.checkout);
//             return now.isAtSameMomentAs(checkout);
//           },
//         ).toList();
//
//         return TabBarView(
//             physics: NeverScrollableScrollPhysics(),
//             controller: _tabController,
//             children: [
//               checkInReservationList.isEmpty
//                   ? Center(child: Text(StringUtils.noCheckInReservations))
//                   : ReservationList(
//                       reservationList: checkInReservationList,
//                     ),
//               checkOutReservationList.isEmpty
//                   ? Center(child: Text(StringUtils.noCheckOutReservations))
//                   : ReservationList(
//                       reservationList: checkOutReservationList,
//                     ),
//             ]);
//       }),
//     );
//   }
// }
//
// class ReservationList extends StatelessWidget {
//   const ReservationList({super.key, required this.reservationList});
//
//   final List<ReservationModel> reservationList;
//
//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       scrollDirection: Axis.horizontal,
//       child: DataTable(
//         headingRowColor: WidgetStateProperty.all(ColorUtils.grey.shade200),
//         showCheckboxColumn: false, // 👈 removes the checkbox
//
//         columns: const [
//           DataColumn(label: Text(StringUtils.guestName)),
//           DataColumn(label: Text(StringUtils.room)),
//           DataColumn(label: Text(StringUtils.checkIn)),
//           DataColumn(label: Text(StringUtils.checkOut)),
//           DataColumn(label: Text(StringUtils.pendingPrice)),
//         ],
//         rows: reservationList.map((reservation) {
//           return DataRow(
//               onSelectChanged: (value) {
//                 Get.to(() => ReservationDetailScreen(reservation: reservation));
//               },
//               cells: [
//                 DataCell(Text(reservation.fullname)),
//                 DataCell(Text(reservation.roomName)),
//                 DataCell(Text(DateFormat('yyyy-MM-dd')
//                     .format(DateTime.parse(reservation.checkin)))),
//                 DataCell(Text(DateFormat('yyyy-MM-dd')
//                     .format(DateTime.parse(reservation.checkout)))),
//                 DataCell(Text('${reservation.balance}')),
//               ]);
//         }).toList(),
//       ),
//     );
//   }
// }
import 'package:cal_room/blocs/reservation/reservation__bloc.dart';
import 'package:cal_room/blocs/reservation/reservation__event.dart';
import 'package:cal_room/blocs/reservation/reservation__state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../model/reservation_model.dart';
import '../screens/reservation_detail_screen.dart';
import '../utils/color_utils.dart';
import '../utils/string_utils.dart';
import '../widgets/choose_add_calendar_bottom_sheet.dart';

class TodayScreen extends StatefulWidget {
  const TodayScreen({super.key});

  @override
  State<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final tabLabels = [
    StringUtils.checkInTab,
    StringUtils.checkOutTab,
  ];

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    context.read<ReservationBloc>().add(FetchReservationsEvent());
    super.initState();
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
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
          tabs: tabLabels.map((label) => Tab(text: label)).toList(),
          onTap: (_) => setState(() {}),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => chooseAddCalendarBottomSheet(context),
        child: const Icon(Icons.add),
      ),
      body: BlocBuilder<ReservationBloc, ReservationState>(
        builder: (context, state) {
          if (state is ReservationLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ReservationLoaded) {
            final now = DateFormat("yyyy-MM-dd")
                .parse(DateFormat("yyyy-MM-dd").format(DateTime.now()));

            final checkInReservationList = state.reservations.where((res) {
              final checkin = DateTime.parse(res.checkin);
              return checkin.isAtSameMomentAs(now);
            }).toList();

            final checkOutReservationList = state.reservations.where((res) {
              final checkout = DateTime.parse(res.checkout);
              return checkout.isAtSameMomentAs(now);
            }).toList();

            return TabBarView(
              physics: const NeverScrollableScrollPhysics(),
              controller: _tabController,
              children: [
                checkInReservationList.isEmpty
                    ? const Center(
                        child: Text(StringUtils.noCheckInReservations))
                    : ReservationList(reservationList: checkInReservationList),
                checkOutReservationList.isEmpty
                    ? const Center(
                        child: Text(StringUtils.noCheckOutReservations))
                    : ReservationList(reservationList: checkOutReservationList),
              ],
            );
          } else if (state is ReservationError) {
            return Center(child: Text(state.message));
          } else {
            return const Center(child: Text(StringUtils.noReservationsMessage));
          }
        },
      ),
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
        showCheckboxColumn: false,
        columns: const [
          DataColumn(label: Text(StringUtils.guestName)),
          DataColumn(label: Text(StringUtils.room)),
          DataColumn(label: Text(StringUtils.checkIn)),
          DataColumn(label: Text(StringUtils.checkOut)),
          DataColumn(label: Text(StringUtils.pendingPrice)),
        ],
        rows: reservationList.map((reservation) {
          return DataRow(
            onSelectChanged: (_) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ReservationDetailScreen(
                    reservation: reservation,
                  ),
                ),
              );
            },
            cells: [
              DataCell(Text(reservation.fullname)),
              DataCell(Text(reservation.roomName)),
              DataCell(Text(DateFormat('yyyy-MM-dd')
                  .format(DateTime.parse(reservation.checkin)))),
              DataCell(Text(DateFormat('yyyy-MM-dd')
                  .format(DateTime.parse(reservation.checkout)))),
              DataCell(Text('${reservation.balance}')),
            ],
          );
        }).toList(),
      ),
    );
  }
}
