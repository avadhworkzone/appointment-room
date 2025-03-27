// ignore_for_file: deprecated_member_use

import 'dart:developer';
import 'dart:io';
import 'package:cal_room/utils/string_utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
// import 'package:pdf/pdf.dart';
import '../model/user_model.dart';
import '../model/room_model.dart';
import '../model/reservation_model.dart';

// Export Reservations as PDF
Future<void> exportReservationsAsPDF(List<ReservationModel> reservations) async {
  final pdf = pw.Document();

  pdf.addPage(
    pw.Page(
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(StringUtils.reservationReportTitle, style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            pw.Table.fromTextArray(
              headers: [StringUtils.fullName,
                StringUtils.checkIn,
                StringUtils.checkOut,
                StringUtils.phoneLabel,
                StringUtils.emailLabel,
                StringUtils.total],
              data: reservations.map((res) => [
                res.fullname,
                res.checkin,
                res.checkout,
                res.phone,
                res.email,
                "\$${res.grandTotal}"
              ]).toList(),
              border: pw.TableBorder.all(),
              cellAlignment: pw.Alignment.centerLeft,
            ),
          ],
        );
      },
    ),
  );

  final directory = await getApplicationDocumentsDirectory();
  final file = File("${directory.path}/reservations_report.pdf");
  await file.writeAsBytes(await pdf.save());

  log("PDF Saved at: ${file.path}");
}

// Export Users as PDF
Future<void> exportUsersAsPDF(List<UserModel> users) async {
  final pdf = pw.Document();

  pdf.addPage(
    pw.Page(
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(StringUtils.userReportTitle, style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            pw.Table.fromTextArray(
              headers: [StringUtils.id, StringUtils.mobileNumber, StringUtils.fullName],
              data: users.map((user) => [user.id, user.mobileNumber, user.fullname]).toList(),
              border: pw.TableBorder.all(),
              cellAlignment: pw.Alignment.centerLeft,
            ),
          ],
        );
      },
    ),
  );

  final directory = await getApplicationDocumentsDirectory();
  final file = File("${directory.path}/users_report.pdf");
  await file.writeAsBytes(await pdf.save());

  log("PDF Saved at: ${file.path}");
}

// Export Rooms as PDF
Future<void> exportRoomsAsPDF(List<RoomModel> rooms) async {
  final pdf = pw.Document();

  pdf.addPage(
    pw.Page(
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(StringUtils.roomReportTitle, style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            pw.Table.fromTextArray(
              headers: [StringUtils.roomId,
                StringUtils.roomName,
                StringUtils.description,
                StringUtils.userId],
              data: rooms.map((room) => [room.id, room.roomName, room.roomDesc, room.userId]).toList(),
              border: pw.TableBorder.all(),
              cellAlignment: pw.Alignment.centerLeft,
            ),
          ],
        );
      },
    ),
  );

  final directory = await getApplicationDocumentsDirectory();
  final file = File("${directory.path}/rooms_report.pdf");
  await file.writeAsBytes(await pdf.save());

  log("PDF Saved at: ${file.path}");
}
