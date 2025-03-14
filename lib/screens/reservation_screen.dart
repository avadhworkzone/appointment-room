import 'dart:developer';

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
    super.initState();
  }

  initMethod()async{
    await reservationController.fetchReservations();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Reservations")),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await showReservationDialog();
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
                          showReservationDialog(reservation: reservation),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () async{
                        await _deleteReservation(reservation.id!);
                        await reservationController.fetchReservations();
                      }
                    ),
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
      {bool isBold = false, Color color = Colors.black}) {
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
            "\$${value.toStringAsFixed(2)}",
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
  Future<void> _deleteReservation(int reservationId) async{
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

  /// ✅ Show Add/Edit Reservation Dialog
  Future<void> showReservationDialog({ReservationModel? reservation}) async {
    final formKey = GlobalKey<FormState>();

    TextEditingController checkinController = TextEditingController();
    TextEditingController checkoutController = TextEditingController();
    TextEditingController fullnameController = TextEditingController();
    TextEditingController phoneController = TextEditingController();
    TextEditingController emailController = TextEditingController();
    TextEditingController rateController = TextEditingController();
    TextEditingController discountController = TextEditingController();
    TextEditingController prepaymentController = TextEditingController();

    DateTime? checkinDate;
    DateTime? checkoutDate;

    var adultCount = 1.obs;
    var childCount = 0.obs;
    var petCount = 0.obs;
    var subtotal = 0.0.obs;
    var tax = 0.0.obs;
    var grandTotal = 0.0.obs;
    var balance = 0.0.obs;

    /// ✅ **Pick a date and validate it**
    Future<void> selectDate(BuildContext context, bool isCheckIn) async {
      DateTime initialDate = isCheckIn
          ? DateTime.now() // Check-in starts today
          : checkinDate ??
              DateTime.now()
                  .add(Duration(days: 1)); // Check-out starts after check-in

      DateTime firstDate = isCheckIn
          ? DateTime.now() // Check-in cannot be before today
          : checkinDate ?? DateTime.now(); // Check-out must be after check-in

      DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: initialDate,
        firstDate: firstDate,
        lastDate: DateTime(2100),
      );

      if (pickedDate != null) {
        if (isCheckIn) {
          checkinDate = pickedDate;
          checkinController.text = DateFormat('yyyy-MM-dd').format(pickedDate);

          // Auto-reset checkout if it's before the check-in
          if (checkoutDate != null && checkoutDate!.isBefore(checkinDate!)) {
            checkoutDate = checkinDate!.add(Duration(days: 1));
            checkoutController.text =
                DateFormat('yyyy-MM-dd').format(checkoutDate!);
          }
        } else {
          checkoutDate = pickedDate;
          checkoutController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
        }
      }
    }

    /// ✅ **Calculates Tax, Grand Total & Balance**
    void calculateTotal() {
      double rate = double.tryParse(rateController.text) ?? 0.0;
      double discount = double.tryParse(discountController.text) ?? 0.0;
      double prepayment = double.tryParse(prepaymentController.text) ?? 0.0;

      subtotal.value = rate;
      tax.value = subtotal.value * 0.05; // 5% Tax
      grandTotal.value = (subtotal.value - discount) + tax.value;
      balance.value = grandTotal.value - prepayment;
    }

    /// ✅ **Pre-fill data when editing a reservation**
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
      calculateTotal();
    } else {
      rateController.text = "100"; // Default rate
      discountController.text = "0";
      prepaymentController.text = "0";
      calculateTotal();
    }

    /// ✅ **Call `_calculateTotal()` whenever rate, discount, or prepayment changes**
    rateController.addListener(calculateTotal);
    discountController.addListener(calculateTotal);
    prepaymentController.addListener(calculateTotal);

    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  reservation == null ? "Add Reservation" : "Edit Reservation",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                _buildTextField(
                  fullnameController,
                  "Full Name",
                  keyboardType: TextInputType.text,
                  validator: (value) =>
                      value!.isEmpty ? "Enter full Name" : null,
                ),
                _buildTextField(
                  phoneController,
                  "Phone",
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if(value!.isEmpty){
                      return "Enter mobile number";
                    }
                    else if (value.length < 10 ||value.length > 10){
                      return "Phone number must be 10 digits";
                    }
                    return null;
                  }
                ),
                _buildTextField(
                  emailController,
                  "Email",
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) => value!.isEmpty ? "Enter email" : null,
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildCounter("Adults", adultCount),
                    _buildCounter("Children", childCount),
                    _buildCounter("Pets", petCount),
                  ],
                ),
                SizedBox(height: 10),

                /// ✅ **Check-in & Check-out Date Fields**
                Row(
                  children: [
                    Expanded(
                        child: _buildDateField(
                            "Check-in Date",
                            checkinController,
                            () => selectDate(Get.context!, true))),
                    SizedBox(width: 20),
                    Expanded(
                        child: _buildDateField(
                            "Check-out Date",
                            checkoutController,
                            () => selectDate(Get.context!, false))),
                  ],
                ),
                SizedBox(height: 20),

                _buildTextField(
                  rateController,
                  "Rate Per Night",
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                      value!.isEmpty ? "Enter rate per night" : null,
                ),
                _buildTextField(
                  discountController,
                  "Discount",
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                      value!.isEmpty ? "Enter discount" : null,
                ),
                _buildTextField(
                  prepaymentController,
                  "Prepayment",
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                      value!.isEmpty ? "Enter prepayment" : null,
                ),
                SizedBox(height: 10),
                Obx(() => Column(
                      children: [
                        _buildSummaryRow("Subtotal", subtotal.value),
                        _buildSummaryRow("Tax (5%)", tax.value),
                        _buildSummaryRow("Grand Total", grandTotal.value,
                            isBold: true),
                        _buildSummaryRow("Balance", balance.value,
                            isBold: true, color: Colors.red),
                      ],
                    )),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () async {
                    if (formKey.currentState!.validate() ) {
                      ReservationModel newReservation = ReservationModel(
                        userId: 1,
                        // Replace with actual user ID logic
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
                      );

                      if (reservation == null) {
                        await reservationController
                            .addReservation(newReservation);
                      } else {
                        newReservation.id = reservation.id;
                        await reservationController
                            .updateReservation(newReservation);
                      }
                      Get.back();
                      await reservationController.fetchReservations();
                    }
                  },
                  child: Text(reservation == null
                      ? "Add Reservation"
                      : "Update Reservation"),
                ),
              ],
            ),
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  /// ✅ **Reusable Date Picker Field**
  Widget _buildDateField(
      String label, TextEditingController controller, VoidCallback onTap) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
        suffixIcon: Icon(Icons.calendar_today),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Please select $label";
        }
        return null;
      },
      onTap: onTap,
    );
  }

  /// ✅ Reusable TextField
  Widget _buildTextField(TextEditingController controller, String label,
      {String? Function(String?)? validator, TextInputType? keyboardType}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration:
            InputDecoration(labelText: label, border: OutlineInputBorder()),
        validator: validator,
      ),
    );
  }

  /// ✅ Counter Widget
  Widget _buildCounter(String label, RxInt count) {
    return Column(
      children: [
        Text(label,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        Row(
          children: [
            IconButton(
              onPressed: () {
                if (count.value > 0) count.value--;
              },
              icon: Icon(Icons.remove_circle_outline, color: Colors.red),
            ),
            Obx(() =>
                Text(count.value.toString(), style: TextStyle(fontSize: 18))),
            IconButton(
              onPressed: () {
                count.value++;
              },
              icon: Icon(Icons.add_circle_outline, color: Colors.green),
            ),
          ],
        ),
      ],
    );
  }

  /// ✅ Summary Row Widget
  Widget _buildSummaryRow(String label, double value,
      {bool isBold = false, Color color = Colors.black}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                  color: color)),
          Text("\$${value.toStringAsFixed(2)}",
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                  color: color)),
        ],
      ),
    );
  }
}
