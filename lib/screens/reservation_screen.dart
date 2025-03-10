import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart'; // For Date Formatting
import '../controller/reservation_controller.dart';
import '../model/reservation_model.dart';
import 'export_pdf.dart';

class ReservationScreen extends StatelessWidget {
  final ReservationController reservationController = Get.put(ReservationController());

  final TextEditingController userIdController = TextEditingController();
  final TextEditingController checkinController = TextEditingController();
  final TextEditingController checkoutController = TextEditingController();
  final TextEditingController fullnameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController rateController = TextEditingController();

  var adultCount = 1.obs;
  var childCount = 0.obs;
  var petCount = 0.obs;

  void showReservationDialog({ReservationModel? reservation}) {
    if (reservation != null) {
      userIdController.text = reservation.userId.toString();
      checkinController.text = reservation.checkin;
      checkoutController.text = reservation.checkout;
      fullnameController.text = reservation.fullname;
      phoneController.text = reservation.phone;
      emailController.text = reservation.email;
      rateController.text = reservation.ratePerNight.toString();
      adultCount.value = reservation.adult;
      childCount.value = reservation.child;
      petCount.value = reservation.pet;
    } else {
      userIdController.clear();
      checkinController.clear();
      checkoutController.clear();
      fullnameController.clear();
      phoneController.clear();
      emailController.clear();
      rateController.text = "100"; // Default Rate
      adultCount.value = 1;
      childCount.value = 0;
      petCount.value = 0;
    }

    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(reservation == null ? "Add Reservation" : "Edit Reservation",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            TextField(
              controller: userIdController,
              decoration: InputDecoration(labelText: "User ID"),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: fullnameController,
              decoration: InputDecoration(labelText: "Full Name"),
            ),
            TextField(
              controller: phoneController,
              decoration: InputDecoration(labelText: "Phone"),
              keyboardType: TextInputType.phone,
            ),
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: "Email"),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: rateController,
              decoration: InputDecoration(labelText: "Rate Per Night"),
              keyboardType: TextInputType.number,
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: checkinController,
                    decoration: InputDecoration(labelText: "Check-in Date"),
                    readOnly: true,
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: Get.context!,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                      );
                      if (pickedDate != null) {
                        checkinController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
                      }
                    },
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: checkoutController,
                    decoration: InputDecoration(labelText: "Check-out Date"),
                    readOnly: true,
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: Get.context!,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                      );
                      if (pickedDate != null) {
                        checkoutController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
                      }
                    },
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Adults"),
                DropdownButton<int>(
                  value: adultCount.value,
                  items: List.generate(5, (index) => DropdownMenuItem(value: index + 1, child: Text("${index + 1}"))),
                  onChanged: (value) => adultCount.value = value!,
                ),
                Text("Children"),
                DropdownButton<int>(
                  value: childCount.value,
                  items: List.generate(5, (index) => DropdownMenuItem(value: index, child: Text("$index"))),
                  onChanged: (value) => childCount.value = value!,
                ),
                Text("Pets"),
                DropdownButton<int>(
                  value: petCount.value,
                  items: List.generate(3, (index) => DropdownMenuItem(value: index, child: Text("$index"))),
                  onChanged: (value) => petCount.value = value!,
                ),
              ],
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                if (fullnameController.text.isEmpty || userIdController.text.isEmpty) {
                  Get.snackbar("Error", "User ID and Full Name are required");
                  return;
                }

                double rate = double.tryParse(rateController.text) ?? 100.0;
                double subtotal = rate * (1 + childCount.value * 0.5); // Assume child pays half
                double tax = subtotal * 0.1;
                double grandTotal = subtotal + tax;

                if (reservation == null) {
                  reservationController.addReservation(ReservationModel(
                    userId: int.parse(userIdController.text),
                    checkin: checkinController.text,
                    checkout: checkoutController.text,
                    fullname: fullnameController.text,
                    phone: phoneController.text,
                    email: emailController.text,
                    adult: adultCount.value,
                    child: childCount.value,
                    pet: petCount.value,
                    ratePerNight: rate,
                    subtotal: subtotal,
                    discount: 0.0,
                    tax: tax,
                    grandTotal: grandTotal,
                    prepayment: 50.0,
                    balance: grandTotal - 50.0,
                  ));
                } else {
                  reservationController.updateReservation(ReservationModel(
                    id: reservation.id,
                    userId: int.parse(userIdController.text),
                    checkin: checkinController.text,
                    checkout: checkoutController.text,
                    fullname: fullnameController.text,
                    phone: phoneController.text,
                    email: emailController.text,
                    adult: adultCount.value,
                    child: childCount.value,
                    pet: petCount.value,
                    ratePerNight: rate,
                    subtotal: subtotal,
                    discount: 0.0,
                    tax: tax,
                    grandTotal: grandTotal,
                    prepayment: 50.0,
                    balance: grandTotal - 50.0,
                  ));
                }
                Get.back();
              },
              child: Text(reservation == null ? "Add Reservation" : "Update Reservation"),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Reservations")),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showReservationDialog(),
        child: Icon(Icons.add),
      ),
      body: Obx(() {

        return Column(
          children: [
            Expanded(
              child:reservationController.reservationList.isEmpty?Center(child: Text("No reservations found. Add a new reservation!")): ListView.builder(
                itemCount: reservationController.reservationList.length,
                itemBuilder: (context, index) {
                  final reservation = reservationController.reservationList[index];
                  return ListTile(
                    title: Text(reservation.fullname),
                    subtitle: Text("Check-in: ${reservation.checkin}, Check-out: ${reservation.checkout}"),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: ElevatedButton(
                onPressed: () {
                  exportReservationsAsPDF(reservationController.reservationList);
                  Get.snackbar("Export Successful", "PDF saved in documents folder!");
                },
                child: Text("Export as PDF"),
              ),
            ),
          ],
        );
      }),
    );
  }
}
