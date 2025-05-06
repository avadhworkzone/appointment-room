// ignore_for_file: library_private_types_in_public_api, avoid_function_literals_in_foreach_calls
import 'package:cal_room/blocs/reservation/reservation__bloc.dart';
import 'package:cal_room/blocs/reservation/reservation__event.dart';
import 'package:cal_room/blocs/reservation/reservation__state.dart';
import 'package:cal_room/blocs/room/room_bloc.dart';
import 'package:cal_room/blocs/room/room_event.dart';
import 'package:cal_room/blocs/room/room_state.dart';
import 'package:cal_room/model/reservation_model.dart';
import 'package:cal_room/utils/color_utils.dart';
import 'package:cal_room/utils/string_utils.dart';
import 'package:cal_room/widgets/add_edit_reservation_bottom_sheet.dart';
import 'package:cal_room/widgets/add_edit_room_bottom_sheet.dart';
import 'package:cal_room/widgets/choose_add_calendar_bottom_sheet.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../widgets/common_method.dart';
import 'reservation_detail_screen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  // final ReservationController reservationController = Get.find();
  // late Worker _reservationListener;
  bool isLoading = true;
  DateTime selectedMonth = DateTime.now();
  DateTime calenderCenterDate = DateTime.now();
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
    context.read<ReservationBloc>().add(FetchReservationsEvent());
    context.read<RoomBloc>().add(FetchRooms());
    // _loadEvents();
    //
    // _reservationListener = ever(reservationController.reservationList, (_) {
    //   if (mounted) _loadEvents();
    // });
    await Future.delayed(Duration(milliseconds: 500), () {
      setCalenderDates(isFromInit: true);
    });
    if (mounted) setState(() => isLoading = false);
  }

  @override
  void dispose() {
    // _reservationListener.dispose();
    super.dispose();
  }

  void setCalenderDates({bool isFromInit = false}) {
    final now = calenderCenterDate;
    final oldDates =
        List.generate(120, (index) => now.subtract(Duration(days: index)));
    calenderDates.addAll(oldDates.reversed);

    final newDates =
        List.generate(120, (index) => now.add(Duration(days: index + 1)));
    calenderDates.addAll(newDates);

    scrollController = ScrollController(
      initialScrollOffset: ((calenderDates.length ~/ 2) * 50) - 60,
    );
    if (isFromInit) {
      listenScrollController();
    }
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

    setState(() {});
    if (isFromListen) {
      scrollController.jumpTo((90 * 50) - 60);
      Future.delayed((Duration(seconds: 2)), () {
        isDataLoad = false;
      });
    } else {
      scrollController.jumpTo(scrollController.offset + ((10 * 50)));
    }
  }

  void setAfterDates({bool isFromListen = false}) {
    final startDate = calenderDates.last.add(Duration(days: 1));
    final oldDates = List.generate(isFromListen ? 90 : 10,
        (index) => startDate.add(Duration(days: index)));

    calenderDates.addAll(oldDates);
    setState(() {});
    if (isFromListen) {
      Future.delayed((Duration(seconds: 2)), () {
        isDataLoad = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Calendar"),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15),
            child: GestureDetector(
                onTap: () {
                  scrollToToday();
                },
                child: Text(StringUtils.goToToday)),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => chooseAddCalendarBottomSheet(context),
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
    } else {
      calenderDates.clear();
      calenderCenterDate = DateTime.now();
      setCalenderDates();
    }
  }

  Widget buildCalendarBody() {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 10),
          BlocBuilder<ReservationBloc, ReservationState>(
            builder: (context, state) {
              if (state is ReservationLoading) {
                return Center(child: CircularProgressIndicator());
              } else if (state is ReservationError) {
                return Center(child: Text('Error: ${state.message}'));
              } else if (state is ReservationLoaded) {
                List<ReservationModel> reservationList = [];
                state.reservations.forEach(
                  (e1) {
                    Map<String, dynamic> map = e1.toMap();
                    e1.rooms.forEach(
                      (e2) {
                        map['roomId'] = e2.id;
                        map['roomName'] = e2.roomName;
                        reservationList.add(ReservationModel.fromMap(map));
                      },
                    );
                  },
                );

                return SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Sidebar with Month + Room Names
                      SizedBox(
                        width: 130,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            GestureDetector(
                              onTap: onDateTap,
                              child: SizedBox(
                                height: 50,
                                child: Column(
                                  children: [
                                    Text("${selectedMonth.year}",
                                        style: TextStyle(fontSize: 18)),
                                    Text(DateFormat('MMM')
                                        .format(selectedMonth)),
                                  ],
                                ),
                              ),
                            ),
                            BlocBuilder<RoomBloc, RoomState>(
                              builder: (context, state) {
                                if (state is RoomLoading) {
                                  return Center(
                                      child: CircularProgressIndicator());
                                } else if (state is RoomLoaded) {
                                  return Column(
                                    children: state.rooms.map((e) {
                                      return GestureDetector(
                                        onTap: () {
                                          showModalBottomSheet(
                                            context: context,
                                            builder: (context) => Container(
                                              padding: EdgeInsets.all(16),
                                              decoration: BoxDecoration(
                                                color: ColorUtils.white,
                                                borderRadius:
                                                    BorderRadius.vertical(
                                                  top: Radius.circular(16),
                                                ),
                                              ),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(StringUtils.rooms),
                                                  ListTile(
                                                    title: Text(
                                                      e.roomName,
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    subtitle: Text(e.roomDesc),
                                                    trailing: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        IconButton(
                                                          icon: Icon(Icons.edit,
                                                              color: ColorUtils
                                                                  .blue),
                                                          onPressed: () {
                                                            Navigator.pop(
                                                                context);
                                                            addEditRoomBottomSheet(
                                                                context,
                                                                room: e);
                                                          },
                                                        ),
                                                        IconButton(
                                                          icon: Icon(
                                                              Icons.delete,
                                                              color: ColorUtils
                                                                  .red),
                                                          onPressed: () {
                                                            Navigator.pop(
                                                                context);
                                                            context
                                                                .read<
                                                                    RoomBloc>()
                                                                .add(DeleteRoom(
                                                                    e.id!));
                                                          },
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                        child: Container(
                                          height: 50,
                                          margin:
                                              EdgeInsets.fromLTRB(2, 0, 2, 2),
                                          decoration: BoxDecoration(
                                            color: ColorUtils.green,
                                            borderRadius:
                                                BorderRadius.circular(5),
                                          ),
                                          child: Center(
                                            child: Text(
                                              e.roomName,
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  color: ColorUtils.white),
                                            ),
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  );
                                } else if (state is RoomError) {
                                  return Center(child: Text(state.message));
                                } else {
                                  return Center(
                                      child: Text('No Rooms Available'));
                                }
                              },
                            )
                          ],
                        ),
                      ),

                      // Calendar Grid
                      BlocBuilder<RoomBloc, RoomState>(
                        builder: (context, state) {
                          if (state is RoomLoaded) {
                            final roomList = state.rooms;

                            return Expanded(
                              child: SizedBox(
                                height: (roomList.length + 1) * 51.5,
                                width: MediaQuery.of(context).size.width,
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  controller: scrollController,
                                  child: Stack(
                                    children: [
                                      Row(
                                        children: List.generate(
                                            calenderDates.length, (index) {
                                          bool isCurrentDate =
                                              DateFormat("dd-MM-yyyy").format(
                                                      calenderDates[index]) ==
                                                  DateFormat("dd-MM-yyyy")
                                                      .format(DateTime.now());

                                          return VisibilityDetector(
                                            key: ValueKey(calenderDates[index]
                                                .millisecondsSinceEpoch),
                                            onVisibilityChanged: (info) {
                                              if (info.visibleFraction == 1.0 &&
                                                  DateFormat("MM-yyyy").format(
                                                          selectedMonth) !=
                                                      DateFormat("MM-yyyy")
                                                          .format(calenderDates[
                                                              index])) {
                                                setState(() => selectedMonth =
                                                    calenderDates[index]);
                                                if (calenderDates[index]
                                                    .isAfter(
                                                        calenderCenterDate)) {
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
                                                      Text(
                                                        DateFormat("EEE")
                                                            .format(
                                                                calenderDates[
                                                                    index])
                                                            .substring(0, 2),
                                                      ),
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
                                                            roomList.map((e) {
                                                          return InkWell(
                                                            onTap: () async {
                                                              await addEditReservationBottomSheet(
                                                                  context);
                                                            },
                                                            child: Container(
                                                              height: 51.5,
                                                              width: 50,
                                                              decoration:
                                                                  BoxDecoration(
                                                                border:
                                                                    Border.all(
                                                                  color: ColorUtils
                                                                      .grey
                                                                      .withAlpha(
                                                                          80),
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
                                                            height: roomList
                                                                    .length *
                                                                51.5,
                                                            width: 50,
                                                            child: Stack(
                                                              children: [
                                                                Center(
                                                                    child: VerticalDivider(
                                                                        color: ColorUtils
                                                                            .blue)),
                                                                Align(
                                                                  alignment:
                                                                      Alignment
                                                                          .topCenter,
                                                                  child:
                                                                      Padding(
                                                                    padding: const EdgeInsets
                                                                        .only(
                                                                        top: 5,
                                                                        left:
                                                                            1),
                                                                    child:
                                                                        CircleAvatar(
                                                                      radius: 6,
                                                                      backgroundColor:
                                                                          ColorUtils
                                                                              .blue,
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

                                      // Reservation Bars
                                      for (int i = 0;
                                          i < reservationList.length;
                                          i++)
                                        Builder(builder: (context) {
                                          final reservation =
                                              reservationList[i];
                                          if (reservation.roomId == 0) {
                                            return SizedBox();
                                          }

                                          final inDays = DateTime.parse(
                                                  reservation.checkout)
                                              .difference(DateTime.parse(
                                                  reservation.checkin))
                                              .inDays;

                                          final containIndex =
                                              calenderDates.indexWhere((date) =>
                                                  DateFormat("yyyy-MM-dd")
                                                      .format(date) ==
                                                  reservation.checkin);

                                          if (containIndex == -1) {
                                            return SizedBox();
                                          }

                                          final roomIdIndex =
                                              roomList.indexWhere((room) =>
                                                  room.id ==
                                                  reservation.roomId);

                                          return Positioned(
                                            top: ((roomIdIndex + 1) * 51.5) +
                                                2.5,
                                            left: (containIndex * 50),
                                            child: GestureDetector(
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        ReservationDetailScreen(
                                                            reservation:
                                                                reservation),
                                                  ),
                                                );
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
                                                          BorderRadius.circular(
                                                              50),
                                                    ),
                                                    child: Center(
                                                      child: Text(
                                                        reservation.fullname,
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: TextStyle(
                                                          color: reservation
                                                                      .balance ==
                                                                  0
                                                              ? ColorUtils.black
                                                              : ColorUtils
                                                                  .white,
                                                          fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.bold,
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
                            );
                          } else if (state is RoomLoading) {
                            return Center(child: CircularProgressIndicator());
                          } else if (state is RoomError) {
                            return Center(child: Text(state.message));
                          } else {
                            return SizedBox();
                          }
                        },
                      )
                    ],
                  ),
                );
              } else {
                return Center(child: Text('No Reservations Found'));
              }
            },
          ),
        ],
      ),
    );
  }

  DateTime chosenDateTime = DateTime.now();

  void onDateTap() {
    iosDatePicker(context);

    // if (Platform.isIOS) {
    //   iosDatePicker(context);
    // } else {
    //   androidDatePicker(context);
    // }
  }

  androidDatePicker(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date != null) {
      chosenDateTime = date;
    }
  }

  iosDatePicker(BuildContext context) {
    showCupertinoModalPopup(
        context: context,
        builder: (BuildContext builder) {
          return Container(
            height: MediaQuery.of(context).copyWith().size.height * 0.35,
            color: Colors.white,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.monthYear,
                    onDateTimeChanged: (value) {
                      chosenDateTime = value;
                    },
                    initialDateTime: DateTime.now(),
                    minimumYear: DateTime.now().year - 50,
                    maximumYear: DateTime.now().year + 50,
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text("CANCEL")),
                      TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            selectedMonth = chosenDateTime;
                            calenderCenterDate = chosenDateTime;
                            calenderDates.clear();
                            setCalenderDates();
                          },
                          child: Text("OK")),
                    ],
                  ),
                )
              ],
            ),
          );
        });
  }

  // void confirmDelete(BuildContext context, int id) {
  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: Text(StringUtils.deleteRoomTitle),
  //       content: Text(StringUtils.deleteRoomMessage),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.of(context).pop(), // Cancel
  //           child: Text(StringUtils.cancel),
  //         ),
  //         ElevatedButton(
  //           style: ElevatedButton.styleFrom(
  //             backgroundColor: Colors.red,
  //           ),
  //           onPressed: () async {
  //             await Future.delayed(
  //                 Duration(milliseconds: 300)); // Optional delay
  //             context.read<RoomBloc>().add(DeleteRoom(id));
  //             context.read<RoomBloc>().add(FetchRooms());
  //             Navigator.of(context).pop(); // Close the dialog
  //           },
  //           child: Text(
  //             StringUtils.delete,
  //             style: TextStyle(color: Colors.white),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }
}
