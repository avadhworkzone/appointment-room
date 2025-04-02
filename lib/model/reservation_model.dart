import 'dart:convert';

import 'package:cal_room/model/room_model.dart';

class ReservationModel {
  int? id;
  int userId;
  String checkin;
  String checkout;
  String fullname;
  String phone;
  String email;
  int adult;
  int child;
  int pet;
  double ratePerNight;
  double subtotal;
  double discount;
  double tax;
  double grandTotal;
  double prepayment;
  double balance;
  int roomId;
  String roomName;
  List<RoomModel> rooms;

  ReservationModel({
    this.id,
    required this.userId,
    required this.checkin,
    required this.checkout,
    required this.fullname,
    required this.phone,
    required this.email,
    required this.adult,
    required this.child,
    required this.pet,
    required this.ratePerNight,
    required this.subtotal,
    required this.discount,
    required this.tax,
    required this.grandTotal,
    required this.prepayment,
    required this.balance,
    required this.roomId,
    required this.roomName,
    required this.rooms,
  });

  // Convert a ReservationModel to a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'checkin': checkin,
      'checkout': checkout,
      'fullname': fullname,
      'phone': phone,
      'email': email,
      'adult': adult,
      'child': child,
      'pet': pet,
      'ratepernight': ratePerNight,
      'subtotal': subtotal,
      'discount': discount,
      'tax': tax,
      'grandtotal': grandTotal,
      'prepayment': prepayment,
      'balance': balance,
      'roomId': roomId,
      'roomName': roomName,
      'rooms': jsonEncode(rooms
          .map(
            (e) => e.toMap(),
          )
          .toList()),
    };
  }

  // Convert a Map to a ReservationModel
  factory ReservationModel.fromMap(Map<String, dynamic> map) {
    return ReservationModel(
      id: map['id'],
      userId: map['user_id'],
      checkin: map['checkin'],
      checkout: map['checkout'],
      fullname: map['fullname'],
      phone: map['phone'],
      email: map['email'],
      adult: map['adult'],
      child: map['child'],
      pet: map['pet'],
      ratePerNight: map['ratepernight'],
      subtotal: map['subtotal'],
      discount: map['discount'],
      tax: map['tax'],
      grandTotal: map['grandtotal'],
      prepayment: map['prepayment'],
      balance: map['balance'],
      roomId: map['roomId'] ?? 0,
      roomName: map['roomName'] ?? "",
      rooms: map['rooms'] != null && map['rooms'] != "" && map['rooms'] != "null"
          ? (jsonDecode(map['rooms']) as List).cast<Map<String,dynamic>>()
              .map(
                (e) => RoomModel.fromMap(e),
              )
              .toList()
          : [],
    );
  }
}
