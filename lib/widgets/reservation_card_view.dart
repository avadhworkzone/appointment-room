// import 'package:cal_room/controller/reservation_controller.dart';
// import 'package:cal_room/model/reservation_model.dart';
// import 'package:cal_room/widgets/add_edit_reservation_bottom_sheet.dart';
// import 'package:flutter/material.dart';

// ignore_for_file: use_build_context_synchronously

//
// class ReservationCardView extends StatelessWidget {
//   const ReservationCardView(
//       {super.key, required this.reservation, this.isFromToday = false});
//
//   final ReservationModel reservation;
//   final bool isFromToday;
//
//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       elevation: 4,
//       margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             /// 🔹 **Guest Name & Actions**
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   reservation.fullname,
//                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                 ),
//                 Row(
//                   children: [
//                     IconButton(
//                       icon: Icon(Icons.edit, color: ColorUtils.blue),
//                       onPressed: () => addEditReservationBottomSheet(
//                           reservation: reservation),
//                     ),
//                     IconButton(
//                         icon: Icon(Icons.delete, color: ColorUtils.red),
//                         onPressed: () async {
//                           await _deleteReservation(reservation.id!);
//                           await ReservationController.to.fetchReservations();
//                         }),
//                   ],
//                 ),
//               ],
//             ),
//
//             SizedBox(height: 8),
//
//             /// 🔹 **Check-in & Check-out Dates**
//             _buildInfoRow(
//                 Icons.calendar_today, "Check-in: ${reservation.checkin}"),
//             _buildInfoRow(Icons.calendar_today_outlined,
//                 "Check-out: ${reservation.checkout}"),
//
//             SizedBox(height: 8),
//
//             /// 🔹 **Guest Contact Details**
//             _buildInfoRow(Icons.phone, "Phone: ${reservation.phone}"),
//             _buildInfoRow(Icons.email, "Email: ${reservation.email}"),
//
//             SizedBox(height: 8),
//
//             /// 🔹 **Guest Count (Adults, Children, Pets)**
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 _buildGuestCount(Icons.person, "Adults", reservation.adult),
//                 _buildGuestCount(
//                     Icons.child_care, "Children", reservation.child),
//                 _buildGuestCount(Icons.pets, "Pets", reservation.pet),
//               ],
//             ),
//
//             if (!isFromToday) Divider(thickness: 1, height: 16),
//
//             /// 🔹 **Pricing Details**
//             if (!isFromToday)
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   _buildPriceRow("Room", 0, strValue: reservation.roomName),
//                   _buildPriceRow("Rate per Night", reservation.ratePerNight),
//                   _buildPriceRow("Subtotal", reservation.subtotal),
//                   _buildPriceRow("Tax (5%)", reservation.tax),
//                   _buildPriceRow("Discount", reservation.discount),
//                   _buildPriceRow("Grand Total", reservation.grandTotal,
//                       isBold: true),
//                   _buildPriceRow("Prepayment", reservation.prepayment),
//                   _buildPriceRow("Balance", reservation.balance,
//                       isBold: true, color: ColorUtils.red),
//                 ],
//               ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   /// ✅ **Builds Row for Info (Check-in, Contact, Email)**
//   Widget _buildInfoRow(IconData icon, String text) {
//     return Row(
//       children: [
//         Icon(icon, size: 20, color: ColorUtils.grey[700]),
//         SizedBox(width: 8),
//         Expanded(
//           child: Text(
//             text,
//             style: TextStyle(fontSize: 16),
//             overflow: TextOverflow.ellipsis,
//           ),
//         ),
//       ],
//     );
//   }
//
//   /// ✅ **Builds Guest Count Row (Adults, Children, Pets)**
//   Widget _buildGuestCount(IconData icon, String label, int count) {
//     return Column(
//       children: [
//         Icon(icon, size: 24, color: ColorUtils.blue),
//         SizedBox(height: 4),
//         Text("$count",
//             style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//         Text(label, style: TextStyle(fontSize: 14, color: ColorUtils.grey)),
//       ],
//     );
//   }
//
//   /// ✅ **Builds Price Row (Rate, Subtotal, Tax, Grand Total, etc.)**
//   Widget _buildPriceRow(String label, double value,
//       {bool isBold = false, Color color = ColorUtils.black, String? strValue}) {
//     return Padding(
//       padding: EdgeInsets.symmetric(vertical: 4),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             label,
//             style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: isBold ? FontWeight.bold : FontWeight.normal),
//           ),
//           Text(
//             strValue ?? "\$${value.toStringAsFixed(2)}",
//             style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
//                 color: color),
//           ),
//         ],
//       ),
//     );
//   }
//
//   /// ✅ **Delete Reservation with Confirmation**
//   Future<void> _deleteReservation(int reservationId) async {
//     Get.defaultDialog(
//       title: "Delete Reservation",
//       middleText: "Are you sure you want to delete this reservation?",
//       textConfirm: "Yes",
//       textCancel: "No",
//       confirmTextColor: ColorUtils.white,
//       onConfirm: () async {
//         await ReservationController.to.deleteReservation(reservationId);
//         Get.back();
//         await ReservationController.to.fetchReservations();
//       },
//     );
//   }
// }
// import 'package:cal_room/controller/reservation_controller.dart';
import 'package:cal_room/model/reservation_model.dart';
import 'package:cal_room/screens/reservation_detail_screen.dart';
import 'package:cal_room/utils/color_utils.dart';
import 'package:cal_room/utils/string_utils.dart';
import 'package:cal_room/widgets/add_edit_reservation_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/reservation/reservation__bloc.dart';
import '../blocs/reservation/reservation__event.dart';

