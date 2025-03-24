// ignore_for_file: library_private_types_in_public_api, invalid_use_of_protected_member

import 'dart:convert';
import 'dart:developer';

import 'package:cal_room/controller/room_controller.dart';
import 'package:cal_room/widgets/add_edit_reservation_bottom_sheet.dart';
import 'package:cal_room/widgets/choose_add_calendar_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../controller/reservation_controller.dart';
import '../model/reservation_model.dart';
import '../widgets/common_method.dart';
import 'reservation_detail_screen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final ReservationController reservationController = Get.find();
  final Map<DateTime, List<ReservationModel>> _eventsMap = {};
  late Worker _reservationListener; // To store the listener reference

  @override
  void initState() {
    super.initState();
    _loadEvents();
    setCalenderDates();
    // Listen for reservation list changes
    _reservationListener = ever(reservationController.reservationList, (_) {
      if (mounted) {
        _loadEvents();
      }
    });
  }

  @override
  void dispose() {
    _reservationListener
        .dispose(); // Remove the listener when widget is disposed
    super.dispose();
  }

  DateTime _parseDate(String dateString) {
    try {
      DateTime parsedDate = DateTime.parse(dateString);
      return DateTime(parsedDate.year, parsedDate.month, parsedDate.day);
    } catch (e) {
      try {
        DateTime parsedDate = DateFormat("dd-MM-yyyy").parse(dateString);
        return DateTime(parsedDate.year, parsedDate.month, parsedDate.day);
      } catch (e) {
        log("Date parsing error: $e");
        return DateTime.now();
      }
    }
  }

  void _loadEvents() {
    if (!mounted) return; // Prevent updating UI after dispose
    setState(() {
      _eventsMap.clear();
      for (var res in reservationController.reservationList) {
        DateTime parsedDate = _parseDate(res.checkin);
        if (_eventsMap.containsKey(parsedDate)) {
          _eventsMap[parsedDate]!.add(res);
        } else {
          _eventsMap[parsedDate] = [res];
        }
      }
    });
  }

  DateTime selectedMonth = DateTime.now();

  late ScrollController scrollController;

  List<DateTime> calenderDates = [];

  void setCalenderDates() {
    final now = DateTime.now();
    final oldDates = List.generate(
      365 * 2,
      (index) => now.subtract(Duration(days: index)),
    );
    calenderDates.addAll(oldDates.reversed);
    final newDates = List.generate(
      365 * 2,
      (index) => now.add(Duration(days: index + 1)),
    );
    calenderDates.addAll(newDates);
    log("calenderDates===> ${jsonEncode(calenderDates.map(
          (e) => e.toString(),
        ).toList())}");
    scrollController = ScrollController(
        initialScrollOffset: ((calenderDates.length ~/ 2) * 50) - 60);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Calendar")),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          chooseAddCalendarBottomSheet();
        },
        child: Icon(Icons.add),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 10),
            Obx(() => SizedBox(
                  width: Get.width,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 130,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              height: 50,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "${selectedMonth.year}",
                                    style: TextStyle(fontSize: 18),
                                  ),
                                  Text(
                                      DateFormat('MMM').format(selectedMonth)),
                                ],
                              ),
                            ),
                            Column(
                                children: RoomController.to.roomList.value.map(
                              (e) {
                                return Container(
                                  height: 50,
                                  // width: 130,

                                  decoration: BoxDecoration(
                                      color: Colors.green,
                                      borderRadius: BorderRadius.circular(5)),
                                  margin: EdgeInsets.fromLTRB(2, 0, 2, 2),
                                  child: Center(
                                      child: Text(
                                    e.roomName,
                                    style: TextStyle(
                                        fontSize: 20, color: Colors.white),
                                  )),
                                );
                              },
                            ).toList())
                          ],
                        ),
                      ),
                      Expanded(
                        child: SizedBox(
                          height:
                              (RoomController.to.roomList.value.length + 1) *
                                  51.5,
                          width: Get.width,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            controller: scrollController,
                            child: Stack(
                              children: [
                                Row(
                                  children: List.generate(
                                    calenderDates.length,
                                    (index) {
                                      bool isCurrentDate =
                                          DateFormat("dd-MM-yyyy").format(
                                                  calenderDates[index]) ==
                                              DateFormat("dd-MM-yyyy")
                                                  .format(DateTime.now());

                                      return VisibilityDetector(
                                        key: ValueKey(calenderDates[index]
                                            .millisecondsSinceEpoch
                                            .toString()),
                                        onVisibilityChanged: (info) {
                                          if (info.visibleFraction == 1.0 &&
                                              selectedMonth !=
                                                  calenderDates[index]) {
                                            setState(() {
                                              selectedMonth =
                                                  calenderDates[index];
                                            });
                                          }
                                        },
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            SizedBox(
                                              height: 51.5,
                                              width: 50,
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    "${calenderDates[index].day}",
                                                  ),
                                                  Text(
                                                      DateFormat("EEEE").format(calenderDates[index]).substring(0, 2)),
                                                ],
                                              ),
                                            ),
                                            SizedBox(
                                              width: 50,
                                              child: Stack(
                                                clipBehavior: Clip.none,
                                                children: [
                                                  Column(
                                                    children:
                                                        RoomController
                                                            .to.roomList.value
                                                            .map(
                                                              (e) => InkWell(
                                                                onTap:
                                                                    () async {
                                                                  await addEditReservationBottomSheet();

                                                                  ///jo reservation available hoy click thase and edetail page par jase jo nai hoy to create reservation
                                                                },
                                                                child:
                                                                    Container(
                                                                  height: 51.5,
                                                                  width: 50,
                                                                  decoration: BoxDecoration(
                                                                      border: Border.all(
                                                                          color: Colors
                                                                              .grey
                                                                              .withValues(alpha: 0.3),
                                                                          width: 0.4)),
                                                                ),
                                                              ),
                                                            )
                                                            .toList(),
                                                  ),
                                                  if (isCurrentDate)
                                                    Center(
                                                      child: SizedBox(
                                                        height: RoomController
                                                                .to
                                                                .roomList
                                                                .value
                                                                .length *
                                                            51.5,
                                                        width: 50,
                                                        child: Stack(
                                                          children: [
                                                            Center(
                                                              child:
                                                                  VerticalDivider(
                                                                width: 0,
                                                                color:
                                                                    Colors.blue,
                                                              ),
                                                            ),
                                                            Align(
                                                                alignment:
                                                                    Alignment
                                                                        .topCenter,
                                                                child: Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .only(
                                                                          top:
                                                                              5,
                                                                          left:
                                                                              1),
                                                                  child:
                                                                      CircleAvatar(
                                                                    radius: 6,
                                                                    backgroundColor:
                                                                        Colors
                                                                            .blue,
                                                                  ),
                                                                )),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                for (int i = 0;
                                    i <
                                        ReservationController
                                            .to.reservationList.value.length;
                                    i++)
                                  Builder(builder: (context) {
                                    final reservation = ReservationController
                                        .to.reservationList.value[i];
                                    if (reservation.roomId == 0) {
                                      return SizedBox();
                                    }
                                    final inDays = DateTime.parse(
                                            reservation.checkout)
                                        .difference(
                                            DateTime.parse(reservation.checkin))
                                        .inDays;
                                    final containIndex =
                                        calenderDates.indexWhere(
                                      (element) =>
                                          DateFormat("yyyy-MM-dd")
                                              .format(element) ==
                                          reservation.checkin,
                                    );
                                    final roomIdIndex = RoomController
                                        .to.roomList.value
                                        .indexWhere(
                                      (element) =>
                                          element.id == reservation.roomId,
                                    );
                                    return Positioned(
                                      top: ((roomIdIndex + 1) * 51.5) + 2.5,
                                      left: (containIndex * 50),
                                      child: GestureDetector(
                                        onTap: () {
                                          Get.to(() => ReservationDetailScreen(
                                                reservation: reservation,
                                              ));
                                        },
                                        child: Container(
                                          height: 45,
                                          width: ((inDays + 1) * 50),
                                          decoration: BoxDecoration(
                                            color: Colors.transparent,
                                            borderRadius:
                                                BorderRadius.circular(50),
                                          ),
                                          child: Center(
                                              child: Container(
                                            height: 45,
                                            width: (inDays * 50),
                                            decoration: BoxDecoration(
                                              color: CommonMethod()
                                                  .reservationColor(
                                                      reservation),
                                              borderRadius:
                                                  BorderRadius.circular(50),
                                            ),
                                            child: Center(
                                              child: Text(
                                                reservation.fullname,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                    color:
                                                        reservation.balance == 0
                                                            ? Colors.black
                                                            : Colors.white,
                                                    fontSize: 15,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                          )),
                                        ),
                                      ),
                                    );
                                  })
                              ],
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                )),
            // SizedBox(height: 10),
            // Expanded(
            //   child: _eventsMap[DateTime(_selectedDay.year, _selectedDay.month,
            //                   _selectedDay.day)] ==
            //               null ||
            //           _eventsMap[DateTime(_selectedDay.year, _selectedDay.month,
            //                   _selectedDay.day)]!
            //               .isEmpty
            //       ? Center(child: Text('No reservation available for the day'))
            //       : ListView.builder(
            //           itemCount: _eventsMap[DateTime(_selectedDay.year,
            //                       _selectedDay.month, _selectedDay.day)]
            //                   ?.length ??
            //               0,
            //           itemBuilder: (context, index) {
            //             final reservation = _eventsMap[DateTime(_selectedDay.year,
            //                 _selectedDay.month, _selectedDay.day)]![index];
            //             return _buildReservationCard(reservation);
            //           },
            //         ),
            // ),
          ],
        ),
      ),
    );
  }
}
