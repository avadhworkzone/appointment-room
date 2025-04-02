import 'package:cal_room/controller/reservation_controller.dart';
import 'package:cal_room/utils/string_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  TextEditingController filterController = TextEditingController();
  List<String> filterList = ["Daily", "Monthly", 'Yearly'];

  @override
  void initState() {
    filterController.text = filterList.first;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Report"),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            SizedBox(
              height: 20,
            ),
            TextFormField(
              onTap: () {
                filterDialog();
              },
              readOnly: true,
              controller: filterController,
              decoration: InputDecoration(
                  suffixIcon: Icon(Icons.arrow_drop_down),
                  hintText: StringUtils.room,
                  border: OutlineInputBorder()),
            ),
            Spacer(),
            Obx(() {
              final reservationList =
                  ReservationController.to.reservationList.value;
              List<double> reservationGrandTotalList = [];
              num reservationSum = 0;
              if (filterController.text == "Daily") {
                reservationGrandTotalList = reservationList
                    .where(
                      (element) => DateFormat("dd-MM-yyyy")
                          .parse(DateTime.now().toString())
                          .isAfter(
                              DateFormat("dd-MM-yyyy").parse(element.checkout)),
                    )
                    .map(
                      (e) => e.grandTotal,
                    )
                    .toList();
              } else if (filterController.text == "Monthly") {
                reservationGrandTotalList = reservationList
                    .where(
                      (element) {
                        // print(
                        //     "r1 :=>${DateFormat("MM-yyyy").parse(DateTime.now().toString())} r2 :=>${ DateFormat("MM-yyyy").parse(element.checkout)}");
                        return DateFormat("MM-yyyy")
                            .parse(DateTime.now().toString())
                            .isAtSameMomentAs(
                                DateFormat("MM-yyyy").parse(element.checkout));
                      },
                    )
                    .map(
                      (e) => e.grandTotal,
                    )
                    .toList();
              } else {
                reservationGrandTotalList = reservationList
                    .where(
                      (element) =>
                          DateTime.now().year ==
                          DateFormat("yyyy-MM-dd").parse(element.checkout).year,
                    )
                    .map(
                      (e) => e.grandTotal,
                    )
                    .toList();
              }
              if (reservationGrandTotalList.isNotEmpty) {
                reservationSum = reservationGrandTotalList.reduce(
                  (previousValue, element) => previousValue + element,
                );
              }
              return
                Text("SUM : $reservationSum",style: TextStyle(fontSize: 25),)
                  ;
            }),
            Spacer(),
          ],
        ),
      ),
    );
  }

  void filterDialog() {
    String filter = filterController.text;
    Get.dialog(
      StatefulBuilder(
        builder: (context, dialogSetState) {
          return AlertDialog(
            insetPadding: EdgeInsets.zero,
            contentPadding: EdgeInsets.zero,
            title: Text(StringUtils.room),
            content: SizedBox(
              width: Get.width - 60,
              child: SingleChildScrollView(
                physics: ClampingScrollPhysics(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: filterList
                      .map((e) => ListTile(
                            onTap: () {
                              dialogSetState(() {
                                filter = e;
                              });
                            },
                            leading: Icon(e == filter
                                ? Icons.radio_button_checked
                                : Icons.radio_button_off),
                            title: Text(e),
                          ))
                      .toList(),
                ),
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Get.back();
                  },
                  child: Text(StringUtils.cancelCapital)),
              TextButton(
                  onPressed: () {
                    filterController.text = filter;
                    setState(() {

                    });
                    Get.back();
                  },
                  child: Text(StringUtils.ok)),
            ],
          );
        },
      ),
    );
  }
}
