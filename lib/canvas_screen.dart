import 'dart:async';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'utilities.dart';
import 'main.dart';
import 'deployment_model.dart';


class CanvasScreen extends StatefulWidget {
  const CanvasScreen({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  CanvasScreenState createState() => CanvasScreenState();
}

class CanvasScreenState extends State<CanvasScreen>  with AutomaticKeepAliveClientMixin{

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    loadSettings();
  }

  loadSettings() async {
    setState(() {
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
          title: AppHeader(title: 'Dashboard'),
          backgroundColor: Colors.grey[850]
      ),

      body: CustomPaint(
          painter: MachinesPainter(context),
          child: Container(),
      ),

      drawer: const MainDrawer(
        // parameters
      ),
    );
  }
}


// For painting machines
class MachinesPainter extends CustomPainter {

  final BuildContext context;
  final DeploymentState deploymentState;

  MachinesPainter(this.context):
        deploymentState = Provider.of<DeploymentState>(context, listen: true);


  void drawName(Canvas context, String name, double x, double y, double sz, Color clr, Color bck)
  {
    TextSpan span = TextSpan(
        style: TextStyle(
            color: clr,
            backgroundColor: bck,
            fontSize: sz,
            fontFamily: 'Roboto',
            fontWeight: FontWeight.bold
        ),
        text: name
    );
    TextPainter tp = TextPainter(
        text: span,
        textAlign: TextAlign.left,
        textDirection: TextDirection.ltr,
    );
    tp.layout();
    tp.paint(context, Offset(x, y));
  }

