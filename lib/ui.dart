import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:unique_data/bloc.dart';
import 'package:unique_data/event.dart';
import 'package:unique_data/state.dart';

class ImeiScreen extends StatelessWidget {
  const ImeiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ImeiBloc(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Device Information"),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () =>
                  context.read<ImeiBloc>().add(GetDeviceInfoEvent()),
            ),
          ],
        ),
        body: BlocBuilder<ImeiBloc, ImeiState>(
          builder: (context, state) {
            if (state is ImeiInitial) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                context.read<ImeiBloc>().add(GetDeviceInfoEvent());
              });
              return const Center(child: CircularProgressIndicator());
            } else if (state is ImeiLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is DeviceInfoLoaded) {
              return _buildDeviceInfo(context, state.deviceInfo);
            } else if (state is ImeiError) {
              return _buildError(context, state.message);
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildError(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(
              message,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                context.read<ImeiBloc>().add(GetDeviceInfoEvent());
              },
              child: const Text("Try Again"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceInfo(BuildContext context, Map<String, String?> info) {
    final isSerialRestricted = info['serial']?.contains("Restricted") ?? false;
    final requiresPhonePermission =
        info['serial']?.contains("READ_PHONE_STATE") ?? false;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          if (isSerialRestricted || requiresPhonePermission)
            Card(
              color: Colors.orange[50],
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.warning_amber, color: Colors.orange),
                        const SizedBox(width: 8),
                        Text(
                          isSerialRestricted
                              ? 'Android Restriction Notice'
                              : 'Permission Required',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isSerialRestricted
                          ? 'Device serial numbers are restricted on Android 10+ for privacy reasons.'
                          : 'Phone permission is required to access the serial number.',
                    ),
                    if (requiresPhonePermission) ...[
                      const SizedBox(height: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () => _requestPhonePermission(context),
                        child: const Text('Grant Permission'),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          Expanded(
            child: ListView(
              children: info.entries.map((entry) {
                final isRestricted =
                    entry.value?.contains("Restricted") ?? false;
                final requiresPermission =
                    entry.value?.contains("Requires") ?? false;
                final isUnavailable = entry.value == "Unavailable";

                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text(
                      _formatKey(entry.key),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: isRestricted ? Colors.orange : null,
                      ),
                    ),
                    subtitle: Text(
                      entry.value ?? "Not available",
                      style: TextStyle(
                        color: isRestricted
                            ? Colors.orange
                            : requiresPermission
                            ? Colors.orange
                            : isUnavailable
                            ? Colors.grey
                            : null,
                      ),
                    ),
                    trailing:
                        !isRestricted && !requiresPermission && !isUnavailable
                        ? IconButton(
                            icon: const Icon(Icons.copy),
                            onPressed: () {
                              Clipboard.setData(
                                ClipboardData(text: entry.value ?? ""),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "${_formatKey(entry.key)} copied",
                                  ),
                                ),
                              );
                            },
                          )
                        : null,
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _requestPhonePermission(BuildContext context) async {
    final status = await Permission.phone.request();
    if (status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Phone permission granted - refreshing...'),
        ),
      );
      context.read<ImeiBloc>().add(GetDeviceInfoEvent());
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Phone permission is still denied')),
      );
    }
  }

  String _formatKey(String key) {
    return key
        .replaceAllMapped(RegExp(r'([A-Z])'), (match) => ' ${match.group(1)}')
        .trim()
        .capitalize();
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}
