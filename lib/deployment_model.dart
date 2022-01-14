


// State of a machine in the deployment
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
import 'dart:ui' as ui;
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';


import 'utilities.dart';
import 'main.dart';

// State of a machine
class MachineState {
  final String name;

  String clientName = '';
  String statusJson = '';
  int machineSeq = -1;

  String remoteServerURL = 'backend.ups.anantak.net';
  String localServerURL = 'backend.ups.anantak.net'; //'127.0.0.1:80';

  Map<String,dynamic> statusMap = {};

  // Machine's variables
  int machineCurrentRouteNum = -1; // route num of the machine
  int machineCurrentMapNum = -1;
  int machineCurrentRigFrameNum = -1;
  int machineLastRouteNum = -1; // route num of the machine
  int machineLastMapNum = -1;
  int machineLastRigFrameNum = -1;
  Offset machineOffset = const Offset(-10,-10);

  double batteryVoltage = 0.0;
  double batteryCurrent = 0.0;
  double ambientTemperature = 0.0;
  double ambientHumidity = 0.0;
  double cpuBattery = -1.0;
  double cpuTemperature = -100.0;
  double machineSpeed = 0.0;
  double machineTargetSpeed = 0.0;
  double machineSteering = 0.0;
  String lightsMessage = 'Machine status shows here';
  String lightsColor = '';
  String lightsShape = '';
  String batteryInfoMessage = 'Battery info shows here';
  String airInfoMessage = 'Air info shows here';
  String controlInfoMessage = 'Control info shows here';
  int gatewayRoute = 0; // current gateway route
  String sensorUnitVersionString = '';

  // Batch variables
  String batchId = '';
  String batchOperatorId = '';
  String batchTuggerId = '';
  String batchCurrCommand = '';
  int    batchCurrCommandTs = -1;
  String batchCurrCommandTsStr = '';
  String batchCurrLocation = '';
  String batchNextLocation = '';
  int    batchNumCarts = -1;
  int    batchCartNumber = -1;
  String batchCartPosition = '';
  int    batchDelaySeconds = -1;
  String batchItemId = '';
  int    batchQuantity = -1;
  String batchDistance = '';
  String batchSpeed = '';
  String batchStart = '';
  String batchStop = '';
  int    batchWaitSec = -1;
  List<String>  tripCurrStops = [];

  // Route variables
  int    selectedStationNum = 0;
  int    targetStationNum = 0;

  // Learn map variables
  int machineLearnMapIndex = -1;
  int machineLearnMapNumRFs = -1;
  int machineLearnMapSave = -1;
  int machineLearnMapTypeIndex = 0;
  int machineLearnMapSegmentIndex = 0;
  int machineLearnMapMarkerTypeIndex = 0;
  int machineLearnStationHundredsNum = 0;
  int machineLearnStationTensNum = 0;
  int machineLearnStationUnitsNum = 0;
  int machineLearnBuildRouteTypeIndex = 0;
  int machineTransferMapTypeIndex = 0;

  int machineTransferMapTypeIndexLastTriggered = 0;
  int machineTransferMapTypeIndexLastTriggeredTimestampMs = 0;
  int machineTransferMapStatusLastSentTimestampMs = 0;
  double transferMapPercentComplete = 0.0;
  int transferMapStartedAgoMin = 0;
  int transferMapEndedAgoMin = 0;
  String transferMapStatusStr = '';


  int gatewayHandheldClientDelayMs = -1;
  int gatewayCommanderClientDelayMs = -1;
  int gatewayHandheldClientDelayTimestampMs = 0;

