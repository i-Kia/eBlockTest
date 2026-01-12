import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class SelectedDevice{
  BluetoothDevice? device;
  int? state;

  SelectedDevice(this.device,this.state);
}

class BluetoothSettings extends StatefulWidget{
  const BluetoothSettings({super.key});

  @override
  _BluetoothSettingsState createState() => _BluetoothSettingsState();
}

class _BluetoothSettingsState extends State<BluetoothSettings> {
  bool bluetoothState = false;

  @override
  Widget build(BuildContext context){
    return Scaffold(
        backgroundColor: Color(0xFF092429),
        appBar: AppBar(
          leading: BackButton(
            onPressed: () => Navigator.pop(context),
            color: Colors.white,
          ),
          backgroundColor: Color(0xFF051518),
          title: Text(
            "Bluetooth Devices", 
            style: TextStyle(
              color: Colors.white
            ),
          ),
        ),

        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(8.0),
                child: StreamBuilder<bool>(
                  stream: FlutterBluePlus.isScanning,
                  initialData: false,
                  builder: (c, snapshot) {
                    if (snapshot.data!) {
                      return ElevatedButton.icon(
                        onPressed: () => FlutterBluePlus.stopScan(),
                        label: Text(
                          "Stop Scan",
                          style: TextStyle(
                            color: Colors.black,
                          ),
                        ),
                        icon: const Icon(Icons.stop,color: Colors.red),
                      );
                      
                    } else {
                      return ElevatedButton.icon(
                        onPressed: () => {
                          if (bluetoothState){
                            FlutterBluePlus.startScan(timeout: const Duration(seconds: 4))
                          } else {
                            FlutterBluePlus.turnOn(),
                            FlutterBluePlus.startScan(timeout: const Duration(seconds: 4))
                          }
                        },
                        label: Text(
                          "Scan for Devices",
                          style: TextStyle(
                            color: Colors.black,
                          ),
                        ),
                        icon: Icon(Icons.search,color: Colors.black),
                      );
                    }
                  },
                ),
              ),
              Builder(
                builder: (context) {
                  if (FlutterBluePlus.connectedDevices.isNotEmpty) {
                    return Container(
                      height: 700,
                      child: ListView.builder(itemCount: FlutterBluePlus.connectedDevices.length,itemBuilder: (context,index){
                        return Column(
                          children: [
                            ListTile(
                              title: Text(FlutterBluePlus.connectedDevices[index].platformName,style: TextStyle(color: Colors.white),),
                              leading: Icon(Icons.devices,color: Colors.white),
                              trailing: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFF092429),
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(Radius.circular(8)),
                                          side: BorderSide(color: Colors.green)
                                      )
                                  ),
                                  onPressed: () => setState(() {
                                    FlutterBluePlus.connectedDevices[index].disconnect();
                                    Navigator.pop(context);
                                  }),
                                  child: Text("Disconnect",style: TextStyle(color: Colors.white),)),
                            ),
                            Divider(),
                          ],
                        );
                      }),
                    );
                  } else {
                    return Container();
                  }
                }
              ),
              StreamBuilder<List<BluetoothDevice>>(
                stream: Stream.periodic(const Duration(seconds:10)).asyncMap((_) => FlutterBluePlus.systemDevices([])),
                initialData: const [],
                builder: (c, snapshot){
                  snapshot.data.toString();
                  return Column(
                    children: snapshot.data!.map((d) {
                      return Column(
                        children: [
                          ListTile(
                            title: Text(d.platformName,style: TextStyle(color: Colors.white),),
                            leading: Icon(Icons.devices,color: Colors.white),
                            trailing: StreamBuilder<BluetoothConnectionState>(
                              stream: d.connectionState,
                              initialData: BluetoothConnectionState.disconnected,
                              builder: (c, snapshot) {
                                bool con = snapshot.data == BluetoothConnectionState.connected;
                                return ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                          side: BorderSide(color: con?Colors.green:Colors.red),
                                          borderRadius: BorderRadius.all(Radius.circular(8))
                                      )
                                  ),
                                  child:  Text('Connect',style: TextStyle(color: con?Colors.green:Colors.red),),
                                  onPressed: () {Navigator.of(context).pop(SelectedDevice(d,1));}
                                  ,
                                );
                              },
                            ),
                          ),
                          Divider()
                        ],
                      );
                    }).toList(),
                  );
                },
              ),
              StreamBuilder<List<ScanResult>>(
                stream: FlutterBluePlus.scanResults,
                initialData: const [],
                builder: (c, snapshot){
                  List<ScanResult> scanresults = snapshot.data!;
                  List<ScanResult> templist = [];
                  scanresults.forEach((element) {
                    if(element.device.platformName != "")
                    {
                      templist.add(element);
                    }
                  });

                  return Container(
                    height: 700,
                    child: ListView.builder(itemCount: templist.length,itemBuilder: (context,index){
                      return Column(
                        children: [
                          ListTile(
                            title: Text(templist[index].device.platformName,style: TextStyle(color: Colors.white),),
                            leading: Icon(Icons.devices,color: Colors.white),
                            trailing: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFF092429),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(Radius.circular(8)),
                                        side: BorderSide(color: Colors.orange)
                                    )
                                ),
                                onPressed: () => setState(() {
                                  Navigator.pop(context, SelectedDevice(templist[index].device,0));
                                }),
                                child: Text("Connect",style: TextStyle(color: Colors.white),)),
                          ),
                          Divider(),
                        ],
                      );
                    }),
                  );
                },
              ), 
            ],
          ),
        ),
    );
  }
}