class ReservationCardView extends StatelessWidget {
  final bool canEditDelete; // ✅ NEW

  const ReservationCardView({
    super.key,
    required this.reservation,
    this.canEditDelete = true, // ✅ default true

    this.isFromToday = false,
  });

  final ReservationModel reservation;
  final bool isFromToday;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ReservationDetailScreen(reservation: reservation),
          ),
        );
      },
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 3,
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// 🔹 Header with Name and Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      reservation.fullname,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  canEditDelete == false
                      ? SizedBox()
                      : Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit, color: ColorUtils.blue),
                              onPressed: () => addEditReservationBottomSheet(
                                  context,
                                  reservation: reservation),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: ColorUtils.red),
                              onPressed: () async {
                                await _deleteReservation(
                                    context, reservation.id!);
                                context
                                    .read<ReservationBloc>()
                                    .add(FetchReservationsEvent());
                              },
                            ),
                          ],
                        ),
                ],
              ),
              SizedBox(height: 6),

              /// 🔹 Check-in / Check-out and Contact Info
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoRow(Icons.calendar_today,
                            "Check-in: ${reservation.checkin}"),
                        _buildInfoRow(Icons.calendar_today_outlined,
                            "Check-out: ${reservation.checkout}"),
                      ],
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoRow(Icons.phone, reservation.phone),
                        _buildInfoRow(Icons.email, reservation.email),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),

              /// 🔹 Guest Count
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildGuestCount(
                      Icons.person, StringUtils.adults, reservation.adult),
                  _buildGuestCount(Icons.child_care, StringUtils.children,
                      reservation.child),
                  _buildGuestCount(
                      Icons.pets, StringUtils.pets, reservation.pet),
                ],
              ),

              /// 🔹 Divider & Pricing
              if (!isFromToday) ...[
                Divider(thickness: 1, height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildPriceRow(StringUtils.room, 0,
                          strValue: reservation.rooms
                              .map((e) => e.roomName)
                              .toList()
                              .join(',')),
                      _buildPriceRow(
                          StringUtils.rateNight, reservation.ratePerNight),
                      _buildPriceRow(
                          StringUtils.subtotal, reservation.subtotal),
                      _buildPriceRow(StringUtils.tax, reservation.tax),
                      _buildPriceRow(
                          StringUtils.discount, reservation.discount),
                      _buildPriceRow(
                          StringUtils.grandTotal, reservation.grandTotal,
                          isBold: true),
                      _buildPriceRow(
                          StringUtils.prepayment, reservation.prepayment),
                      _buildPriceRow(StringUtils.balance, reservation.balance,
                          isBold: true, color: ColorUtils.red),
                    ],
                  ),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: ColorUtils.grey[600]),
          SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 14.5),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuestCount(IconData icon, String label, int count) {
    return Column(
      children: [
        Icon(icon, size: 20, color: ColorUtils.indigo),
        SizedBox(height: 4),
        Text(
          "$count",
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        Text(label, style: TextStyle(fontSize: 13, color: ColorUtils.grey)),
      ],
    );
  }

  Widget _buildPriceRow(String label, double value,
      {bool isBold = false, Color color = ColorUtils.black, String? strValue}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text(
            strValue ?? "\$${value.toStringAsFixed(2)}",
            style: TextStyle(
              fontSize: 14.5,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteReservation(
      BuildContext context, int reservationId) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(StringUtils.deleteReservationTitle),
        content: Text(StringUtils.deleteReservationMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // Dismiss dialog
            child: Text(StringUtils.no),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Dismiss dialog first
              context
                  .read<ReservationBloc>()
                  .add(DeleteReservationEvent(reservationId));
              context.read<ReservationBloc>().add(FetchReservationsEvent());
            },
            style: TextButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
            child: Text(
              StringUtils.yes,
              style: TextStyle(color: ColorUtils.white),
            ),
          ),
        ],
      ),
    );
  }

// Future<void> _deleteReservation(
  //     BuildContext context, int reservationId) async {
  //   Get.defaultDialog(
  //     title: StringUtils.deleteReservationTitle,
  //     middleText: StringUtils.deleteReservationMessage,
  //     textConfirm: StringUtils.yes,
  //     textCancel: StringUtils.no,
  //     confirmTextColor: ColorUtils.white,
  //     onConfirm: () async {
  //       context
  //           .read<ReservationBloc>()
  //           .add(DeleteReservationEvent(reservationId));
  //       Navigator.pop(context);
  //       context.read<ReservationBloc>().add(FetchReservationsEvent());
  //     },
  //   );
  // }
}