  void assignStatusValues() {
    try {
      if (statusMap.containsKey('status')) {
        Map<String, dynamic> statusMsg = statusMap['status'];

        // Measurements
        if (statusMsg.containsKey('battery_current')) batteryCurrent = statusMsg['battery_current'].toDouble();
        if (statusMsg.containsKey('battery_voltage')) batteryVoltage = statusMsg['battery_voltage'].toDouble();
        if (statusMsg.containsKey('env')) {
          Map<String, dynamic> envMsg = statusMsg['env'];
          if (envMsg.containsKey('cpubat'))  cpuBattery = envMsg['cpubat'].toDouble();
          if (envMsg.containsKey('cputemp')) cpuTemperature = envMsg['cputemp'].toDouble();
          if (envMsg.containsKey('ambtemp')) ambientTemperature = envMsg['ambtemp'].toDouble();
          if (envMsg.containsKey('ambhum'))  ambientHumidity = envMsg['ambhum'].toDouble();
        }

        // Lights
        if (statusMsg.containsKey('lights')) {
          Map<String, dynamic> lightsMsg = statusMsg['lights'];
          if (lightsMsg.containsKey('msg')) lightsMessage = lightsMsg['msg'].toString();
          if (lightsMsg.containsKey('color')) lightsColor = lightsMsg['color'].toString();
          if (lightsMsg.containsKey('shape')) lightsShape = lightsMsg['shape'].toString();
        }
        if (statusMsg.containsKey('speed')) machineSpeed = statusMsg['speed'].toDouble();
        if (statusMsg.containsKey('tgt_speed')) machineTargetSpeed = statusMsg['tgt_speed'].toDouble();
        if (statusMsg.containsKey('steer')) machineSteering = statusMsg['steer'].toDouble();

        // Learn commands
        if (statusMsg.containsKey('learn')) machineLearnMapIndex = statusMsg['learn'].toInt();
        if (statusMsg.containsKey('nRF'))   machineLearnMapNumRFs = statusMsg['nRF'].toInt();
        if (statusMsg.containsKey('save'))  machineLearnMapSave = statusMsg['save'].toInt();
      }
      if (statusMap.containsKey('current_trip')) {
        Map<String, dynamic> tripMsg = statusMap['current_trip'];
        if (tripMsg.containsKey('route_id')) {
          String routeID = tripMsg['route_id'].toString();
          if (routeID.length > 6) {
            String routeNumStr = routeID.substring(6);
            int routeNum = int.parse(routeNumStr);
            machineCurrentRouteNum = routeNum;
          }
          else {
            machineCurrentRouteNum = -1;
          }
          // if (isInDebugMode) print(_machineCurrentRouteNum);
        }
        if (tripMsg.containsKey('wait_s')) batchWaitSec = tripMsg['wait_s'].toInt();
        if (tripMsg.containsKey('curr_stops')) tripCurrStops = tripMsg['curr_stops'].cast<String>();
        // if (isInDebugMode) {print(_tripCurrStops);}
      }
      if (statusMap.containsKey('location')) {
        Map<String, dynamic> locationMsg = statusMap['location'];
        if (locationMsg.containsKey('map_num')) machineCurrentMapNum = locationMsg['map_num'].toInt();
        if (locationMsg.containsKey('rf_num'))  machineCurrentRigFrameNum = locationMsg['rf_num'].toInt();
      }
      else {
        if (isInDebugMode) print("location msg not found");
      }
      if (statusMap.containsKey('gateway_route')) {
        gatewayRoute = statusMap['gateway_route'].toInt();
      }
      if (statusMap.containsKey('batch')) {
        Map<String, dynamic> batchMsg = statusMap['batch'];

        if (batchMsg.containsKey('batch_id')) batchId = batchMsg['batch_id'].toString();
        if (batchMsg.containsKey('operator_id')) batchOperatorId = batchMsg['operator_id'].toString();
        if (batchMsg.containsKey('tugger_id')) batchTuggerId = batchMsg['tugger_id'].toString();
        if (batchMsg.containsKey('curr_command')) batchCurrCommand = batchMsg['curr_command'].toString();
        if (batchMsg.containsKey('curr_command_ts_us')) {
          batchCurrCommandTs = batchMsg['curr_command_ts_us'].toInt();
          var date = DateTime.fromMicrosecondsSinceEpoch(batchCurrCommandTs);
          batchCurrCommandTsStr = date.month.toString()+'/'+date.day.toString()+' '+date.hour.toString()+':'+date.minute.toString();
        }

        if (batchMsg.containsKey('current_location')) batchCurrLocation = batchMsg['current_location'].toString();
        if (batchMsg.containsKey('next_location')) batchNextLocation = batchMsg['next_location'].toString();
        if (batchMsg.containsKey('num_carts')) batchNumCarts = batchMsg['num_carts'].toInt();
        if (batchMsg.containsKey('cart_number')) batchCartNumber = batchMsg['cart_number'].toInt();
        if (batchMsg.containsKey('cart_position')) batchCartPosition = batchMsg['cart_position'].toString();
        if (batchMsg.containsKey('delay_seconds')) batchDelaySeconds = batchMsg['delay_seconds'].toInt();
        if (batchMsg.containsKey('item_id')) batchItemId = batchMsg['item_id'].toString();
        if (batchMsg.containsKey('quantity')) batchQuantity = batchMsg['quantity'].toInt();
      }
      if (statusMap.containsKey('monitor_reply')) {
        Map<String, dynamic> monitorReplyMsg = statusMap['monitor_reply'];
        if (monitorReplyMsg.containsKey('result')) {
          Map<String, dynamic> resultMsg = monitorReplyMsg['result'];
          if (resultMsg.containsKey('percent_complete')) transferMapPercentComplete = resultMsg['percent_complete'].toDouble();
          if (resultMsg.containsKey('started_ago_min')) transferMapStartedAgoMin = resultMsg['started_ago_min'].toInt();
          if (resultMsg.containsKey('ended_ago_min')) transferMapEndedAgoMin = resultMsg['ended_ago_min'].toInt();
          // setTransferMapStatusStr();
        }
      }
      if (statusMap.containsKey('version')) {
        sensorUnitVersionString = statusMap['version'];
      }
      if (statusMap.containsKey('client_type_delays_ms')) {
        List<dynamic> clientTypeDelaysMs = statusMap['client_type_delays_ms'];
        gatewayHandheldClientDelayMs = clientTypeDelaysMs[0];
        gatewayCommanderClientDelayMs = clientTypeDelaysMs[1];
      }
    } catch(e) {
      if (isInDebugMode) {
        print('Could not parse the machine message');
        print(e);
      }
    }
  }

