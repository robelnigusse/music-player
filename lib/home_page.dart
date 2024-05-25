import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool _storagePermissionGranted = false;

  @override
  void initState() {
    super.initState();
    _requestPermission();
  }

  Future<void> _requestPermission() async {
    AndroidDeviceInfo build = await DeviceInfoPlugin().androidInfo;
    Permission permission = build.version.sdkInt >= 30
        ? Permission.manageExternalStorage
        : Permission.storage;

    var status = await permission.status;

    if (!status.isGranted) {
      status = await permission.request();
    }

    if (status.isGranted) {
      setState(() {
        _storagePermissionGranted = true;
      });
    }
  }






  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        title: const Text("M-Player"),
      ),
      body: Center(
        child: _storagePermissionGranted
            ? const Text("Permission Granted")
            : const Text("Permission Not Granted"),
      ),
    );
  }
}
