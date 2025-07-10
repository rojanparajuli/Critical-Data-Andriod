import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:unique_data/bloc.dart';
import 'package:unique_data/event.dart';
import 'package:unique_data/state.dart';

class ImeiScreen extends StatelessWidget {
  const ImeiScreen({super.key});

  Future<void> _requestPermissions() async {
    await Permission.phone.request();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("IMEI Fetcher")),
      body: BlocBuilder<ImeiBloc, ImeiState>(
        builder: (context, state) {
          if (state is ImeiInitial) {
            return Center(
              child: ElevatedButton(
                onPressed: () async {
                  await _requestPermissions();
                  context.read<ImeiBloc>().add(GetImeiEvent());
                },
                child: const Text("Get IMEI"),
              ),
            );
          } else if (state is ImeiLoading) {
            return const Center(child: CircularProgressIndicator());
            } else if (state is ImeiLoaded) {
            return Center(
              child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("IMEI: ${state.imei}"),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                icon: const Icon(Icons.copy),
                label: const Text("Copy to Clipboard"),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: state.imei));
                  ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("IMEI copied to clipboard")),
                  );
                },
                ),
              ],
              ),
            );
            } else if (state is ImeiError) {
            return Center(
              child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Error: ${state.message}"),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                icon: const Icon(Icons.copy),
                label: const Text("Copy Error"),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: state.message));
                  ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Error message copied to clipboard")),
                  );
                },
                ),
              ],
              ),
            );
            }
          return const SizedBox();
        },
      ),
    );
  }
}
