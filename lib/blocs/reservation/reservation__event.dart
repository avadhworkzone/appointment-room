import 'package:cal_room/model/reservation_model.dart';

abstract class ReservationEvent {}

class FetchReservationsEvent extends ReservationEvent {}

class AddReservationEvent extends ReservationEvent {
  final ReservationModel reservation;

  AddReservationEvent(this.reservation);
}

class UpdateReservationEvent extends ReservationEvent {
  final ReservationModel reservation;

  UpdateReservationEvent(this.reservation);
}

class DeleteReservationEvent extends ReservationEvent {
  final int id;

  DeleteReservationEvent(this.id);
}
