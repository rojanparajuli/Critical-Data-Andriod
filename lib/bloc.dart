import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:unique_data/event.dart';
import 'package:unique_data/state.dart';

class ImeiBloc extends Bloc<ImeiEvent, ImeiState> {
  static const platform = MethodChannel('com.example.device/info');

  ImeiBloc() : super(ImeiInitial()) {
    on<GetImeiEvent>(_onGetImei);
    on<GetDeviceInfoEvent>(_onGetDeviceInfo);
  }

  Future<void> _onGetImei(GetImeiEvent event, Emitter<ImeiState> emit) async {
    emit(ImeiLoading());
    try {
      final String? imei = await platform.invokeMethod<String>('getImei');
      if (imei != null && imei.isNotEmpty) {
        emit(ImeiLoaded(imei));
      } else {
        emit( ImeiError("Empty IMEI received"));
      }
    } on PlatformException catch (e) {
      emit(ImeiError("Failed to get IMEI: ${e.message ?? 'Unknown error'}"));
    } catch (e) {
      emit(ImeiError("Unexpected error: ${e.toString()}"));
    }
  }

  Future<void> _onGetDeviceInfo(
    GetDeviceInfoEvent event,
    Emitter<ImeiState> emit,
  ) async {
    emit(ImeiLoading());
    try {
      final Map<dynamic, dynamic>? deviceInfo = 
        await platform.invokeMethod<Map<dynamic, dynamic>>('getDeviceInfo');
      
      if (deviceInfo != null) {
        emit(DeviceInfoLoaded(Map<String, String?>.from(deviceInfo)));
      } else {
        emit( ImeiError("No device info received"));
      }
    } on PlatformException catch (e) {
      emit(ImeiError("Failed to get device info: ${e.message ?? 'Unknown error'}"));
    } catch (e) {
      emit(ImeiError("Unexpected error: ${e.toString()}"));
    }
  }
}