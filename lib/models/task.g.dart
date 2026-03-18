// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TaskAdapter extends TypeAdapter<Task> {
  @override
  final int typeId = 0;

  @override
  Task read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Task(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String?,
      priority: fields[3] as int,
      dueDate: fields[4] as DateTime?,
      status: fields[5] as String,
      createdAt: fields[6] as DateTime,
      completedAt: fields[7] as DateTime?,
      totalTimeSpent: fields[8] as int,
      category: (fields[9] as String?) ?? 'General',
      subtasks: (fields[10] as List?)?.cast<String>() ?? [],
      subtasksDone: (fields[11] as List?)?.cast<bool>() ?? [],
    );
  }

  @override
  void write(BinaryWriter writer, Task obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.priority)
      ..writeByte(4)
      ..write(obj.dueDate)
      ..writeByte(5)
      ..write(obj.status)
      ..writeByte(6)
      ..write(obj.createdAt)
      ..writeByte(7)
      ..write(obj.completedAt)
      ..writeByte(8)
      ..write(obj.totalTimeSpent)
      ..writeByte(9)
      ..write(obj.category)
      ..writeByte(10)
      ..write(obj.subtasks)
      ..writeByte(11)
      ..write(obj.subtasksDone);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
