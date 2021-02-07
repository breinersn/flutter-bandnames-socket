import 'dart:io';

import 'package:band_name/services/sockets_service.dart';
import 'package:band_name/models/band.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pie_chart/pie_chart.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Band> bands = [];

  @override
  void initState() {
    //escuchar eventos permanentemente
    final socketService = Provider.of<SocketService>(context, listen: false);
    socketService.socket.on('bandas-activas', _handleActivebands);
    super.initState();
  }

  _handleActivebands(dynamic payload) {
    this.bands = (payload as List).map((band) => Band.fomMap(band)).toList();

    setState(() {}); //redibujar el widget al recibir bandas-activa
  }

  @override
  void dispose() {
    //dejar de escuchar eventos
    final socketService = Provider.of<SocketService>(context, listen: false);
    socketService.socket.off('bandas-activas');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final socketService = Provider.of<SocketService>(context);

    return Scaffold(
        appBar: AppBar(
          title: Center(
              child:
                  Text('BandNames', style: TextStyle(color: Colors.black87))),
          backgroundColor: Colors.white,
          elevation: 1,
          actions: [
            Container(
              margin: EdgeInsets.only(right: 10),
              child: (socketService.serverStatus == ServerStatus.Online)
                  ? Icon(Icons.check_circle, color: Colors.greenAccent[400])
                  : Icon(Icons.offline_bolt, color: Colors.red),
            )
          ],
        ),
        body: Column(
          children: <Widget>[
            _showGraph(),
            Expanded(
              child: ListView.builder(
                  itemCount: bands.length,
                  itemBuilder: (context, i) => _bandTile(bands[i])),
            )
          ],
        ),
        floatingActionButton: FloatingActionButton(
            child: Icon(Icons.add), elevation: 1, onPressed: addBandPress));
  }

  Widget _bandTile(Band band) {
    final socketService = Provider.of<SocketService>(context, listen: false);

    return Dismissible(
      key: Key(band.id),
      onDismissed: (_) => socketService.emit('band-delete', {'id': band.id}),
      background: Container(
        padding: EdgeInsets.only(left: 8.0),
        color: Colors.red,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Delete Band',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(band.name.substring(0, 2)),
          backgroundColor: Colors.blue[100],
        ),
        title: Text(band.name),
        trailing: Text('${band.votes}', style: TextStyle(fontSize: 20)),
        onTap: () => socketService.emit('band-votes', {'id': band.id}),
      ),
    );
  }

  addBandPress() {
    final textController = new TextEditingController();

    if (Platform.isAndroid) {
      showDialog(
          context: context,
          builder: (_) => AlertDialog(
                  title: Text('New band name'),
                  content: TextField(
                    controller: textController,
                  ),
                  actions: <Widget>[
                    MaterialButton(
                        child: Text('Add'),
                        elevation: 5,
                        textColor: Colors.blue,
                        onPressed: () => addbandToList(textController.text))
                  ]));
    }

    if (Platform.isIOS) {
      showCupertinoDialog(
          context: context,
          builder: (_) => CupertinoAlertDialog(
                title: Text('New band name'),
                content: CupertinoTextField(
                  controller: textController,
                ),
                actions: <Widget>[
                  CupertinoDialogAction(
                      isDefaultAction: true,
                      child: Text('Add'),
                      onPressed: () => addbandToList(textController.text)),
                  CupertinoDialogAction(
                      isDestructiveAction: true,
                      child: Text('Dismiss'),
                      onPressed: () => Navigator.pop(context))
                ],
              ));
    }
  }

  addbandToList(String name) {
    if (name.length > 1) {
      final socketService = Provider.of<SocketService>(context, listen: false);
      socketService.emit('band-name', {'name': name});
    }
    Navigator.pop(context);
  }

// mostrar graficos
  Widget _showGraph() {
    Map<String, double> dataMap = new Map();
    bands.forEach((band) {
      dataMap.putIfAbsent(band.name, () => band.votes.toDouble());
    });

    final List<Color> colorList = [
      Colors.green[200],
      Colors.green[500],
      Colors.red[200],
      Colors.red[500],
      Colors.yellow[200],
      Colors.yellow[700],
      Colors.pink[200],
      Colors.pink[500],
    ];

    //VERSION 3.0.1
    // return Container(
    //     padding: EdgeInsets.only(top: 15),
    //     width: double.infinity,
    //     height: 200,
    //     child: PieChart(
    //       dataMap: dataMap,
    //       animationDuration: Duration(milliseconds: 800),
    //       showChartValuesInPercentage: true,
    //       showChartValues: true,
    //       showChartValuesOutside: false,
    //       chartValueBackgroundColor: Colors.grey[200],
    //       colorList: colorList,
    //       showLegends: true,
    //       decimalPlaces: 0,
    //       chartType: ChartType.ring,
    //     ));

    return Container(
      padding: EdgeInsets.only(top: 20),
      width: double.infinity,
      //height: 200,
      child: PieChart(
        dataMap: dataMap,
        animationDuration: Duration(milliseconds: 800),
        chartLegendSpacing: 32,
        chartRadius: MediaQuery.of(context).size.width / 2.2,
        colorList: colorList,
        initialAngleInDegree: 0,
        chartType: ChartType.ring,
        ringStrokeWidth: 22,
        //centerText: "HYBRID",
        legendOptions: LegendOptions(
          showLegendsInRow: false,
          legendPosition: LegendPosition.right,
          showLegends: true,
          //legendShape: _BoxShape.circle,
          legendTextStyle: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        chartValuesOptions: ChartValuesOptions(
          showChartValueBackground: false,
          showChartValues: true,
          showChartValuesInPercentage: true,
          showChartValuesOutside: false,
        ),
      ),
    );
  }
}
