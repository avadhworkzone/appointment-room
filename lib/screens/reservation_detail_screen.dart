import 'package:flutter/material.dart';
import '../model/reservation_model.dart';
import 'package:get/get.dart';
class ReservationDetailScreen extends StatelessWidget {
  final ReservationModel reservation;

  const ReservationDetailScreen({super.key, required this.reservation});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Reservation Details")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                reservation.fullname,textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold,),
              ),
            ),
            SizedBox(height: 10),
            _buildInfoRow(Icons.phone, "Phone: ${reservation.phone}"),
            _buildInfoRow(Icons.email, "Email: ${reservation.email}"),
            _buildInfoRow(Icons.calendar_today, "Check-in: ${reservation.checkin}"),
            _buildInfoRow(Icons.calendar_today, "Check-out: ${reservation.checkout}"),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildGuestCount(Icons.person, "Adults", reservation.adult),
                _buildGuestCount(Icons.child_care, "Children", reservation.child),
                _buildGuestCount(Icons.pets, "Pets", reservation.pet),
              ],
            ),

            Divider(thickness: 1, height: 24),
            _buildPriceRow("Rate per Night", reservation.ratePerNight),
            _buildPriceRow("Subtotal", reservation.subtotal),
            _buildPriceRow("Tax (5%)", reservation.tax),
            _buildPriceRow("Discount", reservation.discount),
            _buildPriceRow("Grand Total", reservation.grandTotal, isBold: true),
            _buildPriceRow("Prepayment", reservation.prepayment),
            _buildPriceRow("Balance", reservation.balance,
                isBold: true, color: Colors.red),
SizedBox(height: 50,),
          Center(
            child: Container(
            width: 200,
              decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),border: Border.all(color: Colors.grey,width: 1),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Center(child: InkWell(
                  onTap: () {
                    Get.back();
                  },
                  child: Text('Back',style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),)),),
            ),
            ),
          )
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          SizedBox(width: 8),
          Text(text, style: TextStyle(fontSize: 18)),
        ],
      ),
    );
  }

  Widget _buildGuestCount(IconData icon, String label, int count) {
    return Row(
      children: [
        Icon(icon, size: 25, color: Colors.blue),
        SizedBox(width: 4),
        Text("$label: $count", style: TextStyle(fontSize: 18)),
      ],
    );
  }

  Widget _buildPriceRow(String label, double amount, {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 18, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text(
            "\$${amount.toStringAsFixed(2)}",
            style: TextStyle(fontSize: 18, fontWeight: isBold ? FontWeight.bold : FontWeight.normal, color: color),
          ),
        ],
      ),
    );
  }
}
