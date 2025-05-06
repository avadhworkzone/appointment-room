// Updated ReservationState with a getter to access reservations safely
import 'package:cal_room/model/reservation_model.dart';
import 'package:equatable/equatable.dart';

abstract class ReservationState extends Equatable {
  const ReservationState();

  List<ReservationModel> get reservations => [];

  @override
  List<Object> get props => [];
}

class ReservationInitial extends ReservationState {}

class ReservationLoading extends ReservationState {}

class ReservationLoaded extends ReservationState {
  final List<ReservationModel> _reservations;

  const ReservationLoaded(this._reservations);

  @override
  List<ReservationModel> get reservations => _reservations;

  @override
  List<Object> get props => [_reservations];
}

class ReservationError extends ReservationState {
  final String message;

  const ReservationError(this.message);

  @override
  List<Object> get props => [message];
}
