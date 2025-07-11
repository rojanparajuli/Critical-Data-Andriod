abstract class ImeiState {}

class ImeiInitial extends ImeiState {}

class ImeiLoading extends ImeiState {}

class ImeiLoaded extends ImeiState {
  final String imei;
  ImeiLoaded(this.imei);
}

class ImeiError extends ImeiState {
  final String message;
  ImeiError(this.message);
}

class DeviceInfoLoaded extends ImeiState {
  final Map<String, String?> deviceInfo;
  DeviceInfoLoaded(this.deviceInfo);
}
