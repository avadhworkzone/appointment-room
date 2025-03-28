// ignore_for_file: invalid_use_of_protected_member

import 'package:cal_room/controller/reservation_controller.dart';
import 'package:cal_room/controller/room_controller.dart';
import 'package:cal_room/model/reservation_model.dart';
import 'package:cal_room/model/room_model.dart';
import 'package:cal_room/utils/color_utils.dart';
import 'package:cal_room/utils/string_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

/// ✅ Show Add/Edit Reservation Dialog
Future<dynamic> addEditReservationBottomSheet(
    {ReservationModel? reservation}) async {
  return await Get.bottomSheet(
    AddEditReservationWidget(
      reservation: reservation,
    ),
    isScrollControlled: true,
  );
}

class AddEditReservationWidget extends StatefulWidget {
  const AddEditReservationWidget({super.key, this.reservation});

  final ReservationModel? reservation;

  @override
  State<AddEditReservationWidget> createState() =>
      _AddEditReservationWidgetState();
}

class _AddEditReservationWidgetState extends State<AddEditReservationWidget> {
  final formKey = GlobalKey<FormState>();
  bool isLoading = false;

  final ReservationController reservationController =
      Get.find<ReservationController>();
  TextEditingController checkinController = TextEditingController();
  TextEditingController checkoutController = TextEditingController();
  TextEditingController fullnameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController rateController = TextEditingController();
  TextEditingController discountController = TextEditingController();
  TextEditingController prepaymentController = TextEditingController();
  TextEditingController roomController = TextEditingController();
  DateTime? checkinDate;
  DateTime? checkoutDate;
  RoomModel? selectedRoom;

  var adultCount = 1.obs;
  var childCount = 0.obs;
  var petCount = 0.obs;
  var subtotal = 0.0.obs;
  var tax = 0.0.obs;
  var grandTotal = 0.0.obs;
  var balance = 0.0.obs;
  ReservationModel? reservation;

  @override
  void initState() {
    init();
    super.initState();
  }