  @override
  void paint(Canvas canvas, Size size) {

    if (deploymentState.gotSiteMapImage) {
      canvas.drawImage(deploymentState.sitemapImage, const Offset(0.0,0.0), Paint());
      // paintImage(
      //     canvas: canvas,
      //     rect: Rect.fromLTWH(0, 0, scaledWidth, scaledHeight),
      //     image: deploymentState.sitemapImage,
      //     fit: BoxFit.scaleDown,
      //     repeat: ImageRepeat.noRepeat,
      //     scale: 1.0,
      //     alignment: Alignment.center,
      //     flipHorizontally: false,
      //     filterQuality: FilterQuality.high
      // );
    }

    drawName(canvas, deploymentState.drawingTicker.toString(), 0, 0, 12.0, Colors.grey, Colors.white);

    final rigFramePaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.indigo
      ..strokeWidth = 2;
    final rigFramePaint2 = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.white
      ..strokeWidth = 6;

    canvas.drawPoints(PointMode.points, deploymentState.rigFramesOffsets, rigFramePaint2);
    canvas.drawPoints(PointMode.points, deploymentState.rigFramesOffsets, rigFramePaint);

    final stationsPaint = Paint()
      // ..style = PaintingStyle.stroke
      ..color = Colors.indigo
      ..strokeWidth = 10;
    final stationsPaint2 = Paint()
    // ..style = PaintingStyle.stroke
      ..color = Colors.white
      ..strokeWidth = 12;

    canvas.drawPoints(PointMode.points, deploymentState.stationsOffsets, stationsPaint2);
    canvas.drawPoints(PointMode.points, deploymentState.stationsOffsets, stationsPaint);

    for (Station stn in deploymentState.stations) {
      drawName(canvas, " "+stn.name+" ", stn.x-10, stn.y-20, 12.0, Colors.indigo, Colors.white);
    }

    deploymentState.machines.forEach((id, machineState)
    {
      double tableRowDistance = 25;

      // Symbol gets draw at machine location
      Offset symbolLocation = machineState.machineOffset;
      // If invalid location, draw in table
      if ((symbolLocation.dx < 0) || (symbolLocation.dy < 0)) {
        symbolLocation = Offset(
            deploymentState.machinesTableOffset.dx + 110,
            deploymentState.machinesTableOffset.dy + machineState.machineSeq*tableRowDistance + 8
        );
      }

      Color clr = Colors.red;
      Color clr2 = clr;
      if (machineState.lightsColor == 'red') {
        clr = Colors.red; clr2 = clr;
      }
      else if (machineState.lightsColor == 'gold') {
        clr = Colors.amber; clr2 = clr;
        if (machineState.lightsShape == 'spokes_with_center') {
          clr2 = Colors.yellow;
        }
      }
      else if (machineState.lightsColor == 'green') {
        clr = Colors.green; clr2 = clr;
      }
      else if (machineState.lightsColor == 'blue') {
        clr = Colors.blueAccent; clr2 = clr;
      }
      else if (machineState.lightsColor == 'cyan') {
        clr = Colors.cyan; clr2 = clr;
      }
      else if (machineState.lightsColor == 'limegreen') {
        clr = Colors.green; clr2 = clr;
      }
      else if (machineState.lightsColor == 'greenyellow') {
        clr = Colors.green; clr2 = clr;
      }
      else if (machineState.lightsColor == 'lime') {
        clr = Colors.green; clr2 = clr;
      }
      else if (machineState.lightsColor == 'orange') {
        clr = Colors.orange; clr2 = clr;
      }
      else if (machineState.lightsColor == 'magenta') {
        clr = Colors.purple; clr2 = clr;
      }
      else if (machineState.lightsColor == 'azure') {
        clr = Colors.blueAccent; clr2 = clr;
      }

      if (machineState.lightsShape == 'square') {
        final machinePaint = Paint()..style = PaintingStyle.stroke..color = clr..strokeWidth = 4..style = PaintingStyle.fill;
        canvas.drawRect(Offset(symbolLocation.dx-7.5, symbolLocation.dy-7.5) & const Size(15,15), machinePaint);
        final machinePaint2 = Paint()..style = PaintingStyle.stroke..color = Colors.black..strokeWidth = 1;
        canvas.drawRect(Offset(symbolLocation.dx-7.5, symbolLocation.dy-7.5) & const Size(15,15), machinePaint2);
      }
      else if (machineState.lightsShape == 'circle') {
        final machinePaint = Paint()..style = PaintingStyle.stroke..color = clr..strokeWidth = 6..style = PaintingStyle.fill;
        canvas.drawCircle(symbolLocation,6,machinePaint);
        final machinePaint2 = Paint()..style = PaintingStyle.stroke..color = Colors.black..strokeWidth = 1;
        canvas.drawCircle(symbolLocation,6,machinePaint2);
      }
      else if (machineState.lightsShape == 'spokes') {
        final machinePaint = Paint()..style = PaintingStyle.stroke..color = clr..strokeWidth = 6;
        canvas.drawCircle(symbolLocation,6,machinePaint);
        final machinePaint2 = Paint()..style = PaintingStyle.stroke..color = Colors.white..strokeWidth = 4..style = PaintingStyle.fill;
        canvas.drawCircle(symbolLocation,4,machinePaint2);
        final machinePaint3 = Paint()..style = PaintingStyle.stroke..color = Colors.black..strokeWidth = 1;
        canvas.drawCircle(symbolLocation,9,machinePaint3);
      }
      else if (machineState.lightsShape == 'spokes_with_center') {
        final machinePaint = Paint()..style = PaintingStyle.stroke..color = clr..strokeWidth = 6;
        canvas.drawCircle(symbolLocation,6,machinePaint);
        final machinePaint2 = Paint()..style = PaintingStyle.stroke..color = clr2..strokeWidth = 4..style = PaintingStyle.fill;
        canvas.drawCircle(symbolLocation,4,machinePaint2);
        final machinePaint3 = Paint()..style = PaintingStyle.stroke..color = Colors.black..strokeWidth = 1;
        canvas.drawCircle(symbolLocation,9,machinePaint3);
      }
      else {
        final machinePaint = Paint()..style = PaintingStyle.stroke..color = clr..strokeWidth = 4;
        canvas.drawCircle(symbolLocation,5,machinePaint);
      }

      // Draw Machine Name
      drawName(canvas, machineState.clientName, machineState.machineOffset.dx-10, machineState.machineOffset.dy-35, 20.0, Colors.black, Colors.limeAccent);

      // Draw Voltage
      // drawName(canvas, machineState.batteryVoltage.toStringAsFixed(1)+"V", machineState.machineOffset.dx-10, machineState.machineOffset.dy+10, 12.0, Colors.black, Colors.greenAccent);

      // Draw Machines table
      drawName(canvas,
          machineState.clientName,
          deploymentState.machinesTableOffset.dx,
          deploymentState.machinesTableOffset.dy + machineState.machineSeq*tableRowDistance,
          15.0,
          Colors.black,
          Colors.limeAccent
      );
      drawName(canvas,
          machineState.batteryVoltage.toStringAsFixed(1)+"V",
          deploymentState.machinesTableOffset.dx + 50,
          deploymentState.machinesTableOffset.dy + machineState.machineSeq*tableRowDistance,
          15.0,
          Colors.black,
          (machineState.batteryVoltage > 35.5) ? Colors.lightGreenAccent : Colors.pink.shade100
      );
      drawName(canvas,
          machineState.lightsMessage,
          deploymentState.machinesTableOffset.dx + 130,
          deploymentState.machinesTableOffset.dy + machineState.machineSeq*tableRowDistance + 2,
          10.0,
          Colors.black,
          Colors.white
      );


    });



  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }

}

