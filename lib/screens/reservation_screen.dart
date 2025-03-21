import 'dart:developer';

import 'package:cal_room/controller/room_controller.dart';
import 'package:cal_room/model/room_model.dart';
import 'package:cal_room/widgets/add_edit_reservation_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/reservation_controller.dart';
import '../model/reservation_model.dart';
import 'package:intl/intl.dart';

class ReservationScreen extends StatefulWidget {
  const ReservationScreen({super.key});

  @override
  State<ReservationScreen> createState() => _ReservationScreenState();
}

class _ReservationScreenState extends State<ReservationScreen> {
  final ReservationController reservationController =
      Get.find<ReservationController>();

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
      appBar: AppBar(title: Text("Reservations")),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await addEditReservationBottomSheet();
          await reservationController.fetchReservations(); // Refresh the list
        },
        child: Icon(Icons.add),
      ),
      body: Obx(() => reservationController.reservationList.isEmpty
          ? Center(child: Text("No reservations found. Add a new reservation!"))
          : ListView.builder(
              itemCount: reservationController.reservationList.length,
              itemBuilder: (context, index) {
                final reservation =
                    reservationController.reservationList[index];
                log("---reservation----$reservation");
                return _buildReservationCard(reservation);
              },
            )),
    );
  }

  /// ✅ **Reservation Card View**
  Widget _buildReservationCard(ReservationModel reservation) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 🔹 **Guest Name & Actions**
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  reservation.fullname,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.blue),
                      onPressed: () =>
                          addEditReservationBottomSheet(reservation: reservation),
                    ),
                    IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          await _deleteReservation(reservation.id!);
                          await reservationController.fetchReservations();
                        }),
                  ],
                ),
              ],
            ),

            SizedBox(height: 8),

            /// 🔹 **Check-in & Check-out Dates**
            _buildInfoRow(
                Icons.calendar_today, "Check-in: ${reservation.checkin}"),
            _buildInfoRow(Icons.calendar_today_outlined,
                "Check-out: ${reservation.checkout}"),

            SizedBox(height: 8),

            /// 🔹 **Guest Contact Details**
            _buildInfoRow(Icons.phone, "Phone: ${reservation.phone}"),
            _buildInfoRow(Icons.email, "Email: ${reservation.email}"),

            SizedBox(height: 8),

            /// 🔹 **Guest Count (Adults, Children, Pets)**
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildGuestCount(Icons.person, "Adults", reservation.adult),
                _buildGuestCount(
                    Icons.child_care, "Children", reservation.child),
                _buildGuestCount(Icons.pets, "Pets", reservation.pet),
              ],
            ),

            Divider(thickness: 1, height: 16),

            /// 🔹 **Pricing Details**
            _buildPriceRow("Room", 0, strValue: reservation.roomName),
            _buildPriceRow("Rate per Night", reservation.ratePerNight),
            _buildPriceRow("Subtotal", reservation.subtotal),
            _buildPriceRow("Tax (5%)", reservation.tax),
            _buildPriceRow("Discount", reservation.discount),
            _buildPriceRow("Grand Total", reservation.grandTotal, isBold: true),
            _buildPriceRow("Prepayment", reservation.prepayment),
            _buildPriceRow("Balance", reservation.balance,
                isBold: true, color: Colors.red),
          ],
        ),
      ),
    );
  }

  /// ✅ **Builds Row for Info (Check-in, Contact, Email)**
  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[700]),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 16),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  /// ✅ **Builds Guest Count Row (Adults, Children, Pets)**
  Widget _buildGuestCount(IconData icon, String label, int count) {
    return Column(
      children: [
        Icon(icon, size: 24, color: Colors.blue),
        SizedBox(height: 4),
        Text("$count",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        Text(label, style: TextStyle(fontSize: 14, color: Colors.grey)),
      ],
    );
  }

  /// ✅ **Builds Price Row (Rate, Subtotal, Tax, Grand Total, etc.)**
  Widget _buildPriceRow(String label, double value,
      {bool isBold = false, Color color = Colors.black, String? strValue}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
                fontSize: 16,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal),
          ),
          Text(
            strValue ?? "\$${value.toStringAsFixed(2)}",
            style: TextStyle(
                fontSize: 16,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                color: color),
          ),
        ],
      ),
    );
  }

  /// ✅ **Delete Reservation with Confirmation**
  Future<void> _deleteReservation(int reservationId) async {
    Get.defaultDialog(
      title: "Delete Reservation",
      middleText: "Are you sure you want to delete this reservation?",
      textConfirm: "Yes",
      textCancel: "No",
      confirmTextColor: Colors.white,
      onConfirm: () async {
        await reservationController.deleteReservation(reservationId);
        Get.back();
        await reservationController.fetchReservations();
      },
    );
  }
}
