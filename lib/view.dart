import 'package:bloc_test/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:bloc_test/cruel.dart';

class View extends ConsumerStatefulWidget {
  const View({super.key});

  @override
  ConsumerState<View> createState() => _ViewState();
}

// var bluetoothcon = ref.watch(bluetoothConnectionProvider);

class _ViewState extends ConsumerState<View> {
  List<DropdownMenuItem<BluetoothDevice>> getDeviceItems() {
    List<DropdownMenuItem<BluetoothDevice>> items = [];
    if (devicesList.isEmpty) {
      items.add(const DropdownMenuItem(
        child: Text('NONE'),
      ));
    } else {
      for (var device in devicesList) {
        items.add(DropdownMenuItem(
          value: device,
          child: Text(device.name!),
        ));
      }
    }
    return items;
  }

  Future<void> enableBluetooth() async {
    bluetoothState = await FlutterBluetoothSerial.instance.state;

    if (bluetoothState == BluetoothState.STATE_OFF) {
      await FlutterBluetoothSerial.instance.requestEnable();
      await getPairedDevices();
      // return true;
    } else {
      await getPairedDevices();
    }
    // return false;
  }

  bool isDisconnecting = false;

  BluetoothConnection? connection;

  bool? get isConnected => connection != null && connection!.isConnected;

  BluetoothDevice? device;

  bool isButtonUnavailable = false;

  int deviceState = 0;

  BluetoothState bluetoothState = BluetoothState.UNKNOWN;

  List<BluetoothDevice> devicesList = [];

  final FlutterBluetoothSerial bluetooth = FlutterBluetoothSerial.instance;

  Future<void> getPairedDevices() async {
    List<BluetoothDevice> devices = [];

    // To get the list of paired devices
    try {
      devices = await bluetooth.getBondedDevices();
    } on PlatformException {
      debugPrint("Error");
    }

    // It is an error to call [setState] unless [mounted] is true.
    if (!mounted) {
      return;
    }

    // Store the [devices] list in the [_devicesList] for accessing
    // the list outside this class
    if (mounted)
      setState(() {
        devicesList = devices;
      });
  }

  @override
  void initState() {
    FlutterBluetoothSerial.instance.state.then((state) {
      setState(() {
        bluetoothState = state;
      });
    });

    deviceState = 0;

    enableBluetooth();

    FlutterBluetoothSerial.instance
        .onStateChanged()
        .listen((BluetoothState state) {
      if (mounted)
        setState(() {
          bluetoothState = state;
          if (bluetoothState == BluetoothState.STATE_OFF) {
            isButtonUnavailable = true;
          }
          getPairedDevices();
        });
    });
    super.initState();
  }

  @override
  void dispose() {
    if (isConnected!) {
      isDisconnecting = true;
      connection?.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final key = ref.watch(bluetoothConnectionProvider);
    return Scaffold(
      body: Center(
        child: Container(
          child: Row(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    child: Text(key.buttonText),
                    onPressed: () async {
                      if (key.isConnected) {
                        // Disconnect from Bluetooth device
                        await FlutterBluetoothSerial.instance.disconnect();
                        key.isConnected = false;
                        setState(() {});
                        key.buttonText = 'Connect';
                      } else {
                        // Connect to Bluetooth device
                        List<BluetoothDevice> devices =
                            await FlutterBluetoothSerial.instance
                                .getBondedDevices();
                        BluetoothDevice device =
                            devices[0]; // Replace with your desired device
                        await FlutterBluetoothSerial.instance.connect(device);
                        setState(() {});
                        key.isConnected = true;
                        key.buttonText = 'Disconnect';
                      }
                    },
                  ),
                  ElevatedButton(
                      onPressed: () async {
                        // setState(() {});
                        await FlutterBluetoothSerial.instance.write('1');
                      },
                      child: Text('on')),
                  ElevatedButton(
                      onPressed: () async {
                        // setState(() {});
                        await FlutterBluetoothSerial.instance.write('0');
                      },
                      child: Text('off')),
                  ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Cruel()),
                        );
                      },
                      child: Text('->'))
                ],
              ),
              Row(children: [
                ElevatedButton(
                    onPressed: () async {
                      // setState(() {});
                      await FlutterBluetoothSerial.instance.disconnect();
                    },
                    child: Text('disconnect')),
                DropdownButton(
                  hint: Text('Select A Device'),
                  items: getDeviceItems(),
                  onChanged: (value) => setState(() => device = value!),
                  value: devicesList.isNotEmpty ? device : null,
                )
              ])
            ],
          ),
        ),
      ),
    );
  }
}
