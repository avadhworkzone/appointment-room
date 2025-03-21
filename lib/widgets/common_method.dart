import 'package:flutter/material.dart';

import '../model/reservation_model.dart';

class CommonMethod{
  MaterialColor reservationColor(ReservationModel reservation) => reservation.balance==0?Colors.yellow:reservation.prepayment>0?Colors.green: Colors.orange;

}