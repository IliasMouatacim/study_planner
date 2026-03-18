// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pomodoro_session.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PomodoroSessionAdapter extends TypeAdapter<PomodoroSession> {
  @override
  final int typeId = 1;

  @override
  PomodoroSession read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PomodoroSession(
      id: fields[0] as String,
      taskId: fields[1] as String?,
      sessionType: fields[2] as String,
      duration: fields[3] as int,
      startTime: fields[4] as DateTime,
      endTime: fields[5] as DateTime,
      completed: fields[6] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, PomodoroSession obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.taskId)
      ..writeByte(2)
      ..write(obj.sessionType)
      ..writeByte(3)
      ..write(obj.duration)
      ..writeByte(4)
      ..write(obj.startTime)
      ..writeByte(5)
      ..write(obj.endTime)
      ..writeByte(6)
      ..write(obj.completed);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PomodoroSessionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
