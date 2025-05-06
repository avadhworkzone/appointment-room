import 'package:cal_room/model/room_model.dart';
import 'package:equatable/equatable.dart';

abstract class RoomEvent extends Equatable {
  const RoomEvent();

  @override
  List<Object> get props => [];
}

class FetchRooms extends RoomEvent {}

class AddRoom extends RoomEvent {
  final RoomModel room;

  const AddRoom(this.room);

  @override
  List<Object> get props => [room];
}

class UpdateRoom extends RoomEvent {
  final RoomModel room;

  const UpdateRoom(this.room);

  @override
  List<Object> get props => [room];
}

class DeleteRoom extends RoomEvent {
  final int id;

  const DeleteRoom(this.id);

  @override
  List<Object> get props => [id];
}
