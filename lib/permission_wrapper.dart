import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'ui.dart'; 

class PermissionWrapper extends StatefulWidget {
  const PermissionWrapper({super.key});

  @override
  State<PermissionWrapper> createState() => _PermissionWrapperState();
}

class _PermissionWrapperState extends State<PermissionWrapper> {
  @override
  void initState() {
    super.initState();
    _requestPhonePermission();
  }

  Future<void> _requestPhonePermission() async {
    final status = await Permission.phone.status;
    if (!status.isGranted) {
      await Permission.phone.request();
    }
  }

  @override
  Widget build(BuildContext context) {
    return const ImeiScreen();
  }
}
