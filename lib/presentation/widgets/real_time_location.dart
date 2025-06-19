import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class RealTimeLocationPage extends StatefulWidget {
  @override
  _RealTimeLocationPageState createState() => _RealTimeLocationPageState();
}

class _RealTimeLocationPageState extends State<RealTimeLocationPage> {
  Stream<Position>? _positionStream;
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    _initLocationStream();
  }

  Future<void> _initLocationStream() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
      setState(() {
        _positionStream = Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 10, // metros
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Geolocalización en tiempo real')),
      body: _positionStream == null
          ? Center(child: Text('Permiso no concedido'))
          : StreamBuilder<Position>(
              stream: _positionStream,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  _currentPosition = snapshot.data;
                  return Center(
                    child: Text(
                      'Lat: ${_currentPosition!.latitude}, Lng: ${_currentPosition!.longitude}',
                      style: TextStyle(fontSize: 20),
                    ),
                  );
                }
                return Center(child: CircularProgressIndicator());
              },
            ),
    );
  }
}