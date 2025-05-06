import 'dart:async';
import 'dart:developer';
import 'package:cal_room/blocs/reservation/reservation__event.dart';
import 'package:cal_room/blocs/reservation/reservation__state.dart';
import 'package:cal_room/model/reservation_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../database/db_helper.dart';

class ReservationBloc extends Bloc<ReservationEvent, ReservationState> {
  ReservationBloc() : super(ReservationInitial()) {
    on<FetchReservationsEvent>(_onFetchReservations);
    on<AddReservationEvent>(_onAddReservation);
    on<UpdateReservationEvent>(_onUpdateReservation);
    on<DeleteReservationEvent>(_onDeleteReservation);
  }

  Future<void> _onFetchReservations(
      FetchReservationsEvent event, Emitter<ReservationState> emit) async {
    emit(ReservationLoading());
    try {
      final data = await DBHelper.getReservations();
      final reservations =
          data.map((e) => ReservationModel.fromMap(e)).toList();
      emit(ReservationLoaded(reservations));
    } catch (e) {
      log("Error fetching reservations: $e");
      emit(ReservationError("Failed to fetch reservations."));
    }
  }

  Future<void> _onAddReservation(
      AddReservationEvent event, Emitter<ReservationState> emit) async {
    try {
      await DBHelper.database.then((db) async {
        await db.transaction((txn) async {
          await txn.insert('Reservations', event.reservation.toMap());
        });
      });
      add(FetchReservationsEvent());
    } catch (e) {
      log("Error adding reservation: $e");
      emit(ReservationError("Failed to add reservation."));
    }
  }

  Future<void> _onUpdateReservation(
      UpdateReservationEvent event, Emitter<ReservationState> emit) async {
    try {
      await DBHelper.database.then((db) async {
        await db.transaction((txn) async {
          await txn.update('Reservations', event.reservation.toMap(),
              where: 'id = ?', whereArgs: [event.reservation.id]);
        });
      });
      add(FetchReservationsEvent());
    } catch (e) {
      log("Error updating reservation: $e");
      emit(ReservationError("Failed to update reservation."));
    }
  }

  Future<void> _onDeleteReservation(
      DeleteReservationEvent event, Emitter<ReservationState> emit) async {
    try {
      await DBHelper.database.then((db) async {
        await db.transaction((txn) async {
          await txn
              .delete('Reservations', where: 'id = ?', whereArgs: [event.id]);
        });
      });
      add(FetchReservationsEvent());
    } catch (e) {
      log("Error deleting reservation: $e");
      emit(ReservationError("Failed to delete reservation."));
    }
  }
}
