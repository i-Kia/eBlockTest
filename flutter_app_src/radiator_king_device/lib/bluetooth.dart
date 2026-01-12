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
        backgroundColor: Color(0xFF051518),
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
                padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                child: StreamBuilder<bool>(
                  stream: FlutterBluePlus.isScanning,
                  initialData: false,
                  builder: (c, snapshot) {
                    if (snapshot.data!) {
                      return ElevatedButton.icon(
                        onPressed: () => FlutterBluePlus.stopScan(),
                        icon: const Icon(Icons.stop,color: Colors.red),
                        label: FittedBox(
                          fit: BoxFit.fitHeight,
                          child: Text(
                            "Stop Scan",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                            ),
                          ),
                        ),
                        style: ButtonStyle(
                          backgroundColor: WidgetStatePropertyAll<Color>(Colors.grey.shade100),
                          foregroundColor: WidgetStatePropertyAll<Color>(Colors.black),
                          shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0)
                            ),
                          ),
                        )
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
                        icon: Icon(Icons.search,color: Colors.black),
                        label: FittedBox(
                          fit: BoxFit.fitHeight,
                          child: Text(
                            "Scan for Devices",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                            ),
                          ),
                        ),
                        style: ButtonStyle(
                          backgroundColor: WidgetStatePropertyAll<Color>(Colors.grey.shade100),
                          foregroundColor: WidgetStatePropertyAll<Color>(Colors.black),
                          shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0)
                            ),
                          ),
                        )
                      );
                    }
                  },
                ),
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