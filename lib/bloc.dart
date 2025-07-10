import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:unique_data/event.dart';
import 'package:unique_data/state.dart';

class ImeiBloc extends Bloc<ImeiEvent, ImeiState> {
  static const platform = MethodChannel('com.example.imei/imei');

  ImeiBloc() : super(ImeiInitial()) {
    on<GetImeiEvent>((event, emit) async {
      emit(ImeiLoading());
      try {
        final String imei = await platform.invokeMethod('getImei');
        emit(ImeiLoaded(imei));
      } on PlatformException catch (e) {
        emit(ImeiError("Failed to get IMEI: ${e.message}"));
      }
    });
  }
}
