import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:window_manager/window_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:super_drag_and_drop/super_drag_and_drop.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'dilih',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      debugShowCheckedModeBanner: false,
      home: DnDHomePage(),
    );
  }
}

class DnDHomePage extends StatefulWidget {
  const DnDHomePage({super.key});

  @override
  State<DnDHomePage> createState() => _DnDHomePageState();
}

class _DnDHomePageState extends State<DnDHomePage> {
  bool dropAccepted = true;
  List<String> filePaths = [];
  late var draggableChild = notConnected;
  late bool droppedOnApp;
  List<DropOperation> dropOperationChoices = [
    DropOperation.move,
    DropOperation.copy,
    DropOperation.link,
  ];

  late Widget notConnected = GestureDetector(
    onDoubleTap: () async {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
      );
      if (result != null) {
        for (String? path in result.paths.toList()) {
          if (path != null) {
            setState(() {
              filePaths.add(path);
              draggableChild = draggableFiles;
            });
          }
        }
      } else {}
    },
    child: Stack(
      fit: StackFit.expand,
      children: [
        Container(
          color: const Color(0xFFE56711),
          child: Padding(
            padding: EdgeInsetsGeometry.all(30),
            child: FittedBox(
              fit: BoxFit.fill,
              child: const Icon(
                Icons.link_off,
                color: Color.fromARGB(130, 0, 0, 0),
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsetsGeometry.only(bottom: 3),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Drag And Drop Files\nDouble Click To Select Files',
                maxLines: 3,
                textAlign: TextAlign.center,
                style: TextStyle(
                  decoration: TextDecoration.none,
                  fontSize: 9,
                  color: Color(0xFF703208),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  late Widget connectedToDevice = GestureDetector(
    onLongPress: () {
      print('hi');
    },
    onDoubleTap: () async {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
      );
      if (result != null) {
        for (String? path in result.paths.toList()) {
          if (path != null) {
            setState(() {
              filePaths.add(path);
              draggableChild = draggableFiles;
            });
          }
        }
      } else {}
    },
    child: Stack(
      fit: StackFit.expand,
      children: [
        Container(
          color: const Color(0xFF00925B),
          child: Padding(
            padding: EdgeInsetsGeometry.all(30),
            child: FittedBox(
              fit: BoxFit.fill,
              child: const Icon(
                Icons.link,
                color: Color.fromARGB(130, 0, 0, 0),
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsetsGeometry.only(bottom: 3),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Drag And Drop Files\nDouble Click To Select Files\nClick And Hold For Text',
                maxLines: 3,
                textAlign: TextAlign.center,
                style: TextStyle(
                  decoration: TextDecoration.none,
                  fontSize: 9,
                  color: Color(0xFF703208),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget receivingData = Container(
    color: const Color(0xFF977368),
    child: Padding(
      padding: EdgeInsetsGeometry.all(30),
      child: FittedBox(
        fit: BoxFit.fill,
        child: const Icon(Icons.download, color: Color.fromARGB(130, 0, 0, 0)),
      ),
    ),
  );

  Widget sendingData = Container(
    color: const Color(0xFFFF80EC),
    child: Padding(
      padding: EdgeInsetsGeometry.all(30),
      child: FittedBox(
        fit: BoxFit.fill,
        child: const Icon(Icons.upload, color: Color.fromARGB(130, 0, 0, 0)),
      ),
    ),
  );

  Widget draggableFiles = DraggableWidget(
    child: Container(
      color: const Color(0xFF38A3FE),
      child: Padding(
        padding: EdgeInsetsGeometry.all(30),
        child: FittedBox(
          fit: BoxFit.fill,
          child: const Icon(
            Icons.file_copy,
            color: Color.fromARGB(130, 0, 0, 0),
          ),
        ),
      ),
    ),
  );

  Widget draggingFiles = Container(
    color: const Color(0xFFD5576C),
    child: Padding(
      padding: EdgeInsetsGeometry.all(30),
      child: FittedBox(
        fit: BoxFit.fill,
        child: const Icon(
          Icons.drive_file_move_outline,
          color: Color.fromARGB(130, 0, 0, 0),
        ),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return DropRegion(
      formats: Formats.standardFormats,
      hitTestBehavior: HitTestBehavior.opaque,
      onDropOver: (event) {
        // You can inspect local data here, as well as formats of each item.
        // However on certain platforms (mobile / web) the actual data is
        // only available when the drop is accepted (onPerformDrop).
        final item = event.session.items.first;
        if (item.localData is Map) {
          // This is a drag within the app and has custom local data set.
        }
        if (item.canProvide(Formats.plainText)) {
          // this item contains plain text.
        }
        // This drop region only supports copy operation.
        if (event.session.allowedOperations.contains(DropOperation.copy)) {
          return DropOperation.copy;
        } else {
          return DropOperation.none;
        }
      },
      onDropEnter: (event) {
        // This is called when region first accepts a drag. You can use this
        // to display a visual indicator that the drop is allowed.
      },
      onDropLeave: (event) {
        // Called when drag leaves the region. Will also be called after
        // drag completion.
        // This is a good place to remove any visual indicators.
      },
      onPerformDrop: (event) async {
        if (dropAccepted) {
          for (final item in event.session.items) {
            final reader = item.dataReader!;
            if (reader.canProvide(Formats.plainText)) {
              reader.getValue(Formats.plainText, (droppedPath) {
                if (droppedPath != null) {
                  setState(() {
                    filePaths.add(droppedPath.trim());
                    draggableChild = draggableFiles;
                  });
                }
              });
              // reader.getFile(
              //   null,
              //   (file) async {
              //     print(file);
              //     // final stream = file.getStream();
              //     // await for (List<int> bytes in stream) {
              //     //   // print('Received ${bytes.length} bytes.');
              //     // }
              //   },
              //   onError: (error) {
              //     print('Error reading value $error');
              //   },
              // );
            }
          }
        } else {
          setState(() {
            droppedOnApp = true;
          });
        }
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          DragItemWidget(
            dragItemProvider: (request) async {
              final item = DragItem();
              for (final path in filePaths) {
                item.add(Formats.fileUri(Uri.file(path)));
              }
              request.session.dragging.addListener(() {
                final dragging = request.session.dragging.value;
                if (dragging) {
                  setState(() {
                    dropAccepted = false;
                    draggableChild = draggingFiles;
                  });
                } else {
                  setState(() {
                    dropAccepted = true;
                    draggableChild = draggableFiles;
                  });
                }
              });
              request.session.dragCompleted.addListener(() {
                final dragCompleteValue = request.session.dragCompleted.value;
                if (dragCompleteValue ==
                    dropOperationChoices[dropOperationChoice]) {
                  if (droppedOnApp == true) {
                    setState(() {
                      droppedOnApp = false;
                    });
                  } else {
                    setState(() {
                      filePaths = [];
                      draggableChild = notConnected;
                    });
                  }
                }
              });
              return item;
            },
            allowedOperations: () => [
              dropOperationChoices[dropOperationChoice],
            ],
            child: draggableChild,
          ),
          Container(
            alignment: Alignment.topRight,
            child: Padding(
              padding: EdgeInsetsGeometry.all(3),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                spacing: 5,
                children: [
                  IconButton(
                    tooltip: "Clear",
                    constraints: BoxConstraints(minHeight: 25, minWidth: 25),
                    padding: EdgeInsets.all(0),
                    color: Colors.grey.shade400,
                    icon: Icon(Icons.delete_outline, size: 20),
                    style: IconButton.styleFrom(
                      backgroundColor: Color(0xFFF7001F),
                    ),
                    onPressed: () {
                      setState(() {
                        filePaths = [];
                        draggableChild = notConnected;
                      });
                    },
                  ),
                  IconButton(
                    tooltip: "Connect to device",
                    constraints: BoxConstraints(minHeight: 25, minWidth: 25),
                    padding: EdgeInsets.all(0),
                    icon: Icon(Icons.link, size: 20),
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(0xFF00925B),
                    ),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (context) => const ConnectionPage(),
                        ),
                      );
                    },
                  ),
                  IconButton(
                    tooltip: "Settings",
                    constraints: BoxConstraints(minHeight: 25, minWidth: 25),
                    padding: EdgeInsets.all(0),
                    icon: Icon(Icons.settings, size: 20),
                    style: IconButton.styleFrom(backgroundColor: Colors.grey),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (context) => const SettingsPage(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<StatefulWidget> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  List<DropOperation> dropOperationChoices = [
    DropOperation.move,
    DropOperation.copy,
    DropOperation.link,
  ];

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Material(
          child: ListView(
            padding: const EdgeInsets.only(top: 20),
            children: <Widget>[
              ListTile(
                title: Text("Drop Operation"),
                subtitle: DropdownMenu(
                  initialSelection: dropOperationChoices[dropOperationChoice],
                  dropdownMenuEntries: [
                    DropdownMenuEntry(
                      label: "Move",
                      value: dropOperationChoices[0],
                    ),
                    DropdownMenuEntry(
                      label: "Copy",
                      value: dropOperationChoices[1],
                    ),
                    DropdownMenuEntry(
                      label: "Link",
                      value: dropOperationChoices[2],
                    ),
                  ],
                  onSelected: (value) {
                    if (value != null) {
                      updateSettings(
                        int,
                        'dropOperationChoice',
                        dropOperationChoices.indexOf(value),
                      );
                      setState(() {
                        dropOperationChoice = dropOperationChoices.indexOf(
                          value,
                        );
                      });
                    }
                  },
                ),
              ),
              ListTile(
                tileColor: const Color.fromARGB(107, 207, 216, 220),
                title: Text("Title bar"),
                subtitle: Text('Requires restart!'),
                subtitleTextStyle: TextStyle(color: Colors.red, fontSize: 11),
                trailing: SizedBox(
                  width: 35,
                  height: 25,
                  child: FittedBox(
                    fit: BoxFit.fill,
                    child: Switch(
                      value: titleBarVisible,
                      onChanged: (bool value) {
                        updateSettings(bool, 'titleBarVisible', value);
                        setState(() {
                          titleBarVisible = value;
                        });
                      },
                    ),
                  ),
                ),
              ),
              ListTile(
                title: Text("Always on Top"),
                subtitle: Text('Requires restart!'),
                subtitleTextStyle: TextStyle(color: Colors.red, fontSize: 11),
                trailing: SizedBox(
                  width: 35,
                  height: 25,
                  child: FittedBox(
                    fit: BoxFit.fill,
                    child: Switch(
                      value: alwaysOnTop,
                      onChanged: (bool value) {
                        updateSettings(bool, 'alwaysOnTop', value);
                        setState(() {
                          alwaysOnTop = value;
                        });
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          alignment: Alignment.topLeft,
          child: Padding(
            padding: EdgeInsetsGeometry.all(4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              spacing: 5,
              children: [
                IconButton(
                  tooltip: "Back",
                  constraints: BoxConstraints(maxHeight: 22, maxWidth: 22),
                  padding: EdgeInsets.zero,
                  icon: Icon(Icons.arrow_back),
                  iconSize: 22,
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                IconButton(
                  tooltip: "Reset settings",
                  constraints: BoxConstraints(maxHeight: 22, maxWidth: 22),
                  padding: EdgeInsets.zero,
                  icon: Icon(Icons.replay),
                  iconSize: 22,
                  style: IconButton.styleFrom(backgroundColor: Colors.grey),
                  onPressed: () async {
                    await clearSettings();
                    setState(() {});
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class ConnectionPage extends StatefulWidget {
  const ConnectionPage({super.key});

  @override
  State<StatefulWidget> createState() => _ConnecttionPageState();
}

class _ConnecttionPageState extends State<ConnectionPage> {
  void blScan() async {
    // listen to scan results
    // Note: `onScanResults` clears the results between scans. You should use
    //  `scanResults` if you want the current scan results *or* the results from the previous scan.
    var subscription = FlutterBluePlus.onScanResults.listen((results) {
      if (results.isNotEmpty) {
        ScanResult r = results.last; // the most recently found device
        print('${r.device.remoteId}: "${r.advertisementData.advName}" found!');
      }
    }, onError: (e) => print(e));

    // cleanup: cancel subscription when scanning stops
    FlutterBluePlus.cancelWhenScanComplete(subscription);

    // Wait for Bluetooth enabled & permission granted
    // In your real app you should use `FlutterBluePlus.adapterState.listen` to handle all states
    await FlutterBluePlus.adapterState
        .where((val) => val == BluetoothAdapterState.on)
        .first;

    // Start scanning w/ timeout
    // Optional: use `stopScan()` as an alternative to timeout
    await FlutterBluePlus.startScan(
      // withServices: [Guid("180D")], // match any of the specified services
      // withNames: ["Bluno"], // *or* any of the specified names
      timeout: Duration(seconds: 15),
    );

    // wait for scanning to stop
    await FlutterBluePlus.isScanning.where((val) => val == false).first;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          color: Colors.white54,
          child: ElevatedButton(
            onPressed: () async {
              if (await FlutterBluePlus.isSupported == false) {
                // Bluetooth not supported by the device
                return;
              }

              var subscription = FlutterBluePlus.adapterState.listen((
                BluetoothAdapterState state,
              ) {
                if (state == BluetoothAdapterState.on) {
                  blScan();
                } else {
                  // error
                }
              });

              // for iOS, the user controls bluetooth enable/disable
              if (Platform.isAndroid || Platform.isLinux) {
                try {
                  print('object');
                  await FlutterBluePlus.turnOn();
                  print('object');
                } catch (e) {
                  print(e);
                  // Failed to turn on Bluetooth
                }
              }

              subscription.cancel();
            },
            child: Text("bl connect"),
          ),
        ),
        Container(
          alignment: Alignment.topLeft,
          child: Padding(
            padding: EdgeInsetsGeometry.all(4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              spacing: 5,
              children: [
                IconButton(
                  tooltip: "Back",
                  constraints: BoxConstraints(maxHeight: 22, maxWidth: 22),
                  padding: EdgeInsets.zero,
                  icon: Icon(Icons.arrow_back),
                  iconSize: 22,
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

bool titleBarVisible = true;
bool alwaysOnTop = false;
int dropOperationChoice = 0;

Future<void> updateSettings(Type type, String key, dynamic value) async {
  final prefs = await SharedPreferences.getInstance();
  if (type == bool) {
    await prefs.setBool(key, value);
  } else if (type == String) {
    await prefs.setString(key, value);
  } else if (type == int) {
    await prefs.setInt(key, value);
  }
}

Future<void> loadSettings() async {
  final prefs = await SharedPreferences.getInstance();
  titleBarVisible = prefs.getBool('titleBarVisible') ?? true;
  alwaysOnTop = prefs.getBool('alwaysOnTop') ?? false;
  dropOperationChoice = prefs.getInt('dropOperationChoice') ?? 0;
}

Future<void> clearSettings() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('titleBarVisible', true);
  await prefs.setBool('alwaysOnTop', false);
  await prefs.setInt('dropOperationChoice', 0);
  await loadSettings();
}

void main() async {
  await loadSettings();
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  WindowOptions windowOptions = WindowOptions(
    titleBarStyle: titleBarVisible
        ? TitleBarStyle.normal
        : TitleBarStyle.hidden,
    alwaysOnTop: alwaysOnTop,
    size: Size(170, 170),
    skipTaskbar: false,
    minimumSize: Size(170, 170),
  );
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  runApp(const MyApp());
}
