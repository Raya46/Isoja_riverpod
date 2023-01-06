import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final bluetoothConnectionProvider =
    Provider<BluetoothConnectionState>((ref) => BluetoothConnectionState());

// final bleProv = Provider<BleApp>((ref) => BleApp());

class BluetoothConnectionState extends ChangeNotifier {
  // List<DropdownMenuItem<BluetoothDevice>> getDeviceItems() {
  //   List<DropdownMenuItem<BluetoothDevice>> items = [];
  //   if (devicesList.isEmpty) {
  //     items.add(const DropdownMenuItem(
  //       child: Text('NONE'),
  //     ));
  //   } else {
  //     for (var device in devicesList) {
  //       items.add(DropdownMenuItem(
  //         value: device,
  //         child: Text(device.name!),
  //       ));
  //     }
  //   }
  //   return items;
  // }

  sendOnMessageToBluetooth() async {
    await FlutterBluetoothSerial.instance.write('1');
    debugPrint('1');
  }

  sendOffMessageToBluetooth() async {
    await FlutterBluetoothSerial.instance.write('0');
    debugPrint('0');
  }

  sendVolume(num value) async {
    await FlutterBluetoothSerial.instance.write('$value');
  }

  List<BluetoothDevice> devicesList = [];
  BluetoothConnection? connection;
  BluetoothDevice? device;

  bool get isConnected => connection != null && connection!.isConnected;
  set isConnected(bool value) {
    _isConnected = value;
    notifyListeners();
  }

  bool _isConnected = false;
  double currentValue = 0.0;

  String get buttonText => _buttonText;
  set buttonText(String value) {
    _buttonText = value;
    notifyListeners();
  }

  String _buttonText = 'Connect';
}






// important