  MachineState({required this.name});

  void setStatusJsonString(String json) {
    // Save the json string
    statusJson = json;

    // Parse the JSON string
    statusMap = jsonDecode(statusJson);
    assignStatusValues();

    // Post assignment steps
    saveLastLocation();
  }

  void saveLastLocation() {
    if ((machineCurrentRouteNum > -1) && (machineCurrentMapNum > -1) && (machineCurrentRigFrameNum > -1)) {
      machineLastRouteNum = machineCurrentRouteNum;
      machineLastMapNum = machineCurrentMapNum;
      machineLastRigFrameNum = machineCurrentRigFrameNum;
    }
  }

  factory MachineState.fromId(String id) => MachineState(name: id);

  Future<void> queryState() async {
    if (isInDebugMode) print("Querying state for "+name);

    var client = http.Client();
    try {
      final response = await client.post(
          Uri.https(localServerURL, '/machine-status'),
          body: convert.jsonEncode(<String, String>{
            'UserEmail': loginEmail,
            'MachineID': name,
          })
      );
      var decodedResponse = convert.jsonDecode(
          convert.utf8.decode(response.bodyBytes)
      ) as Map;
      var result = decodedResponse['result'] as String;
      if (isInDebugMode) print(result+" "+name);
      if (result == 'SUCCESS') {
        final mcstatus = decodedResponse['machine-status'] as String;
        setStatusJsonString(mcstatus);
      }
    } finally {
      client.close();
    }
  }

}

class RigFrame {
  int routeIdx = -1;
  int mapIdx = -1;
  int rfIdx = -1;
  double yaw = 0.0;
  double x = -1.0;
  double y = -1.0;

  RigFrame({
    required this.routeIdx,
    required this.mapIdx,
    required this.rfIdx,
    required this.yaw,
    required this.x,
    required this.y,
  });


  factory RigFrame.fromJson(Map<dynamic, dynamic> json) => RigFrame(
      routeIdx: json["rte"].toInt(),
      mapIdx: json["map"].toInt(),
      rfIdx: json["rf"].toInt(),
      yaw: json["rz"].toDouble()*0.10,
      x: json["x"].toDouble()*0.1,
      y: json["y"].toDouble()*0.1,
  );
}

class Station {
  String name = '';
  int mapIdx = -1;
  int rfIdx = -1;
  double yaw = 0.0;
  double x = -1.0;
  double y = -1.0;

  Station({
    required this.name,
    required this.mapIdx,
    required this.rfIdx,
    required this.yaw,
    required this.x,
    required this.y,
  });


  factory Station.fromJson(Map<dynamic, dynamic> json) => Station(
    name: json["stn"].toString(),
    mapIdx: json["map"].toInt(),
    rfIdx: json["rf"].toInt(),
    yaw: json["rz"].toDouble()*0.10,
    x: json["x"].toDouble()*0.1,
    y: json["y"].toDouble()*0.1,
  );

}

// State of the deployment
class DeploymentState extends ChangeNotifier {

  String remoteServerURL = 'backend.ups.anantak.net';
  String localServerURL = 'backend.ups.anantak.net'; //'127.0.0.1:80';

  String clientID = '';
  String clientName = '';
  List<String> deploymentIDs = [];
  List<String> deploymentNames = [];

  String deploymentID = '';
  String deploymentName = '';

  List<String> machineIDs = [];
  List<String> machineNames = [];
  Map<String, MachineState> machines = {};
  List<Offset> machineOffsets = [];

