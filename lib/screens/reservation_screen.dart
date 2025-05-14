// import 'package:cal_room/controller/room_controller.dart';
// import 'package:cal_room/utils/color_utils.dart';
// import 'package:cal_room/utils/string_utils.dart';
// import 'package:cal_room/widgets/add_edit_reservation_bottom_sheet.dart';
// import 'package:cal_room/widgets/reservation_card_view.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import '../controller/reservation_controller.dart';
// import '../model/reservation_model.dart';
//
// class ReservationScreen extends StatefulWidget {
//   const ReservationScreen({super.key});
//
//   @override
//   State<ReservationScreen> createState() => _ReservationScreenState();
// }
//
// class _ReservationScreenState extends State<ReservationScreen>
//     with SingleTickerProviderStateMixin {
//   final ReservationController reservationController =
//   Get.find<ReservationController>();
//
//   late TabController _tabController;
//   String selectedFilter = StringUtils.thisWeek;
//   DateTimeRange? customRange;
//
//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 3, vsync: this);
//     _tabController.addListener(() {
//       if (!_tabController.indexIsChanging) {
//         setState(() {});
//       }
//     });
//
//     initMethod();
//     RoomController.to.fetchRooms();
//   }
//
//   initMethod() async {
//     await reservationController.fetchReservations();
//   }
//
//   List<ReservationModel> getFilteredReservations(String type) {
//     final now = DateTime.now();
//     final all = reservationController.reservationList;
//
//     List<ReservationModel> list = all.where((r) {
//       final checkin = DateFormat('yyyy-MM-dd').parse(r.checkin);
//       final checkout = DateFormat('yyyy-MM-dd').parse(r.checkout);
//
//       if (type == StringUtils.current) {
//         return checkin.isBefore(now.add(Duration(days: 1))) &&
//             checkout.isAfter(now.subtract(Duration(days: 1)));
//       } else if (type == StringUtils.upcoming) {
//         return checkin.isAfter(now);
//       } else {
//         return checkout.isBefore(now);
//       }
//     }).toList();
//
//     // No filter for "Current"
//     if (type == StringUtils.current) return list;
//
//     // Apply filters only for Upcoming & History
//     return list.where((r) {
//       final checkin = DateFormat('yyyy-MM-dd').parse(r.checkin);
//       switch (selectedFilter) {
//         case StringUtils.thisWeek:
//           final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
//           final endOfWeek = startOfWeek.add(Duration(days: 6));
//           return checkin.isAfter(startOfWeek.subtract(Duration(seconds: 1))) &&
//               checkin.isBefore(endOfWeek.add(Duration(days: 1)));
//         case StringUtils.thisMonth:
//           return checkin.year == now.year && checkin.month == now.month;
//         case StringUtils.custom:
//           if (customRange == null) return true;
//           return checkin.isAfter(customRange!.start.subtract(Duration(seconds: 1))) &&
//               checkin.isBefore(customRange!.end.add(Duration(days: 1)));
//         default:
//           return true;
//       }
//     }).toList();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final tabLabels = [StringUtils.current, StringUtils.upcoming, StringUtils.history];
//     final currentTab = tabLabels[_tabController.index];
//
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(StringUtils.reservations),
//         bottom: TabBar(
//           controller: _tabController,
//           indicatorColor: ColorUtils.white,
//           labelColor: ColorUtils.white,
//           unselectedLabelColor: ColorUtils.white70,
//           labelStyle: TextStyle(fontWeight: FontWeight.bold),        // Selected tab bold
//           unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal), // Unselected tab normal
//           tabs: tabLabels.map((label) => Tab(text: label)).toList(),
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () async {
//           await addEditReservationBottomSheet();
//           await reservationController.fetchReservations();
//         },
//         child: Icon(Icons.add),
//       ),
//       body: Column(
//         children: [
//           if (currentTab != StringUtils.current)
//             Padding(
//               padding: EdgeInsets.all(8),
//               child: Wrap(
//                 spacing: 8,
//                 children: [
//                   _buildFilterChip(StringUtils.thisWeek),
//                   _buildFilterChip(StringUtils.thisMonth),
//                   _buildFilterChip(StringUtils.custom),
//                 ],
//               ),
//             ),
//           Expanded(
//             child: Obx(() {
//               final filteredList = getFilteredReservations(currentTab);
//
//               if (filteredList.isEmpty) {
//                 return Center(
//                   child: Text(StringUtils.noReservationsFound),
//                 );
//               }
//
//               return ListView.builder(
//                 itemCount: filteredList.length,
//                 itemBuilder: (context, index) {
//                   final reservation = filteredList[index];
//                   return ReservationCardView(
//                     reservation: reservation,
//                     canEditDelete: currentTab != StringUtils.history, // ✅ condition added
//
//                     isFromToday: false,
//                   );
//                 },
//               );
//             }),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildFilterChip(String label) {
//     return ChoiceChip(
//       label: Text(label,),
//       selected: selectedFilter == label,
//       onSelected: (selected) async {
//         if (label == StringUtils.custom && selected) {
//           final picked = await showDateRangePicker(
//             context: context,
//             firstDate: DateTime(2025),
//             lastDate: DateTime(2100),
//           );
//           if (picked != null) {
//             setState(() {
//               customRange = picked;
//               selectedFilter = label;
//             });
//           }
//         } else {
//           setState(() {
//             selectedFilter = label;
//             if (label != StringUtils.custom) customRange = null;
//           });
//         }
//       },
//     );
//   }
// }
// ignore_for_file: use_build_context_synchronously

import 'package:cal_room/blocs/reservation/reservation__bloc.dart';
import 'package:cal_room/blocs/reservation/reservation__event.dart';
import 'package:cal_room/blocs/reservation/reservation__state.dart';
import 'package:cal_room/blocs/room/room_bloc.dart';
import 'package:cal_room/blocs/room/room_event.dart';
// import 'package:cal_room/controller/room_controller.dart';
import 'package:cal_room/utils/color_utils.dart';
import 'package:cal_room/utils/string_utils.dart';
import 'package:cal_room/widgets/add_edit_reservation_bottom_sheet.dart';
import 'package:cal_room/widgets/reservation_card_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../model/reservation_model.dart';

class ReservationScreen extends StatefulWidget {
  const ReservationScreen({super.key});

  @override
  State<ReservationScreen> createState() => _ReservationScreenState();
}

class _ReservationScreenState extends State<ReservationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String selectedFilter = StringUtils.thisWeek;
  DateTimeRange? customRange;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});
      }
    });

    context.read<ReservationBloc>().add(FetchReservationsEvent());
    context.read<RoomBloc>().add(FetchRooms());
  }

  List<ReservationModel> getFilteredReservations(
      List<ReservationModel> all, String type) {
    final now = DateTime.now();
    List<ReservationModel> list = all.where((r) {
      final checkin = DateFormat('yyyy-MM-dd').parse(r.checkin);
      final checkout = DateFormat('yyyy-MM-dd').parse(r.checkout);

      if (type == StringUtils.current) {
        return checkin.isBefore(now.add(Duration(days: 1))) &&
            checkout.isAfter(now.subtract(Duration(days: 1)));
      } else if (type == StringUtils.upcoming) {
        return checkin.isAfter(now);
      } else {
        return checkout.isBefore(now);
      }
    }).toList();

    // No filter for "Current"
    if (type == StringUtils.current) return list;

    // Apply filters only for Upcoming & History
    return list.where((r) {
      final checkin = DateFormat('yyyy-MM-dd').parse(r.checkin);
      switch (selectedFilter) {
        case StringUtils.thisWeek:
          final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
          final endOfWeek = startOfWeek.add(Duration(days: 6));
          return checkin.isAfter(startOfWeek.subtract(Duration(seconds: 1))) &&
              checkin.isBefore(endOfWeek.add(Duration(days: 1)));
        case StringUtils.thisMonth:
          return checkin.year == now.year && checkin.month == now.month;
        case StringUtils.custom:
          if (customRange == null) return true;
          return checkin
                  .isAfter(customRange!.start.subtract(Duration(seconds: 1))) &&
              checkin.isBefore(customRange!.end.add(Duration(days: 1)));
        default:
          return true;
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final tabLabels = [
      StringUtils.current,
      StringUtils.upcoming,
      StringUtils.history
    ];
    final currentTab = tabLabels[_tabController.index];

    return Scaffold(
      appBar: AppBar(
        title: Text(StringUtils.reservations),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: ColorUtils.white,
          labelColor: ColorUtils.white,
          unselectedLabelColor: ColorUtils.white70,
          labelStyle: TextStyle(fontWeight: FontWeight.bold),
          unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal),
          tabs: tabLabels.map((label) => Tab(text: label)).toList(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await addEditReservationBottomSheet(context);
          context.read<ReservationBloc>().add(FetchReservationsEvent());
        },
        child: Icon(Icons.add),
      ),
      body: Column(
        children: [
          if (currentTab != StringUtils.current)
            Padding(
              padding: EdgeInsets.all(8),
              child: Wrap(
                spacing: 8,
                children: [
                  _buildFilterChip(StringUtils.thisWeek),
                  _buildFilterChip(StringUtils.thisMonth),
                  _buildFilterChip(StringUtils.custom),
                ],
              ),
            ),
          Expanded(
            child: BlocBuilder<ReservationBloc, ReservationState>(
              builder: (context, state) {
                if (state is ReservationLoading) {
                  return Center(child: CircularProgressIndicator());
                } else if (state is ReservationLoaded) {
                  final filteredList =
                      getFilteredReservations(state.reservations, currentTab);

                  if (filteredList.isEmpty) {
                    return Center(child: Text(StringUtils.noReservationsFound));
                  }

                  return ListView.builder(
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      final reservation = filteredList[index];
                      return ReservationCardView(
                        reservation: reservation,
                        canEditDelete: currentTab != StringUtils.history,
                        isFromToday: false,
                      );
                    },
                  );
                } else if (state is ReservationError) {
                  return Center(child: Text(state.message));
                }
                return SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    return ChoiceChip(
      label: Text(label),
      selected: selectedFilter == label,
      onSelected: (selected) async {
        if (label == StringUtils.custom && selected) {
          final picked = await showDateRangePicker(
            context: context,
            firstDate: DateTime(2025),
            lastDate: DateTime(2100),
          );
          if (picked != null) {
            setState(() {
              customRange = picked;
              selectedFilter = label;
            });
          }
        } else {
          setState(() {
            selectedFilter = label;
            if (label != StringUtils.custom) customRange = null;
          });
        }
      },
    );
  }
}
