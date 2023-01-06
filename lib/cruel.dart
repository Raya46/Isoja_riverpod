import 'package:bloc_test/provider.dart';
import 'package:bloc_test/view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class Cruel extends ConsumerStatefulWidget {
  const Cruel({super.key});

  @override
  ConsumerState<Cruel> createState() => _CruelState();
}

class _CruelState extends ConsumerState<Cruel> {
  @override
  Widget build(BuildContext context) {
    var key = ref.watch(bluetoothConnectionProvider);
    // var jantan = ref.watch(bleProv);

    return Scaffold(
      body: Center(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                      // onPressed: () {
                      //   // await FlutterBluetoothSerial.instance.write('1');
                      //   setState(() {});
                      onPressed: key.sendOnMessageToBluetooth,
                      // },
                      child: Text('on')),
                  ElevatedButton(
                      onPressed:
                          // await FlutterBluetoothSerial.instance.write('0');
                          // setState(() {});
                          key.sendOffMessageToBluetooth,
                      child: Text('off')),
                  ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => View()),
                        );
                      },
                      child: Text('<-')),
                  ElevatedButton(
                      onPressed: () async {
                        await FlutterBluetoothSerial.instance.disconnect();
                      },
                      child: Text('dc'))
                ],
              ),
              Row(
                children: [
                  Slider(
                    value: key.currentValue,
                    min: 0,
                    max: 1.0,
                    divisions: 10,
                    onChanged: (value) {
                      setState(() {
                        key.currentValue = value;
                      });
                      key.sendVolume(value);
                    },
                    
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
