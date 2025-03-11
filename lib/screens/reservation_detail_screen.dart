import 'package:flutter/material.dart';
import '../model/reservation_model.dart';

class ReservationDetailScreen extends StatelessWidget {
  final ReservationModel reservation;

  const ReservationDetailScreen({Key? key, required this.reservation}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Reservation Details")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              reservation.fullname,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
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
            _buildPriceRow("Grand Total", reservation.grandTotal, isBold: true),
            _buildPriceRow("Prepayment", reservation.prepayment),
            _buildPriceRow("Balance", reservation.balance, isBold: true, color: Colors.red),
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
          Text(text, style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildGuestCount(IconData icon, String label, int count) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        SizedBox(width: 4),
        Text("$label: $count", style: TextStyle(fontSize: 14)),
      ],
    );
  }

  Widget _buildPriceRow(String label, double amount, {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 14, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text(
            "\$${amount.toStringAsFixed(2)}",
            style: TextStyle(fontSize: 14, fontWeight: isBold ? FontWeight.bold : FontWeight.normal, color: color),
          ),
        ],
      ),
    );
  }
}