  void init() {
    roomController.text = widget.reservation?.roomName ?? "";
    reservation = widget.reservation;

    /// ✅ **Pre-fill data when editing a reservation**
    if (reservation != null) {
      checkinController.text = reservation!.checkin;
      checkoutController.text = reservation!.checkout;
      fullnameController.text = reservation!.fullname;
      phoneController.text = reservation!.phone;
      emailController.text = reservation!.email;
      rateController.text = reservation!.ratePerNight.toString();
      discountController.text = reservation!.discount.toString();
      prepaymentController.text = reservation!.prepayment.toString();
      adultCount.value = reservation!.adult;
      childCount.value = reservation!.child;
      petCount.value = reservation!.pet;
      selectedRoom = RoomModel(
          roomName: reservation!.roomName,
          roomDesc: "",
          userId: 0,
          id: reservation!.roomId);
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
  }

  /// ✅ **Pick a date and validate it**
  Future<void> selectDate(BuildContext context, bool isCheckIn) async {
    DateTime initialDate = isCheckIn
        ? DateTime.now() // Check-in starts today
        : checkinDate ??
            DateTime.now()
                .add(Duration(days: 1)); // Check-out starts after check-in

    DateTime firstDate = isCheckIn
        ? DateTime.now() // Check-in cannot be before today
        // ? DateTime(1999) // Check-in cannot be before today
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

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColorUtils.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: StatefulBuilder(
        builder: (context, bottomSetState) {
          return SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      InkWell(
                          onTap: () {
                            Get.back();
                          },
                          child: Icon(
                            Icons.arrow_back_outlined,
                            color: ColorUtils.black,
                          )),
                      Spacer(),
                      Text(
                        reservation == null
                            ? StringUtils.addReservation
                            : StringUtils.editReservation,
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Spacer(),
                    ],
                  ),
                  SizedBox(height: 20),
                  Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: TextFormField(
                      onTap: () {
                        RoomModel? selectedDialogRoom = selectedRoom;
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
                                      children: RoomController.to.roomList.value
                                          .map((e) => ListTile(
                                                onTap: () {
                                                  dialogSetState(() {
                                                    selectedDialogRoom = e;
                                                  });
                                                },
                                                leading: Icon(
                                                    selectedDialogRoom?.id == e.id
                                                        ? Icons
                                                            .radio_button_checked
                                                        : Icons.radio_button_off),
                                                title: Text(e.roomName),
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
                                        if (selectedDialogRoom != null) {
                                          bottomSetState(() {
                                            selectedRoom = selectedDialogRoom;
                                            roomController.text =
                                                selectedDialogRoom?.roomName ??
                                                    "";
                                            Get.back();
                                          });
                                        }
                                      },
                                      child: Text(StringUtils.ok)),
                                ],
                              );
                            },
                          ),
                        );
                      },
                      readOnly: true,
                      controller: roomController,
                      decoration: InputDecoration(
                          suffixIcon: Icon(Icons.arrow_drop_down),
                          labelText: StringUtils.room,
                          border: OutlineInputBorder()),
                      validator: (value) =>
                          value!.isEmpty ? StringUtils.selectRoom : null,
                    ),
                  ),
                  _buildTextField(
                    fullnameController,
                    StringUtils.fullName,
                    keyboardType: TextInputType.text,
                    validator: (value) =>
                        value!.isEmpty ? StringUtils.enterFullName : null,
                  ),
                  _buildTextField(phoneController, StringUtils.phone,
                      keyboardType: TextInputType.phone, validator: (value) {
                    if (value!.isEmpty) {
                      return StringUtils.enterMobileNumber;
                    } else if (value.length < 10 || value.length > 10) {
                      return StringUtils.phoneDigits;
                    }
                    return null;
                  }),
                  _buildTextField(
                    emailController,
                    StringUtils.email,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) => value!.isEmpty ? StringUtils.enterEmail : null,
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildCounter(StringUtils.adults, adultCount),
                      _buildCounter(StringUtils.children, childCount),
                      _buildCounter(StringUtils.pets, petCount),
                    ],
                  ),
                  SizedBox(height: 10),

                  /// ✅ **Check-in & Check-out Date Fields**
                  Row(
                    children: [
                      Expanded(
                          child: _buildDateField(
                              StringUtils.checkinDate,
                              checkinController,
                              () => selectDate(Get.context!, true))),
                      SizedBox(width: 20),
                      Expanded(
                          child: _buildDateField(
                              StringUtils.checkoutDate,
                              checkoutController,
                              () => selectDate(Get.context!, false))),
                    ],
                  ),
                  SizedBox(height: 20),

                  _buildTextField(
                    rateController,
                    StringUtils.ratePerNight,
                    keyboardType: TextInputType.number,
                    validator: (value) =>
                        value!.isEmpty ?  StringUtils.enterRatePerNight : null,
                  ),
                  _buildTextField(
                    discountController,
                    StringUtils.discount,
                    keyboardType: TextInputType.number,
                    validator: (value) =>
                        value!.isEmpty ? StringUtils.enterDiscount : null,
                  ),
                  _buildTextField(
                    prepaymentController,
                    StringUtils.prepayment,
                    keyboardType: TextInputType.number,
                    validator: (value) =>
                        value!.isEmpty ? StringUtils.enterPrepayment : null,
                  ),
                  SizedBox(height: 10),
                  Obx(() => Column(
                        children: [
                          _buildSummaryRow(StringUtils.subtotal, subtotal.value),
                          _buildSummaryRow(StringUtils.tax, tax.value),
                          _buildSummaryRow(StringUtils.grandTotal, grandTotal.value,
                              isBold: true),
                          _buildSummaryRow(StringUtils.balance, balance.value,
                              isBold: true, color: ColorUtils.red),
                        ],
                      )),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: isLoading?null:() async {
                      if (formKey.currentState!.validate()) {
                        final checkIn = DateTime.parse(checkinController.text);
                        final checkOut =
                            DateTime.parse(checkoutController.text);
                        if (checkIn.isAtSameMomentAs(checkOut)) {
                          Get.snackbar(
                            StringUtils.attention,
                            StringUtils.dateError,
                            backgroundColor: ColorUtils.blue,
                          );
                          return;
                        }
                        final isContain = ReservationController
                            .to.reservationList.value
                            .any((element) {
                       /*   print(
                              'ID :=>${element.roomId} SEL :=> ${selectedRoom?.id} CHE IN :=> ${element.checkin} CHE OU :=> ${element.checkout}');
                          if (((checkIn.isAfter(DateTime.parse(element.checkin)) || checkIn.isAtSameMomentAs(DateTime.parse(element.checkin))) &&
                                  (checkOut.isBefore(DateTime.parse(element.checkout)) ||
                                      checkOut.isAtSameMomentAs(
                                          DateTime.parse(element.checkout)))) &&
                              element.roomId == selectedRoom?.id &&
                              reservation?.id != element.id) {
                            print(
                                "FIRST -------> ${element.checkin} O :=>${element.checkout}");
                          } else if ((checkOut.isAfter(DateTime.parse(element.checkin)) &&
                                  (checkOut.isBefore(DateTime.parse(element.checkout)) ||
                                      checkOut.isAtSameMomentAs(
                                          DateTime.parse(element.checkout)))) &&
                              element.roomId == selectedRoom?.id &&
                              reservation?.id != element.id) {
                            print(
                                "SECOND -------> ${element.checkin} O :=>${element.checkout}");
                          } else if (((checkIn.isAfter(DateTime.parse(element.checkin)) ||
                                      checkIn.isAtSameMomentAs(
                                          DateTime.parse(element.checkin))) &&
                                  checkIn.isBefore(
                                      DateTime.parse(element.checkout))) &&
                              element.roomId == selectedRoom?.id &&
                              reservation?.id != element.id) {
                            print(
                                "3 -------> ${element.checkin} O :=>${element.checkout}");
                          } else if ((DateTime.parse(element.checkin).isAfter(checkIn) &&
                                  DateTime.parse(element.checkout).isBefore(checkOut)) &&
                              element.roomId == selectedRoom?.id &&
                              reservation?.id != element.id) {
                            print(
                                "4 -------> ${element.checkin} O :=>${element.checkout}");
                          }*/
                          return ((((checkIn.isAfter(DateTime.parse(element.checkin)) || checkIn.isAtSameMomentAs(DateTime.parse(element.checkin))) &&
                                      (checkOut.isBefore(DateTime.parse(element.checkout)) ||
                                          checkOut.isAtSameMomentAs(DateTime.parse(
                                              element.checkout)))) ||
                                  (checkOut.isAfter(DateTime.parse(element.checkin)) &&
                                      (checkOut.isBefore(DateTime.parse(element.checkout)) ||
                                          checkOut.isAtSameMomentAs(
                                              DateTime.parse(
                                                  element.checkout)))) ||
                                  ((checkIn.isAfter(DateTime.parse(element.checkin)) ||
                                      checkIn.isAtSameMomentAs(
                                          DateTime.parse(element.checkin))) &&
                                      checkIn.isBefore(
                                          DateTime.parse(element.checkout))) ||
                                  (DateTime.parse(element.checkin)
                                          .isAfter(checkIn) &&
                                      DateTime.parse(element.checkout)
                                          .isBefore(checkOut))) &&
                              element.roomId == selectedRoom?.id &&
                              reservation?.id != element.id);
                        });
                        if (isContain) {
                          Get.snackbar(
                            StringUtils.attention,
                            StringUtils.overlapDateError,
                            backgroundColor: ColorUtils.blue,
                          );
                          return;
                        }
                        setState(() => isLoading = true);

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
                          roomId: selectedRoom?.id ?? 0,
                          roomName: selectedRoom?.roomName ?? "",
                        );

                        if (reservation == null) {
                          await reservationController
                              .addReservation(newReservation);
                        } else {
                          newReservation.id = reservation?.id ?? 0;
                          await reservationController
                              .updateReservation(newReservation);
                        }
                        setState(() => isLoading = false);

                        Get.back(result: newReservation);
                        await reservationController.fetchReservations();
                      }
                    },
                    child: isLoading
                        ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: ColorUtils.white,
                        strokeWidth: 2,
                      ),
                    )
                        :Text(reservation == null
                        ? StringUtils.addReservation
                        : StringUtils.updateReservation),
                  ),
                ],
              ),
            ),
          );
        },
      ),
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
              icon: Icon(Icons.remove_circle_outline, color: ColorUtils.red),
            ),
            Obx(() =>
                Text(count.value.toString(), style: TextStyle(fontSize: 18))),
            IconButton(
              onPressed: () {
                count.value++;
              },
              icon: Icon(Icons.add_circle_outline, color: ColorUtils.green),
            ),
          ],
        ),
      ],
    );
  }

  /// ✅ Summary Row Widget
  Widget _buildSummaryRow(String label, double value,
      {bool isBold = false, Color color = ColorUtils.black}) {
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
