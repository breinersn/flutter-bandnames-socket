import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:band_name/services/sockets_service.dart';

class StatusPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final socketService = Provider.of<SocketService>(context);

    return Scaffold(
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Server status: ${socketService.serverStatus}'),
        ],
      )),
    );
  }
}
