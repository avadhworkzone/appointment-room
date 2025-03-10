import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
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
            pw.Text("Reservation Report", style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            pw.Table.fromTextArray(
              headers: ["Full Name", "Check-in", "Check-out", "Phone", "Email", "Total"],
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

  print("PDF Saved at: ${file.path}");
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
            pw.Text("User Report", style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            pw.Table.fromTextArray(
              headers: ["ID", "Mobile NUmber", "Full Name"],
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

  print("PDF Saved at: ${file.path}");
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
            pw.Text("Room Report", style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            pw.Table.fromTextArray(
              headers: ["Room ID", "Name", "Description", "User ID"],
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

  print("PDF Saved at: ${file.path}");
}
