// // ignore_for_file: invalid_use_of_protected_member
//
// // import 'package:cal_room/controller/reservation_controller.dart';
// import 'package:cal_room/controller/room_controller.dart';
// import 'package:cal_room/model/reservation_model.dart';
// import 'package:cal_room/model/room_model.dart';
// import 'package:cal_room/utils/color_utils.dart';
// import 'package:cal_room/utils/string_utils.dart';
// import 'package:flutter/material.dart';

// import 'package:intl/intl.dart';
//
// /// ✅ Show Add/Edit Reservation Dialog
// // Future<dynamic> addEditReservationBottomSheet(
// //     {ReservationModel? reservation}) async {
// //   return await Get.bottomSheet(
// //     AddEditReservationWidget(
// //       reservation: reservation,
// //     ),
// //     isScrollControlled: true,
// //   );
// // }
// Future<dynamic> addEditReservationBottomSheet(BuildContext context, {ReservationModel? reservation}) async {
//   return await showModalBottomSheet(
//     context: context,
//     isScrollControlled: true,
//     builder: (context) => Padding(
//       padding: EdgeInsets.only(
//         bottom: MediaQuery.of(context).viewInsets.bottom,
//       ),
//       child: AddEditReservationWidget(
//         reservation: reservation,
//       ),
//     ),
//   );
// }
//
// class AddEditReservationWidget extends StatefulWidget {
//   const AddEditReservationWidget({super.key, this.reservation});
//
//   final ReservationModel? reservation;
//
//   @override
//   State<AddEditReservationWidget> createState() =>
//       _AddEditReservationWidgetState();
// }
//
// class _AddEditReservationWidgetState extends State<AddEditReservationWidget> {
//   final formKey = GlobalKey<FormState>();
//   bool isLoading = false;
//
//   // final ReservationController reservationController =
//   //     Get.find<ReservationController>();
//   TextEditingController taxPercentController = TextEditingController();
//   TextEditingController checkinController = TextEditingController();
//   TextEditingController checkoutController = TextEditingController();
//   TextEditingController fullnameController = TextEditingController();
//   TextEditingController phoneController = TextEditingController();
//   TextEditingController emailController = TextEditingController();
//   TextEditingController rateController = TextEditingController();
//   TextEditingController discountController = TextEditingController();
//   TextEditingController prepaymentController = TextEditingController();
//   TextEditingController roomController = TextEditingController();
//   DateTime? checkinDate;
//   DateTime? checkoutDate;
//   RoomModel? selectedRoom;
//   List<RoomModel> selectedRoomsList = [];
//
//   var adultCount = 1;
//   var childCount = 0;
//   var petCount = 0;
//   var subtotal = 0.0;
//   var tax = 0.0.;
//   var grandTotal = 0.0.obs;
//   var balance = 0.0.obs;
//   ReservationModel? reservation;
//
//   @override
//   void initState() {
//     init();
//     super.initState();
//   }
//
//   void init() {
//     reservation = widget.reservation;
//
//     /// ✅ **Pre-fill data when editing a reservation**
//     if (reservation != null) {
//       roomController.text = widget.reservation?.rooms
//               .map(
//                 (e) => e.roomName,
//               )
//               .toList()
//               .join(",") ??
//           "";
//       checkinController.text = reservation!.checkin;
//       checkoutController.text = reservation!.checkout;
//       fullnameController.text = reservation!.fullname;
//       phoneController.text = reservation!.phone;
//       emailController.text = reservation!.email;
//       rateController.text = reservation!.ratePerNight.toString();
//       discountController.text = reservation!.discount.toString();
//       prepaymentController.text = reservation!.prepayment.toString();
//       adultCount.value = reservation!.adult;
//       childCount.value = reservation!.child;
//       petCount.value = reservation!.pet;
//       double taxPercentage = reservation!.subtotal != 0
//           ? (reservation!.tax / reservation!.subtotal) * 100
//           : 5.0;
//       taxPercentController.text = taxPercentage.toStringAsFixed(2);
//       selectedRoomsList = reservation!.rooms;
//       selectedRoom = RoomModel(
//           roomName: reservation!.roomName,
//           roomDesc: "",
//           userId: 0,
//           id: reservation!.roomId);
//       calculateTotal();
//     } else {
//       taxPercentController.text = "5";
//       rateController.text = "100"; // Default rate
//       discountController.text = "0";
//       prepaymentController.text = "0";
//       calculateTotal();
//     }
//
//     /// ✅ **Call `_calculateTotal()` whenever rate, discount, or prepayment changes**
//     rateController.addListener(calculateTotal);
//     discountController.addListener(calculateTotal);
//     prepaymentController.addListener(calculateTotal);
//     taxPercentController.addListener(calculateTotal);
//   }
//
//   /// ✅ **Pick a date and validate it**
//   Future<void> selectDate(BuildContext context, bool isCheckIn) async {
//     DateTime initialDate = isCheckIn
//         ? DateTime.now() // Check-in starts today
//         : checkinDate ??
//             DateTime.now()
//                 .add(Duration(days: 1)); // Check-out starts after check-in
//
//     DateTime firstDate = isCheckIn
//         ? DateTime.now() // Check-in cannot be before today
//         // ? DateTime(1999) // Check-in cannot be before today
//         : checkinDate ?? DateTime.now(); // Check-out must be after check-in
//
//     DateTime? pickedDate = await showDatePicker(
//       context: context,
//       initialDate: initialDate,
//       firstDate: firstDate,
//       lastDate: DateTime(2100),
//     );
//
//     if (pickedDate != null) {
//       if (isCheckIn) {
//         checkinDate = pickedDate;
//         checkinController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
//
//         // Auto-reset checkout if it's before the check-in
//         if (checkoutDate != null && checkoutDate!.isBefore(checkinDate!)) {
//           checkoutDate = checkinDate!.add(Duration(days: 1));
//           checkoutController.text =
//               DateFormat('yyyy-MM-dd').format(checkoutDate!);
//         }
//         calculateTotal();
//       } else {
//         checkoutDate = pickedDate;
//         checkoutController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
//         calculateTotal();
//       }
//     }
//   }
//
//   /// ✅ **Calculates Tax, Grand Total & Balance**
//   // void calculateTotal() {
//   //   double rate = double.tryParse(rateController.text) ?? 0.0;
//   //   double discount = double.tryParse(discountController.text) ?? 0.0;
//   //   double prepayment = double.tryParse(prepaymentController.text) ?? 0.0;
//   //   double taxPercent = double.tryParse(taxPercentController.text) ?? 0.0;
//   //   subtotal.value = rate;
//   //   tax.value = subtotal.value * (taxPercent / 100);
//   //
//   //   // tax.value = subtotal.value * 0.05; // 5% Tax
//   //   grandTotal.value = (subtotal.value - discount) + tax.value;
//   //   balance.value = grandTotal.value - prepayment;
//   // }
//   void calculateTotal() {
//     double rate = double.tryParse(rateController.text) ?? 0.0;
//     double discount = double.tryParse(discountController.text) ?? 0.0;
//     double prepayment = double.tryParse(prepaymentController.text) ?? 0.0;
//     double taxPercent = double.tryParse(taxPercentController.text) ?? 0.0;
//
//     // int numRooms = selectedRoomsList.length;
//     int nights = 1;
//     if (checkinController.text.isNotEmpty &&
//         checkoutController.text.isNotEmpty) {
//       DateTime checkIn =
//           DateTime.tryParse(checkinController.text) ?? DateTime.now();
//       DateTime checkOut = DateTime.tryParse(checkoutController.text) ??
//           DateTime.now().add(Duration(days: 1));
//       nights = checkOut.difference(checkIn).inDays;
//       if (nights < 1) nights = 1;
//     }
//
//     double roomNightMultiplier =
//         // double.parse(numRooms.toString()) *
//         double.parse(nights.toString());
//
//     subtotal.value = rate * roomNightMultiplier;
//     discount = discount;
//     tax.value = subtotal.value * (taxPercent / 100);
//     grandTotal.value = (subtotal.value - discount) + tax.value;
//     balance.value = grandTotal.value - prepayment;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: ColorUtils.white,
//         borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
//       ),
//       child: StatefulBuilder(
//         builder: (context, bottomSetState) {
//           return SingleChildScrollView(
//             child: Form(
//               key: formKey,
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Row(
//                     children: [
//                       InkWell(
//                           onTap: () {
//                             Get.back();
//                           },
//                           child: Icon(
//                             Icons.arrow_back_outlined,
//                             color: ColorUtils.black,
//                           )),
//                       Spacer(),
//                       Text(
//                         reservation == null
//                             ? StringUtils.addReservation
//                             : StringUtils.editReservation,
//                         style: TextStyle(
//                             fontSize: 18, fontWeight: FontWeight.bold),
//                       ),
//                       Spacer(),
//                     ],
//                   ),
//                   SizedBox(height: 20),
//                   Padding(
//                     padding: EdgeInsets.only(bottom: 8),
//                     child: TextFormField(
//                       onTap: () {
//                         roomDialog(
//                           () {
//                             bottomSetState(() {});
//                           },
//                         );
//                       },
//                       readOnly: true,
//                       controller: roomController,
//                       decoration: InputDecoration(
//                           suffixIcon: Icon(Icons.arrow_drop_down),
//                           labelText: StringUtils.room,
//                           border: OutlineInputBorder()),
//                       validator: (value) =>
//                           value!.isEmpty ? StringUtils.selectRoom : null,
//                     ),
//                   ),
//                   _buildTextField(
//                     fullnameController,
//                     StringUtils.fullName,
//                     keyboardType: TextInputType.text,
//                     validator: (value) =>
//                         value!.isEmpty ? StringUtils.enterFullName : null,
//                   ),
//                   _buildTextField(phoneController, StringUtils.phone,
//                       keyboardType: TextInputType.phone, validator: (value) {
//                     if (value!.isEmpty) {
//                       return StringUtils.enterMobileNumber;
//                     } else if (value.length < 10 || value.length > 10) {
//                       return StringUtils.phoneDigits;
//                     }
//                     return null;
//                   }),
//                   _buildTextField(
//                     emailController,
//                     StringUtils.email,
//                     keyboardType: TextInputType.emailAddress,
//                     validator: (value) =>
//                         value!.isEmpty ? StringUtils.enterEmail : null,
//                   ),
//                   SizedBox(height: 10),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                     children: [
//                       _buildCounter(StringUtils.adults, adultCount),
//                       _buildCounter(StringUtils.children, childCount),
//                       _buildCounter(StringUtils.pets, petCount),
//                     ],
//                   ),
//                   SizedBox(height: 10),
//
//                   /// ✅ **Check-in & Check-out Date Fields**
//                   Row(
//                     children: [
//                       Expanded(
//                           child: _buildDateField(
//                               StringUtils.checkinDate,
//                               checkinController,
//                               () => selectDate(Get.context!, true))),
//                       SizedBox(width: 20),
//                       Expanded(
//                           child: _buildDateField(
//                               StringUtils.checkoutDate,
//                               checkoutController,
//                               () => selectDate(Get.context!, false))),
//                     ],
//                   ),
//                   SizedBox(height: 20),
//
//                   _buildTextField(
//                     rateController,
//                     StringUtils.ratePerNight,
//                     keyboardType: TextInputType.number,
//                     validator: (value) =>
//                         value!.isEmpty ? StringUtils.enterRatePerNight : null,
//                   ),
//                   _buildTextField(
//                     discountController,
//                     StringUtils.discount,
//                     keyboardType: TextInputType.number,
//                     validator: (value) =>
//                         value!.isEmpty ? StringUtils.enterDiscount : null,
//                   ),
//                   _buildTextField(
//                     prepaymentController,
//                     StringUtils.prepayment,
//                     keyboardType: TextInputType.number,
//                     validator: (value) =>
//                         value!.isEmpty ? StringUtils.enterPrepayment : null,
//                   ),
//                   _buildTextField(
//                     taxPercentController,
//                     "${StringUtils.tax} %",
//                     keyboardType: TextInputType.number,
//                     validator: (value) =>
//                         value!.isEmpty ? "Enter tax percentage" : null,
//                   ),
//
//                   SizedBox(height: 10),
//                   Obx(() => Column(
//                         children: [
//                           _buildSummaryRow(
//                               StringUtils.subtotal, subtotal.value),
//                           _buildSummaryRow(StringUtils.tax, tax.value),
//                           _buildSummaryRow(
//                               StringUtils.grandTotal, grandTotal.value,
//                               isBold: true),
//                           _buildSummaryRow(StringUtils.balance, balance.value,
//                               isBold: true, color: ColorUtils.red),
//                         ],
//                       )),
//                   SizedBox(height: 10),
//                   ElevatedButton(
//                     onPressed: isLoading
//                         ? null
//                         : () async {
//                             if (formKey.currentState!.validate()) {
//                               final checkIn =
//                                   DateTime.parse(checkinController.text);
//                               final checkOut =
//                                   DateTime.parse(checkoutController.text);
//                               if (checkIn.isAtSameMomentAs(checkOut)) {
//                                 Get.snackbar(
//                                   StringUtils.attention,
//                                   StringUtils.dateError,
//                                   backgroundColor: ColorUtils.blue,
//                                 );
//                                 return;
//                               }
//                               final isContain = ReservationController
//                                   .to.reservationList.value
//                                   .any((element) {
//                                 /*   print(
//                               'ID :=>${element.roomId} SEL :=> ${selectedRoom?.id} CHE IN :=> ${element.checkin} CHE OU :=> ${element.checkout}');
//                           if (((checkIn.isAfter(DateTime.parse(element.checkin)) || checkIn.isAtSameMomentAs(DateTime.parse(element.checkin))) &&
//                                   (checkOut.isBefore(DateTime.parse(element.checkout)) ||
//                                       checkOut.isAtSameMomentAs(
//                                           DateTime.parse(element.checkout)))) &&
//                               element.roomId == selectedRoom?.id &&
//                               reservation?.id != element.id) {
//                             print(
//                                 "FIRST -------> ${element.checkin} O :=>${element.checkout}");
//                           } else if ((checkOut.isAfter(DateTime.parse(element.checkin)) &&
//                                   (checkOut.isBefore(DateTime.parse(element.checkout)) ||
//                                       checkOut.isAtSameMomentAs(
//                                           DateTime.parse(element.checkout)))) &&
//                               element.roomId == selectedRoom?.id &&
//                               reservation?.id != element.id) {
//                             print(
//                                 "SECOND -------> ${element.checkin} O :=>${element.checkout}");
//                           } else if (((checkIn.isAfter(DateTime.parse(element.checkin)) ||
//                                       checkIn.isAtSameMomentAs(
//                                           DateTime.parse(element.checkin))) &&
//                                   checkIn.isBefore(
//                                       DateTime.parse(element.checkout))) &&
//                               element.roomId == selectedRoom?.id &&
//                               reservation?.id != element.id) {
//                             print(
//                                 "3 -------> ${element.checkin} O :=>${element.checkout}");
//                           } else if ((DateTime.parse(element.checkin).isAfter(checkIn) &&
//                                   DateTime.parse(element.checkout).isBefore(checkOut)) &&
//                               element.roomId == selectedRoom?.id &&
//                               reservation?.id != element.id) {
//                             print(
//                                 "4 -------> ${element.checkin} O :=>${element.checkout}");
//                           }*/
//                                 return ((((checkIn.isAfter(DateTime.parse(element.checkin)) || checkIn.isAtSameMomentAs(DateTime.parse(element.checkin))) &&
//                                             (checkOut.isBefore(DateTime.parse(element.checkout)) ||
//                                                 checkOut.isAtSameMomentAs(
//                                                     DateTime.parse(
//                                                         element.checkout)))) ||
//                                         (checkOut.isAfter(DateTime.parse(element.checkin)) &&
//                                             (checkOut.isBefore(DateTime.parse(element.checkout)) ||
//                                                 checkOut.isAtSameMomentAs(
//                                                     DateTime.parse(
//                                                         element.checkout)))) ||
//                                         ((checkIn.isAfter(DateTime.parse(element.checkin)) ||
//                                                 checkIn.isAtSameMomentAs(
//                                                     DateTime.parse(element.checkin))) &&
//                                             checkIn.isBefore(DateTime.parse(element.checkout))) ||
//                                         (DateTime.parse(element.checkin).isAfter(checkIn) && DateTime.parse(element.checkout).isBefore(checkOut))) &&
//                                     // element.roomId == selectedRoom?.id &&
//                                     element.rooms
//                                         .where(
//                                           (e1) => selectedRoomsList.any(
//                                             (e2) => e2.id == e1.id,
//                                           ),
//                                         )
//                                         .toList()
//                                         .isNotEmpty &&
//                                     reservation?.id != element.id);
//                               });
//                               if (isContain) {
//                                 Get.snackbar(
//                                   StringUtils.attention,
//                                   StringUtils.overlapDateError,
//                                   backgroundColor: ColorUtils.blue,
//                                 );
//                                 return;
//                               }
//                               setState(() => isLoading = true);
//
//                               ReservationModel newReservation =
//                                   ReservationModel(
//                                       userId: 1,
//                                       // Replace with actual user ID logic
//                                       checkin: checkinController.text,
//                                       checkout: checkoutController.text,
//                                       fullname: fullnameController.text,
//                                       phone: phoneController.text,
//                                       email: emailController.text,
//                                       adult: adultCount.value,
//                                       child: childCount.value,
//                                       pet: petCount.value,
//                                       ratePerNight:
//                                           double.parse(rateController.text),
//                                       subtotal: subtotal.value,
//                                       discount:
//                                           double.parse(discountController.text),
//                                       tax: tax.value,
//                                       grandTotal: grandTotal.value,
//                                       prepayment: double.parse(
//                                           prepaymentController.text),
//                                       balance: balance.value,
//                                       roomId: selectedRoom?.id ?? 0,
//                                       roomName: selectedRoom?.roomName ?? "",
//                                       rooms: selectedRoomsList);
//
//                               if (reservation == null) {
//                                 await reservationController
//                                     .addReservation(newReservation);
//                               } else {
//                                 newReservation.id = reservation?.id ?? 0;
//                                 await reservationController
//                                     .updateReservation(newReservation);
//                               }
//                               Get.back(result: newReservation);
//                               if (mounted) {
//                                 setState(() => isLoading = false);
//                               }
//                               await reservationController.fetchReservations();
//                             }
//                           },
//                     child: isLoading
//                         ? SizedBox(
//                             width: 20,
//                             height: 20,
//                             child: CircularProgressIndicator(
//                               color: ColorUtils.white,
//                               strokeWidth: 2,
//                             ),
//                           )
//                         : Text(reservation == null
//                             ? StringUtils.addReservation
//                             : StringUtils.updateReservation),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
//
//   void roomDialog(VoidCallback onTap) {
//     List<RoomModel> selectedDialogRoom = selectedRoomsList;
//     Get.dialog(
//       StatefulBuilder(
//         builder: (context, dialogSetState) {
//           return AlertDialog(
//             insetPadding: EdgeInsets.zero,
//             contentPadding: EdgeInsets.zero,
//             title: Text(StringUtils.room),
//             content: SizedBox(
//               width: Get.width - 60,
//               child: SingleChildScrollView(
//                 physics: ClampingScrollPhysics(),
//                 child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: RoomController.to.roomList.value
//                         .map((e) => ListTile(
//                               onTap: () {
//                                 final roomIndex = selectedDialogRoom.indexWhere(
//                                   (element) => element.id == e.id,
//                                 );
//                                 if (roomIndex > -1) {
//                                   dialogSetState(() {
//                                     selectedDialogRoom.removeAt(roomIndex);
//                                   });
//                                 } else {
//                                   dialogSetState(() {
//                                     selectedDialogRoom.add(e);
//                                   });
//                                 }
//                               },
//                               leading: Checkbox(
//                                 value: selectedDialogRoom
//                                     .any((element) => element.id == e.id),
//                                 onChanged: (bool? value) {
//                                   dialogSetState(() {
//                                     if (value == true) {
//                                       selectedDialogRoom.add(e);
//                                     } else {
//                                       selectedDialogRoom.removeWhere(
//                                           (element) => element.id == e.id);
//                                     }
//                                   });
//                                 },
//                               ),
//                               title: Text(e.roomName),
//                             ))
//                         .toList()),
//               ),
//             ),
//             actions: [
//               TextButton(
//                   onPressed: () {
//                     Get.back();
//                   },
//                   child: Text(StringUtils.cancelCapital)),
//               TextButton(
//                   onPressed: () {
//                     selectedRoomsList = selectedDialogRoom;
//                     Get.back();
//                     roomController.text = selectedRoomsList
//                         .map(
//                           (e) => e.roomName,
//                         )
//                         .toList()
//                         .join(",");
//                     onTap();
//                   },
//                   child: Text(StringUtils.ok)),
//             ],
//           );
//         },
//       ),
//     );
//   }
//
//   /// ✅ **Reusable Date Picker Field**
//   Widget _buildDateField(
//       String label, TextEditingController controller, VoidCallback onTap) {
//     return TextFormField(
//       controller: controller,
//       readOnly: true,
//       decoration: InputDecoration(
//         labelText: label,
//         border: OutlineInputBorder(),
//         suffixIcon: Icon(Icons.calendar_today),
//       ),
//       validator: (value) {
//         if (value == null || value.isEmpty) {
//           return "Please select $label";
//         }
//         return null;
//       },
//       onTap: onTap,
//     );
//   }
//
//   /// ✅ Reusable TextField
//   Widget _buildTextField(TextEditingController controller, String label,
//       {String? Function(String?)? validator, TextInputType? keyboardType}) {
//     return Padding(
//       padding: EdgeInsets.only(bottom: 8),
//       child: TextFormField(
//         controller: controller,
//         keyboardType: keyboardType,
//         decoration:
//             InputDecoration(labelText: label, border: OutlineInputBorder()),
//         validator: validator,
//       ),
//     );
//   }
//
//   /// ✅ Counter Widget
//   Widget _buildCounter(String label, RxInt count) {
//     return Column(
//       children: [
//         Text(label,
//             style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//         Row(
//           children: [
//             IconButton(
//               onPressed: () {
//                 if (count.value > 0) count.value--;
//               },
//               icon: Icon(Icons.remove_circle_outline, color: ColorUtils.red),
//             ),
//             Obx(() =>
//                 Text(count.value.toString(), style: TextStyle(fontSize: 18))),
//             IconButton(
//               onPressed: () {
//                 count.value++;
//               },
//               icon: Icon(Icons.add_circle_outline, color: ColorUtils.green),
//             ),
//           ],
//         ),
//       ],
//     );
//   }
//
//   /// ✅ Summary Row Widget
//   Widget _buildSummaryRow(String label, double value,
//       {bool isBold = false, Color color = ColorUtils.black}) {
//     return Padding(
//       padding: EdgeInsets.symmetric(vertical: 4),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(label,
//               style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
//                   color: color)),
//           Text("\$${value.toStringAsFixed(2)}",
//               style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
//                   color: color)),
//         ],
//       ),
//     );
//   }
// }
// ignore_for_file: invalid_use_of_protected_member

// import 'package:cal_room/controller/reservation_controller.dart';
import 'package:cal_room/blocs/reservation/reservation__bloc.dart';
import 'package:cal_room/blocs/reservation/reservation__event.dart';
import 'package:cal_room/blocs/room/room_bloc.dart';
import 'package:cal_room/blocs/room/room_state.dart';
import 'package:cal_room/model/reservation_model.dart';
import 'package:cal_room/model/room_model.dart';
import 'package:cal_room/utils/color_utils.dart';
import 'package:cal_room/utils/string_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:intl/intl.dart';

/// ✅ Show Add/Edit Reservation Dialog
// Future<dynamic> addEditReservationBottomSheet(
//     {ReservationModel? reservation}) async {
//   return await Get.bottomSheet(
//     AddEditReservationWidget(
//       reservation: reservation,
//     ),
//     isScrollControlled: true,
//   );
// }
Future<dynamic> addEditReservationBottomSheet(BuildContext context,
    {ReservationModel? reservation}) async {
  return await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: AddEditReservationWidget(
        reservation: reservation,
      ),
    ),
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

  // final ReservationController reservationController =
  //     Get.find<ReservationController>();
  TextEditingController taxPercentController = TextEditingController();
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
  List<RoomModel> selectedRoomsList = [];

  var adultCount = 1;
  var childCount = 0;
  var petCount = 0;
  var subtotal = 0.0;
  var tax = 0.0;
  var grandTotal = 0.0;
  var balance = 0.0;
  ReservationModel? reservation;

  @override
  void initState() {
    init();
    super.initState();
  }

  void init() {
    reservation = widget.reservation;

    /// ✅ **Pre-fill data when editing a reservation**
    if (reservation != null) {
      roomController.text = widget.reservation?.rooms
              .map(
                (e) => e.roomName,
              )
              .toList()
              .join(",") ??
          "";
      checkinController.text = reservation!.checkin;
      checkoutController.text = reservation!.checkout;
      fullnameController.text = reservation!.fullname;
      phoneController.text = reservation!.phone;
      emailController.text = reservation!.email;
      rateController.text = reservation!.ratePerNight.toString();
      discountController.text = reservation!.discount.toString();
      prepaymentController.text = reservation!.prepayment.toString();
      adultCount = reservation!.adult;
      childCount = reservation!.child;
      petCount = reservation!.pet;
      double taxPercentage = reservation!.subtotal != 0
          ? (reservation!.tax / reservation!.subtotal) * 100
          : 5.0;
      taxPercentController.text = taxPercentage.toStringAsFixed(2);
      selectedRoomsList = reservation!.rooms;
      selectedRoom = RoomModel(
          roomName: reservation!.roomName,
          roomDesc: "",
          userId: 0,
          id: reservation!.roomId);
      calculateTotal();
    } else {
      taxPercentController.text = "5";
      rateController.text = "100"; // Default rate
      discountController.text = "0";
      prepaymentController.text = "0";
      calculateTotal();
    }

    /// ✅ **Call `_calculateTotal()` whenever rate, discount, or prepayment changes**
    rateController.addListener(calculateTotal);
    discountController.addListener(calculateTotal);
    prepaymentController.addListener(calculateTotal);
    taxPercentController.addListener(calculateTotal);
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
        calculateTotal();
      } else {
        checkoutDate = pickedDate;
        checkoutController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
        calculateTotal();
      }
    }
  }

  /// ✅ **Calculates Tax, Grand Total & Balance**
  // void calculateTotal() {
  //   double rate = double.tryParse(rateController.text) ?? 0.0;
  //   double discount = double.tryParse(discountController.text) ?? 0.0;
  //   double prepayment = double.tryParse(prepaymentController.text) ?? 0.0;
  //   double taxPercent = double.tryParse(taxPercentController.text) ?? 0.0;
  //   subtotal = rate;
  //   tax = subtotal * (taxPercent / 100);
  //
  //   // tax = subtotal * 0.05; // 5% Tax
  //   grandTotal = (subtotal - discount) + tax;
  //   balance = grandTotal - prepayment;
  // }
  void calculateTotal() {
    double rate = double.tryParse(rateController.text) ?? 0.0;
    double discount = double.tryParse(discountController.text) ?? 0.0;
    double prepayment = double.tryParse(prepaymentController.text) ?? 0.0;
    double taxPercent = double.tryParse(taxPercentController.text) ?? 0.0;

    // int numRooms = selectedRoomsList.length;
    int nights = 1;
    if (checkinController.text.isNotEmpty &&
        checkoutController.text.isNotEmpty) {
      DateTime checkIn =
          DateTime.tryParse(checkinController.text) ?? DateTime.now();
      DateTime checkOut = DateTime.tryParse(checkoutController.text) ??
          DateTime.now().add(Duration(days: 1));
      nights = checkOut.difference(checkIn).inDays;
      if (nights < 1) nights = 1;
    }

    double roomNightMultiplier =
        // double.parse(numRooms.toString()) *
        double.parse(nights.toString());

    subtotal = rate * roomNightMultiplier;
    discount = discount;
    tax = subtotal * (taxPercent / 100);
    grandTotal = (subtotal - discount) + tax;
    balance = grandTotal - prepayment;
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
                            Navigator.pop(context);
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
                        roomDialog(context, () {
                          bottomSetState(() {});
                        });
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
                    validator: (value) =>
                        value!.isEmpty ? StringUtils.enterEmail : null,
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
                              () => selectDate(context, true))),
                      SizedBox(width: 20),
                      Expanded(
                          child: _buildDateField(
                              StringUtils.checkoutDate,
                              checkoutController,
                              () => selectDate(context, false))),
                    ],
                  ),
                  SizedBox(height: 20),

                  _buildTextField(
                    rateController,
                    StringUtils.ratePerNight,
                    keyboardType: TextInputType.number,
                    validator: (value) =>
                        value!.isEmpty ? StringUtils.enterRatePerNight : null,
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
                  _buildTextField(
                    taxPercentController,
                    "${StringUtils.tax} %",
                    keyboardType: TextInputType.number,
                    validator: (value) =>
                        value!.isEmpty ? "Enter tax percentage" : null,
                  ),

                  SizedBox(height: 10),
                  Column(
                    children: [
                      _buildSummaryRow(StringUtils.subtotal, subtotal),
                      _buildSummaryRow(StringUtils.tax, tax),
                      _buildSummaryRow(StringUtils.grandTotal, grandTotal,
                          isBold: true),
                      _buildSummaryRow(StringUtils.balance, balance,
                          isBold: true, color: ColorUtils.red),
                    ],
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () async {
                            if (formKey.currentState!.validate()) {
                              final checkIn =
                                  DateTime.parse(checkinController.text);
                              final checkOut =
                                  DateTime.parse(checkoutController.text);
                              if (checkIn.isAtSameMomentAs(checkOut)) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(StringUtils.dateError),
                                    backgroundColor: ColorUtils.blue,
                                    duration: Duration(seconds: 3),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );

                                return;
                              }
                              final reservations = context
                                  .read<ReservationBloc>()
                                  .state
                                  .reservations;

                              final isContain = reservations.any((element) {
                                final elementCheckIn =
                                    DateTime.parse(element.checkin);
                                final elementCheckOut =
                                    DateTime.parse(element.checkout);

                                return (
                                        // Case 1: New check-in within an existing reservation
                                        ((checkIn.isAfter(elementCheckIn) ||
                                                    checkIn.isAtSameMomentAs(
                                                        elementCheckIn)) &&
                                                (checkOut.isBefore(elementCheckOut) ||
                                                    checkOut.isAtSameMomentAs(
                                                        elementCheckOut))) ||

                                            // Case 2: New check-out overlaps with existing reservation
                                            (checkOut.isAfter(elementCheckIn) &&
                                                (checkOut.isBefore(
                                                        elementCheckOut) ||
                                                    checkOut.isAtSameMomentAs(
                                                        elementCheckOut))) ||

                                            // Case 3: New check-in is inside existing reservation range
                                            ((checkIn.isAfter(elementCheckIn) ||
                                                    checkIn.isAtSameMomentAs(
                                                        elementCheckIn)) &&
                                                checkIn.isBefore(
                                                    elementCheckOut)) ||

                                            // Case 4: New reservation fully contains existing reservation
                                            (elementCheckIn.isAfter(checkIn) &&
                                                elementCheckOut
                                                    .isBefore(checkOut))) &&
                                    // Room overlap condition
                                    element.rooms
                                        .where((e1) => selectedRoomsList
                                            .any((e2) => e2.id == e1.id))
                                        .isNotEmpty &&
                                    reservation?.id != element.id;
                              });

                              if (isContain) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(StringUtils.overlapDateError),
                                    backgroundColor: ColorUtils.blue,
                                    duration: Duration(seconds: 3),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );

                                return;
                              }
                              setState(() => isLoading = true);

                              ReservationModel newReservation =
                                  ReservationModel(
                                      userId: 1,
                                      // Replace with actual user ID logic
                                      checkin: checkinController.text,
                                      checkout: checkoutController.text,
                                      fullname: fullnameController.text,
                                      phone: phoneController.text,
                                      email: emailController.text,
                                      adult: adultCount,
                                      child: childCount,
                                      pet: petCount,
                                      ratePerNight:
                                          double.parse(rateController.text),
                                      subtotal: subtotal,
                                      discount:
                                          double.parse(discountController.text),
                                      tax: tax,
                                      grandTotal: grandTotal,
                                      prepayment: double.parse(
                                          prepaymentController.text),
                                      balance: balance,
                                      roomId: selectedRoom?.id ?? 0,
                                      roomName: selectedRoom?.roomName ?? "",
                                      rooms: selectedRoomsList);

                              if (reservation == null) {
                                context
                                    .read<ReservationBloc>()
                                    .add(AddReservationEvent(newReservation));
                              } else {
                                newReservation.id = reservation?.id ?? 0;
                                context.read<ReservationBloc>().add(
                                    UpdateReservationEvent(newReservation));
                              }
                              Navigator.pop(context, newReservation);
                              if (mounted) {
                                setState(() => isLoading = false);
                              }
                              context
                                  .read<ReservationBloc>()
                                  .add(FetchReservationsEvent());
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
                        : Text(reservation == null
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

  void roomDialog(BuildContext context, VoidCallback onTap) {
    List<RoomModel> selectedDialogRoom =
        List.from(selectedRoomsList); // Create a copy

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, dialogSetState) {
            return AlertDialog(
              insetPadding: EdgeInsets.zero,
              contentPadding: EdgeInsets.zero,
              title: Text(StringUtils.room),
              content: SizedBox(
                width: MediaQuery.of(context).size.width - 60,
                child: BlocBuilder<RoomBloc, RoomState>(
                  builder: (context, state) {
                    if (state is RoomLoaded) {
                      return SingleChildScrollView(
                        physics: ClampingScrollPhysics(),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: state.rooms.map((e) {
                            final isSelected =
                                selectedDialogRoom.any((r) => r.id == e.id);
                            return ListTile(
                              onTap: () {
                                dialogSetState(() {
                                  if (isSelected) {
                                    selectedDialogRoom
                                        .removeWhere((r) => r.id == e.id);
                                  } else {
                                    selectedDialogRoom.add(e);
                                  }
                                });
                              },
                              leading: Checkbox(
                                value: isSelected,
                                onChanged: (bool? value) {
                                  dialogSetState(() {
                                    if (value == true) {
                                      selectedDialogRoom.add(e);
                                    } else {
                                      selectedDialogRoom
                                          .removeWhere((r) => r.id == e.id);
                                    }
                                  });
                                },
                              ),
                              title: Text(e.roomName),
                            );
                          }).toList(),
                        ),
                      );
                    } else if (state is RoomLoading) {
                      return Center(child: CircularProgressIndicator());
                    } else if (state is RoomError) {
                      return Center(child: Text(state.message));
                    } else {
                      return SizedBox.shrink();
                    }
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(StringUtils.cancelCapital),
                ),
                TextButton(
                  onPressed: () {
                    selectedRoomsList = selectedDialogRoom;
                    Navigator.pop(context);
                    roomController.text =
                        selectedRoomsList.map((e) => e.roomName).join(", ");
                    onTap();
                  },
                  child: Text(StringUtils.ok),
                ),
              ],
            );
          },
        );
      },
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
  Widget _buildCounter(String label, int count) {
    return Column(
      children: [
        Text(label,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        Row(
          children: [
            IconButton(
              onPressed: () {
                if (count > 0) count--;
              },
              icon: Icon(Icons.remove_circle_outline, color: ColorUtils.red),
            ),
            Text(count.toString(), style: TextStyle(fontSize: 18)),
            IconButton(
              onPressed: () {
                count++;
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