  late ui.Image sitemapImage;
  bool gotSiteMapImage = false;

  List<RigFrame> rigFrames = [];
  List<Offset> rigFramesOffsets = [];

  List<Station> stations = [];
  List<Offset> stationsOffsets = [];

  Offset machinesTableOffset = const Offset(700,350);

  int drawingTicker = 0;

  // Connection status timer
  final Duration _loginStatusTimeout = const Duration(milliseconds: 200);
  late Timer _loginStatusTimer;

  // Drawing timer
  final Duration _drawingTimeout = const Duration(milliseconds: 1000);
  late Timer _drawingTimer;

  // Machines query timer
  final Duration _machinesQueryTimeout = const Duration(seconds: 5);
  late Timer _machinesQueryTimer;

  // Constructor
  DeploymentState() {
    if (isInDebugMode) {print("Starting Deployment State");}

    // Create a login status timer
    _loginStatusTimer = Timer.periodic(_loginStatusTimeout, checkLogin);

  }

  void checkLogin(Timer timer) {
    if (!isLoggedIn) {if (isInDebugMode) print("Waiting for login"); return;}
    _loginStatusTimer.cancel();
    fetchDataFromServer();

    // Create a drawing timer
    _drawingTimer = Timer.periodic(_drawingTimeout, tickDrawing);

    // Query states and create machines query timer
    queryMachineStates();
    _machinesQueryTimer = Timer.periodic(_machinesQueryTimeout, queryMachines);
  }

  void tickDrawing(Timer timer) {
    drawingTicker++;
    drawingTicker %= 10000000;
    if (isInDebugMode) {print(drawingTicker);}
    notifyListeners();
  }

  void queryMachineStates() {
    machines.forEach((id, machineState) {
      machineState.queryState();
    });
    // Update machines' display offsets after querying
    updateMachineOffsets();
  }

  void queryMachines(Timer timer) {
    queryMachineStates();
  }

  Offset getOffsetForRouteMapRigFrameIdx(int rtIdx, int mapIdx, int rfIdx) {
    Offset location = const Offset(-10,-10);
    for (RigFrame rf in rigFrames) {
      if ((rf.routeIdx == rtIdx) && (rf.mapIdx == mapIdx) && (rf.rfIdx == rfIdx)) {
        location = Offset(rf.x,rf.y);
        break;
      }
    }
    return location;
  }

  Offset getOffsetForMachineState(String machineId) {
    Offset location = const Offset(-10,-10);
    if (machines.containsKey(machineId)) {
      int rtIdx  = machines[machineId]!.machineLastRouteNum;
      int mapIdx = machines[machineId]!.machineLastMapNum;
      int rfIdx  = machines[machineId]!.machineLastRigFrameNum;
      location = getOffsetForRouteMapRigFrameIdx(rtIdx, mapIdx, rfIdx);
      // if (isInDebugMode) print(machineId+":"+rtIdx.toString()+"|"+mapIdx.toString()+"|"+rfIdx.toString());
    }
    return location;
  }

  void updateMachineOffsets() {
    machineOffsets.clear();
    for (String machineId in machineIDs) {
      Offset machineOffset = getOffsetForMachineState(machineId);
      machineOffsets.add(machineOffset);
      machines[machineId]!.machineOffset = machineOffset;
    }
  }

  void fetchDataFromServer() {
    fetchDeploymentsList();
    fetchMachinesList();
    fetchSitemapImage();
    fetchSitemapRoutePoints();
    fetchSitemapRouteStations();

    notifyListeners();
  }

  Future<void> fetchDeploymentsList() async {
    var client = http.Client();
    try {
      final response = await client.post(
        Uri.https(localServerURL, '/client-deployments'),
        body: convert.jsonEncode(<String, String>{
          'UserEmail': loginEmail,
        })
      );
      var decodedResponse = convert.jsonDecode(
          convert.utf8.decode(response.bodyBytes)
      ) as Map;
      var result = decodedResponse['result'] as String;
      if (isInDebugMode) print(result);
      if (result == 'SUCCESS') {
        clientID = decodedResponse['client-id'].toString();
        clientName = decodedResponse['client-name'].toString();
        deploymentIDs = List<String>.from(decodedResponse['deployment-ids-list']);;
        deploymentNames = List<String>.from(decodedResponse['deployment-names-list']);;
        if (deploymentIDs.isNotEmpty) deploymentID = deploymentIDs.first;
        if (deploymentNames.isNotEmpty) deploymentName = deploymentNames.first;
        if (isInDebugMode) {
          print(clientID);
          print(clientName);
          print(deploymentIDs);
          print(deploymentNames);
          print(deploymentID);
          print(deploymentName);
        }
      }
    } finally {
      client.close();
    }
  }

