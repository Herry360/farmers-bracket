// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_state.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AuthStateAdapter extends TypeAdapter<AuthState> {
  @override
  final int typeId = 0;

  @override
  AuthState read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AuthState(
      token: fields[0] as String,
      userId: fields[1] as String,
      expiryDate: fields[2] as DateTime?,
      isLoggedIn: fields[3] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, AuthState obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.token)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.expiryDate)
      ..writeByte(3)
      ..write(obj.isLoggedIn);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthStateAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
