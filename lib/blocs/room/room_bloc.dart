import 'package:cal_room/database/db_helper.dart';
import 'package:cal_room/model/room_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'room_event.dart';
import 'room_state.dart';

class RoomBloc extends Bloc<RoomEvent, RoomState> {
  RoomBloc() : super(RoomInitial()) {
    on<FetchRooms>(_onFetchRooms);
    on<AddRoom>(_onAddRoom);
    on<UpdateRoom>(_onUpdateRoom);
    on<DeleteRoom>(_onDeleteRoom);
  }

  Future<void> _onFetchRooms(FetchRooms event, Emitter<RoomState> emit) async {
    emit(RoomLoading());
    try {
      final rooms = await DBHelper.getRooms();
      final roomList = rooms.map((e) => RoomModel.fromMap(e)).toList();
      emit(RoomLoaded(roomList));
    } catch (e) {
      emit(RoomError('Failed to load rooms: ${e.toString()}'));
    }
  }

  Future<void> _onAddRoom(AddRoom event, Emitter<RoomState> emit) async {
    emit(RoomLoading());
    try {
      await DBHelper.database.then((db) async {
        await db.transaction((txn) async {
          await txn.insert('Rooms', event.room.toMap());
        });
      });
      add(FetchRooms());
    } catch (e) {
      emit(RoomError('Failed to add room: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateRoom(UpdateRoom event, Emitter<RoomState> emit) async {
    emit(RoomLoading());
    try {
      await DBHelper.database.then((db) async {
        await db.transaction((txn) async {
          await txn.update('Rooms', event.room.toMap(),
              where: 'id = ?', whereArgs: [event.room.id]);
        });
      });
      add(FetchRooms());
    } catch (e) {
      emit(RoomError('Failed to update room: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteRoom(DeleteRoom event, Emitter<RoomState> emit) async {
    emit(RoomLoading());
    try {
      await DBHelper.database.then((db) async {
        await db.transaction((txn) async {
          await txn.delete('Rooms', where: 'id = ?', whereArgs: [event.id]);
        });
      });
      add(FetchRooms());
    } catch (e) {
      emit(RoomError('Failed to delete room: ${e.toString()}'));
    }
  }
}