  Future<void> fetchMachinesList() async {
    var client = http.Client();
    try {
      final response = await client.post(
          Uri.https(localServerURL, '/machines-list'),
          body: convert.jsonEncode(<String, String>{
            'UserEmail': loginEmail,
            'deploymentID': deploymentID,
          })
      );
      var decodedResponse = convert.jsonDecode(
          convert.utf8.decode(response.bodyBytes)
      ) as Map;
      var result = decodedResponse['result'] as String;
      if (isInDebugMode) print(result);
      if (result == 'SUCCESS') {
        machineIDs = List<String>.from(decodedResponse['machine-ids-list']);
        machineNames = List<String>.from(decodedResponse['machine-names-list']);
        int i=0;
        for (String id in machineIDs) {
          machines.putIfAbsent(id, () => MachineState.fromId(id));
          machines[id]!.clientName = machineNames[i];
          machines[id]!.machineSeq = i;
          i++;
        }
        if (isInDebugMode) {
          print(machineIDs);
          print(machineNames);
          print("Create num machines: "+machines.length.toString());
        }
      }
    } finally {
      client.close();
    }
  }


  Future<void> fetchSitemapImage() async {
    var client = http.Client();
    try {
      final response = await client.post(
          Uri.https(localServerURL, '/sitemap-image'),
          body: convert.jsonEncode(<String, String>{
            'UserEmail': loginEmail,
            'deploymentID': deploymentID,
          })
      );
      if (isInDebugMode) print("Got a Sitemap image");
      // sitemapImage = Image.memory(response.bodyBytes).image as MemoryImage;
      final Completer<ui.Image> completer = Completer();
      ui.decodeImageFromList(response.bodyBytes, (ui.Image img) {
        return completer.complete(img);
      });
      sitemapImage = await completer.future;
      print(sitemapImage.height.toString()+"x"+sitemapImage.width.toString());
      gotSiteMapImage = true;
    } finally {
      client.close();
    }
  }


  Future<void> fetchSitemapRoutePoints() async {
    var client = http.Client();
    try {
      final response = await client.post(
          Uri.https(localServerURL, '/sitemap-route-points'),
          body: convert.jsonEncode(<String, String>{
            'UserEmail': loginEmail,
            'deploymentID': deploymentID,
          })
      );
      var decodedResponse = convert.jsonDecode(
          convert.utf8.decode(response.bodyBytes)
      ) as Map;
      var result = decodedResponse['result'] as String;
      if (isInDebugMode) print(result);
      if (result == 'SUCCESS') {
        final rfs = decodedResponse['sitemap-route-points'];
        for (Map rf in rfs) {
          rigFrames.add(RigFrame.fromJson(rf));
        }
        for (RigFrame rfObj in rigFrames) {
          rigFramesOffsets.add(Offset(rfObj.x,rfObj.y));
        }
        if (isInDebugMode) print("Num rigFrames received: "+rigFrames.length.toString());
        // machineIDs = List<String>.from(decodedResponse['machine-ids-list']);
        // machineNames = List<String>.from(decodedResponse['machine-names-list']);
        // if (isInDebugMode) {
        //   print(machineIDs);
        //   print(machineNames);
        // }
      }
    } finally {
      client.close();
    }
  }


  Future<void> fetchSitemapRouteStations() async {
    var client = http.Client();
    try {
      final response = await client.post(
          Uri.https(localServerURL, '/sitemap-route-stations'),
          body: convert.jsonEncode(<String, String>{
            'UserEmail': loginEmail,
            'deploymentID': deploymentID,
          })
      );
      var decodedResponse = convert.jsonDecode(
          convert.utf8.decode(response.bodyBytes)
      ) as Map;
      var result = decodedResponse['result'] as String;
      if (isInDebugMode) print(result);
      if (result == 'SUCCESS') {
        final rfs = decodedResponse['sitemap-route-stations'];
        for (Map rf in rfs) {
          stations.add(Station.fromJson(rf));
        }
        for (Station stnObj in stations) {
          stationsOffsets.add(Offset(stnObj.x,stnObj.y));
          // Modify station_ to PD
          stnObj.name = stnObj.name.replaceAll("station_", "PD");
        }
        if (isInDebugMode) print("Num stations received: "+stations.length.toString());
      }
    } finally {
      client.close();
    }
  }


}
