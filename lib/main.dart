import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unique_data/bloc.dart';
import 'package:unique_data/permission_wrapper.dart';

void main() {
  runApp(
    MultiBlocProvider(
      providers: [BlocProvider(create: (_) => ImeiBloc())],
      child: const MaterialApp(home: PermissionWrapper()),
    ),
  );
}
