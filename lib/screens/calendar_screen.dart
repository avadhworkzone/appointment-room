// ignore_for_file: library_private_types_in_public_api

import 'package:cal_room/controller/room_controller.dart';
import 'package:cal_room/utils/color_utils.dart';
import 'package:cal_room/utils/string_utils.dart';
import 'package:cal_room/widgets/add_edit_reservation_bottom_sheet.dart';
import 'package:cal_room/widgets/add_edit_room_bottom_sheet.dart';
import 'package:cal_room/widgets/choose_add_calendar_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../controller/reservation_controller.dart';
import '../widgets/common_method.dart';
import 'reservation_detail_screen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final ReservationController reservationController = Get.find();

  // late Worker _reservationListener;

  bool isLoading = true;

  DateTime selectedMonth = DateTime.now();
  late ScrollController scrollController;
  List<DateTime> calenderDates = [];

  @override
  void initState() {
    super.initState();
    initializeScreen();
  }

  Future<void> initializeScreen() async {
    setState(() => isLoading = true);

    // Await room and reservation data before building UI
    await RoomController.to.fetchRooms();
    await reservationController.fetchReservations();
    // _loadEvents();
    //
    // _reservationListener = ever(reservationController.reservationList, (_) {
    //   if (mounted) _loadEvents();
    // });
    await Future.delayed(Duration(milliseconds: 500), () {
      setCalenderDates();
    });
    if (mounted) setState(() => isLoading = false);
  }

  @override
  void dispose() {
    // _reservationListener.dispose();
    super.dispose();
  }

  void setCalenderDates() {
    final now = DateTime.now();
    final oldDates =
        List.generate(120, (index) => now.subtract(Duration(days: index)));
    calenderDates.addAll(oldDates.reversed);

    final newDates =
        List.generate(120, (index) => now.add(Duration(days: index + 1)));
    calenderDates.addAll(newDates);

    scrollController = ScrollController(
      initialScrollOffset: ((calenderDates.length ~/ 2) * 50) - 60,
    );
    listenScrollController();
    setState(() {});
  }

  bool isDataLoad = false;

  void listenScrollController() {
    scrollController.addListener(
      () {
        if (scrollController.offset <= 0 && isDataLoad == false) {
          isDataLoad = true;
          setBeforeDates(isFromListen: true);
        } else if (scrollController.offset >=
                scrollController.position.maxScrollExtent &&
            isDataLoad == false) {
          isDataLoad = true;
          setAfterDates(isFromListen: true);
        }
      },
    );
  }

  void setBeforeDates({bool isFromListen = false}) {
    final startDate = calenderDates.first.subtract(Duration(days: 1));
    final oldDates = List.generate(isFromListen ? 90 : 10,
        (index) => startDate.subtract(Duration(days: index)));

    calenderDates.insertAll(0, oldDates.reversed);
    if (isFromListen) {
      scrollController.jumpTo((90 * 50) - 60);
      Future.delayed((Duration(seconds: 2)), () {
        isDataLoad = false;
      });
    }
  }

  void setAfterDates({bool isFromListen = false}) {
    final startDate = calenderDates.last.add(Duration(days: 1));
    final oldDates = List.generate(isFromListen ? 90 : 10,
        (index) => startDate.add(Duration(days: index)));

    calenderDates.addAll(oldDates);
    setState(() {

    });
    if (isFromListen) {
      Future.delayed((Duration(seconds: 2)), () {
        isDataLoad = false;
      });
    }
  }

  // DateTime _parseDate(String dateString) {
  //   try {
  //     DateTime parsedDate = DateTime.parse(dateString);
  //     return DateTime(parsedDate.year, parsedDate.month, parsedDate.day);
  //   } catch (e) {
  //     try {
  //       DateTime parsedDate = DateFormat("dd-MM-yyyy").parse(dateString);
  //       return DateTime(parsedDate.year, parsedDate.month, parsedDate.day);
  //     } catch (e) {
  //       log("Date parsing error: $e");
  //       return DateTime.now();
  //     }
  //   }
  // }

  // void _loadEvents() {
  //   if (!mounted) return;
  //   _eventsMap.clear();
  //   for (var res in reservationController.reservationList) {
  //     DateTime parsedDate = _parseDate(res.checkin);
  //     _eventsMap.update(parsedDate, (list) => list..add(res),
  //         ifAbsent: () => [res]);
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Calendar"), actions: [Padding(
        padding: const EdgeInsets.only(right: 15),
        child: GestureDetector(
            onTap: (){
              scrollToToday();
            },
            child: Text(StringUtils.goToToday)),
      )],),
      floatingActionButton: FloatingActionButton(
        onPressed: () => chooseAddCalendarBottomSheet(),
        child: Icon(Icons.add),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : buildCalendarBody(),
    );

  }
  void scrollToToday() {
    final todayIndex = calenderDates.indexWhere((date) =>
    DateFormat("dd-MM-yyyy").format(date) ==
        DateFormat("dd-MM-yyyy").format(DateTime.now()));

    if (todayIndex != -1) {
      final scrollOffset = todayIndex * 50.0; // width of each day column
      scrollController.animateTo(
        scrollOffset,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }
  Widget buildCalendarBody() {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 10),
          Obx(() => SizedBox(
                width: Get.width,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Sidebar with Month + Room Names
                    SizedBox(
                      width: 130,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            height: 50,
                            child: Column(
                              children: [
                                Text("${selectedMonth.year}",
                                    style: TextStyle(fontSize: 18)),
                                Text(DateFormat('MMM').format(selectedMonth)),
                              ],
                            ),
                          ),
                          Column(
                            children: RoomController.to.roomList.map((e) {
                              return GestureDetector(
                                onTap: (){
                                  Get.bottomSheet(Container(
                                    padding: EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: ColorUtils.white,
                                      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(StringUtils.rooms),
                                        ListTile(
                                        title: Text(e.roomName,
                                            style: TextStyle(fontWeight: FontWeight.bold)),
                                        // subtitle: Text("Room ID: ${room.id}\n${room.roomDesc}"),
                                        subtitle: Text(e.roomDesc),
                                        trailing: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                                icon: Icon(Icons.edit, color: ColorUtils.blue),
                                                onPressed: () {
                                                  Get.back();
                                                  addEditRoomBottomSheet(room: e);
                                                }
                                            ),
                                            IconButton(
                                                icon: Icon(Icons.delete, color: ColorUtils.red),
                                                onPressed: () {
                                                  Get.back();
                                                  confirmDelete(e.id!);
                                                }
                                            ),
                                          ],
                                        ),
                                                                          ),
                                      ],
                                    ),));
                                },
                                child: Container(
                                  height: 50,
                                  margin: EdgeInsets.fromLTRB(2, 0, 2, 2),
                                  decoration: BoxDecoration(
                                    color: ColorUtils.green,
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Center(
                                    child: Text(
                                      e.roomName,
                                      style: TextStyle(
                                          fontSize: 20, color: ColorUtils.white),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          )
                        ],
                      ),
                    ),

                    /// Calendar Grid
                    Expanded(
                      child: SizedBox(
                        height: (RoomController.to.roomList.length + 1) * 51.5,
                        width: Get.width,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          controller: scrollController,
                          child: Stack(
                            children: [
                              /// Calendar Day Headers + Grid
                              Row(
                                children: List.generate(calenderDates.length,
                                    (index) {
                                  bool isCurrentDate = DateFormat("dd-MM-yyyy")
                                          .format(calenderDates[index]) ==
                                      DateFormat("dd-MM-yyyy")
                                          .format(DateTime.now());

                                  return VisibilityDetector(
                                    key: ValueKey(calenderDates[index]
                                        .millisecondsSinceEpoch),
                                    onVisibilityChanged: (info) {
                                      if (info.visibleFraction == 1.0 &&
                                          DateFormat("MM-yyyy")
                                                  .format(selectedMonth) !=
                                              DateFormat("MM-yyyy").format(
                                                  calenderDates[index])) {
                                        setState(() => selectedMonth =
                                            calenderDates[index]);
                                        if (calenderDates[index]
                                            .isAfter(DateTime.now())) {
                                          setAfterDates();
                                        } else {
                                          setBeforeDates();
                                        }
                                      }
                                    },
                                    child: Column(
                                      children: [
                                        SizedBox(
                                          height: 51.5,
                                          width: 50,
                                          child: Column(
                                            children: [
                                              Text(
                                                  "${calenderDates[index].day}"),
                                              Text(DateFormat("EEE")
                                                  .format(calenderDates[index])
                                                  .substring(0, 2)),
                                            ],
                                          ),
                                        ),
                                        SizedBox(
                                          width: 50,
                                          child: Stack(
                                            clipBehavior: Clip.none,
                                            children: [
                                              Column(
                                                children: RoomController
                                                    .to.roomList
                                                    .map((e) {
                                                  return InkWell(
                                                    onTap: () async {
                                                      await addEditReservationBottomSheet();
                                                    },
                                                    child: Container(
                                                      height: 51.5,
                                                      width: 50,
                                                      decoration: BoxDecoration(
                                                        border: Border.all(
                                                          color: ColorUtils.grey
                                                              .withValues(
                                                                  alpha: 0.3),
                                                          width: 0.4,
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                }).toList(),
                                              ),
                                              if (isCurrentDate)
                                                Center(
                                                  child: SizedBox(
                                                    height: RoomController.to
                                                            .roomList.length *
                                                        51.5,
                                                    width: 50,
                                                    child: Stack(
                                                      children: [
                                                        Center(
                                                            child:
                                                                VerticalDivider(
                                                                    color: ColorUtils.blue)),
                                                        Align(
                                                          alignment: Alignment
                                                              .topCenter,
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                                    top: 5,
                                                                    left: 1),
                                                            child: CircleAvatar(
                                                              radius: 6,
                                                              backgroundColor:
                                                              ColorUtils.blue,
                                                            ),
                                                          ),
                                                        ),
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
                                }),
                              ),

                              /// Reservation Bars
                              for (int i = 0;
                                  i <
                                      reservationController
                                          .reservationList.length;
                                  i++)
                                Builder(builder: (context) {
                                  final reservation =
                                      reservationController.reservationList[i];
                                  if (reservation.roomId == 0) {
                                    return SizedBox();
                                  }

                                  final inDays = DateTime.parse(
                                          reservation.checkout)
                                      .difference(
                                          DateTime.parse(reservation.checkin))
                                      .inDays;

                                  final containIndex = calenderDates.indexWhere(
                                      (date) =>
                                          DateFormat("yyyy-MM-dd")
                                              .format(date) ==
                                          reservation.checkin);
                                  final roomIdIndex = RoomController.to.roomList
                                      .indexWhere((room) =>
                                          room.id == reservation.roomId);

                                  if (containIndex == -1 || roomIdIndex == -1) {
                                    return SizedBox();
                                  }

                                  return Positioned(
                                    top: ((roomIdIndex + 1) * 51.5) + 2.5,
                                    left: (containIndex * 50),
                                    child: GestureDetector(
                                      onTap: () {
                                        Get.to(() => ReservationDetailScreen(
                                            reservation: reservation));
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
                                                          ? ColorUtils.black
                                                          : ColorUtils.white,
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
  void confirmDelete(int id) {
    Get.defaultDialog(
      title: StringUtils.deleteRoomTitle,
      middleText: StringUtils.deleteRoomMessage,
      textConfirm: StringUtils.delete,
      textCancel: StringUtils.cancel,
      confirmTextColor: Colors.white,
      onConfirm: () async {
        // isProcessing.value = true; // ✅ Prevent multiple clicks
        await Future.delayed(Duration(milliseconds: 300)); // ✅ Delay execution
        await Get.find<RoomController>().deleteRoom(id);
        await Get.find<RoomController>().fetchRooms(); // ✅ Refresh list after delete
        // isProcessing.value = false;
        Get.back();
      },
    );
  }
}
