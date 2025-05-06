// ignore_for_file: must_be_immutable, invalid_use_of_protected_member

import 'package:cal_room/blocs/reservation/reservation__bloc.dart';
import 'package:cal_room/blocs/reservation/reservation__state.dart';
import 'package:cal_room/utils/color_utils.dart';
import 'package:cal_room/utils/string_utils.dart';
import 'package:cal_room/widgets/reservation_card_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SearchReservation extends StatelessWidget {
  SearchReservation({super.key});
  String searchStr = "";

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
          width: double.infinity,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50), color: Colors.white12),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: InkWell(
                  onTap: () => Navigator.pop(context),
                  child: Icon(Icons.arrow_back),
                ),
              ),
              Expanded(
                child: TextField(
                  onChanged: (value) {
                    searchStr = value;
                  },
                  style: TextStyle(color: ColorUtils.white),
                  cursorColor: ColorUtils.white,
                  decoration: InputDecoration(border: InputBorder.none),
                ),
              ),
            ],
          ),
        ),
      ),
      body: BlocBuilder<ReservationBloc, ReservationState>(
        builder: (context, state) {
          if (state is ReservationLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ReservationError) {
            return Center(child: Text('Error: ${state.message}'));
          } else if (state is ReservationLoaded) {
            final reservationList = state.reservations;

            if (searchStr.isEmpty) {
              return const Center(child: Text('No Data available'));
            }

            final filteredList = reservationList
                .where(
                  (element) =>
                      element.fullname
                          .toLowerCase()
                          .contains(searchStr.toLowerCase()) ||
                      element.phone
                          .toLowerCase()
                          .contains(searchStr.toLowerCase()),
                )
                .toList();

            if (filteredList.isEmpty) {
              return Center(
                child: Text(StringUtils.noReservationsFound2),
              );
            }

            return ListView.builder(
              itemCount: filteredList.length,
              itemBuilder: (context, index) {
                final reservation = filteredList[index];
                return ReservationCardView(
                  reservation: reservation,
                  isFromToday: false,
                );
              },
            );
          } else {
            return const Center(child: Text('No Reservations Found'));
          }
        },
      ),
    );
  }
}
