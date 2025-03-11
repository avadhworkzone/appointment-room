import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controller/reservation_controller.dart';
import '../controller/user_controller.dart';
import '../model/reservation_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReservationScreen extends StatelessWidget {
  final ReservationController reservationController = Get.find<ReservationController>();
  final UserController userController = Get.find<UserController>(); // ✅ Use Get.find() to avoid multiple instances

  final _formKey = GlobalKey<FormState>();

  final TextEditingController checkinController = TextEditingController();
  final TextEditingController checkoutController = TextEditingController();
  final TextEditingController fullnameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController rateController = TextEditingController();
  final TextEditingController discountController = TextEditingController();
  final TextEditingController prepaymentController = TextEditingController();

  var adultCount = 1.obs;
  var childCount = 0.obs;
  var petCount = 0.obs;
  var isProcessing = false.obs;

  var subtotal = 0.0.obs;
  var tax = 0.0.obs;
  var grandTotal = 0.0.obs;
  var balance = 0.0.obs;

  /// ✅ **Validates form and date selection**
  bool _validateForm() {
    if (!_formKey.currentState!.validate()) return false;

    if (checkinController.text.isNotEmpty && checkoutController.text.isNotEmpty) {
      DateTime checkin = DateFormat('yyyy-MM-dd').parse(checkinController.text);
      DateTime checkout = DateFormat('yyyy-MM-dd').parse(checkoutController.text);

      if (checkout.isBefore(checkin)) {
        Get.snackbar("Invalid Date", "Checkout date cannot be before Check-in date.");
        return false;
      }
    }
    return true;
  }

  /// ✅ **Calculates Tax, Grand Total & Balance**
  void _calculateTotal() {
    double rate = double.tryParse(rateController.text) ?? 0.0;
    double discount = double.tryParse(discountController.text) ?? 0.0;
    double prepayment = double.tryParse(prepaymentController.text) ?? 0.0;

    subtotal.value = rate;
    tax.value = subtotal.value * 0.05; // 5% Tax
    grandTotal.value = (subtotal.value - discount) + tax.value;
    balance.value = grandTotal.value - prepayment;
  }

  /// ✅ **Show Add/Edit Reservation Dialog**
  void showReservationDialog({ReservationModel? reservation}) {
    if (reservation != null) {
      checkinController.text = reservation.checkin;
      checkoutController.text = reservation.checkout;
      fullnameController.text = reservation.fullname;
      phoneController.text = reservation.phone;
      emailController.text = reservation.email;
      rateController.text = reservation.ratePerNight.toString();
      discountController.text = reservation.discount.toString();
      prepaymentController.text = reservation.prepayment.toString();
      adultCount.value = reservation.adult;
      childCount.value = reservation.child;
      petCount.value = reservation.pet;
    } else {
      checkinController.clear();
      checkoutController.clear();
      fullnameController.clear();
      phoneController.clear();
      emailController.clear();
      rateController.text = "100"; // Default Rate
      discountController.text = "0";
      prepaymentController.text = "0";

      adultCount.value = 1;
      childCount.value = 0;
      petCount.value = 0;
    }

    // ✅ **Add listeners to update total dynamically**
    discountController.addListener(_calculateTotal);
    prepaymentController.addListener(_calculateTotal);
    rateController.addListener(_calculateTotal);

    _calculateTotal(); // Ensure values are calculated initially

    Get.bottomSheet(
      Form(
        key: _formKey,
        child: GestureDetector(
          onTap: () => FocusScope.of(Get.context!).unfocus(),
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 30),
                  Text(
                    reservation == null ? "Add Reservation" : "Edit Reservation",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  _buildTextField(fullnameController, "Full Name", TextInputType.text, r'^[a-zA-Z\s]+$', "Enter valid name"),
                  _buildTextField(phoneController, "Phone", TextInputType.phone, r'^\d{10,15}$', "Enter valid phone number (10-15 digits)"),
                  _buildTextField(emailController, "Email", TextInputType.emailAddress, r'^\S+@\S+\.\S+$', "Enter a valid email"),
                  _buildTextField(rateController, "Rate Per Night", TextInputType.number, r'^\d+(\.\d{1,2})?$', "Enter valid rate"),
                  _buildTextField(discountController, "Discount", TextInputType.number, r'^\d+(\.\d{1,2})?$', "Enter valid discount"),
                  _buildTextField(prepaymentController, "Prepayment", TextInputType.number, r'^\d+(\.\d{1,2})?$', "Enter valid prepayment"),
                  SizedBox(height: 10),
                  Obx(() => Column(
                    children: [
                      _buildSummaryRow("Subtotal", subtotal.value),
                      _buildSummaryRow("Tax (5%)", tax.value),
                      _buildSummaryRow("Grand Total", grandTotal.value, isBold: true),
                      _buildSummaryRow("Balance", balance.value, isBold: true, color: Colors.red),
                    ],
                  )),
                  SizedBox(height: 10),
                  Obx(() => ElevatedButton(
                    onPressed: isProcessing.value ? null : () async {
                      if (!_validateForm()) return;
                      isProcessing.value = true;
                      SharedPreferences prefs = await SharedPreferences.getInstance();
                      var userId = prefs.getString('userId') ?? "";
                      print('user id ---> $userId');
                      await reservationController.addReservation(ReservationModel(
                        userId: int.parse(userId),
                        checkin: checkinController.text,
                        checkout: checkoutController.text,
                        fullname: fullnameController.text,
                        phone: phoneController.text,
                        email: emailController.text,
                        adult: adultCount.value,
                        child: childCount.value,
                        pet: petCount.value,
                        ratePerNight: double.parse(rateController.text),
                        subtotal: subtotal.value,
                        discount: double.parse(discountController.text),
                        tax: tax.value,
                        grandTotal: grandTotal.value,
                        prepayment: double.parse(prepaymentController.text),
                        balance: balance.value,
                      ));
                      isProcessing.value = false;
                      Get.back();
                    },
                    child: Text(reservation == null ? "Add Reservation" : "Update Reservation"),
                  )),
                ],
              ),
            ),
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Reservations")),
      floatingActionButton: userController.userList.isEmpty?SizedBox():FloatingActionButton(
        onPressed: () => showReservationDialog(),
        child: Icon(Icons.add),
      ),
      body: Obx(() => reservationController.reservationList.isEmpty
          ? Center(child: Text("No reservations found. Add a new reservation!"))
          : ListView.builder(
        itemCount: reservationController.reservationList.length,
        itemBuilder: (context, index) {
          final reservation = reservationController.reservationList[index];
          return ListTile(
            title: Text(reservation.fullname),
            subtitle: Text("Check-in: ${reservation.checkin}, Check-out: ${reservation.checkout}"),
          );
        },
      )),
    );
  }

  /// ✅ **Reusable TextField**
  Widget _buildTextField(TextEditingController controller, String label, TextInputType type, String pattern, String errorMessage) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(labelText: label, border: OutlineInputBorder()),
        keyboardType: type,
        validator: (value) => RegExp(pattern).hasMatch(value!) ? null : errorMessage,
      ),
    );
  }

  /// ✅ **Builds UI for Summary Fields**
  Widget _buildSummaryRow(String label, double value, {bool isBold = false, Color color = Colors.black}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 16, fontWeight: isBold ? FontWeight.bold : FontWeight.normal, color: color)),
          Text("\$${value.toStringAsFixed(2)}", style: TextStyle(fontSize: 16, fontWeight: isBold ? FontWeight.bold : FontWeight.normal, color: color)),
        ],
      ),
    );
  }

}
