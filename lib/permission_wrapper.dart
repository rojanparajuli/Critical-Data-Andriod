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
    _requestAllPermissions();
  }

  Future<void> _requestAllPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.phone,
      Permission.locationWhenInUse, 
      Permission.locationAlways,
      Permission.bluetooth,
      Permission.storage, 
      Permission.accessMediaLocation,
    ].request();

    statuses.forEach((permission, status) {
      if (status.isDenied) {
        debugPrint("$permission is denied.");
      } else if (status.isPermanentlyDenied) {
        debugPrint("$permission is permanently denied. Please enable it in app settings.");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const ImeiScreen();
  }
}

