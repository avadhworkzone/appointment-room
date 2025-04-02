import 'package:cal_room/controller/reservation_controller.dart';
import 'package:cal_room/utils/color_utils.dart';
import 'package:cal_room/utils/string_utils.dart';
import 'package:cal_room/widgets/reservation_card_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SearchReservation extends StatelessWidget {
  SearchReservation({super.key});

  final ReservationController reservationController = Get.find();

  RxString searchStr = "".obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: false,
      appBar: AppBar(
        backgroundColor: ColorUtils.blue,
        leadingWidth: 0,
        leading: SizedBox(),
        title: Container(
          height: 45,
          width: Get.width,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50), color: Colors.white12),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: InkWell(
                  onTap: () => Get.back(),
                  child: Icon(Icons.arrow_back),
                ),
              ),
              Expanded(
                child: TextField(
                  onChanged: (value) {
                    searchStr.value = value;
                  },
                  decoration: InputDecoration(border: InputBorder.none),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Obx(() {
        if (searchStr.isEmpty) {
          return SizedBox();
        }
        final reservationList = reservationController.reservationList.value
            .where(
              (element) =>
                  element.fullname
                      .toLowerCase()
                      .contains(searchStr.value.toLowerCase()) ||
                  element.phone
                      .toLowerCase()
                      .contains(searchStr.value.toLowerCase()),
            )
            .toList();
        if (reservationList.isEmpty) {
          return Center(
            child: Text(StringUtils.noReservationsFound2),
          );
        }
        return ListView.builder(
          itemCount: reservationList.length,
          itemBuilder: (context, index) {
            final reservation = reservationList[index];
            return ReservationCardView(
              reservation: reservation,
              isFromToday: false,
            );
          },
        );
      }),
    );
  }
}
