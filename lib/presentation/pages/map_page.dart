import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_webservice/places.dart';

class MapPage extends StatefulWidget {
  const MapPage({Key? key}) : super(key: key);

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final TextEditingController _searchController = TextEditingController();
  final GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: 'AIzaSyBTqXtB6zvGbF94g4S3EsCR_U-JbfaBbpI');
  List<Prediction> _suggestions = [];
  GoogleMapController? mapController;
  LatLng? _currentPosition;
  Marker? _marker;
  String? _address;

  Future<void> _getSuggestions(String query) async {
    if (query.isEmpty) {
      setState(() {
        _suggestions = [];
      });
      return;
    }
    final response = await _places.autocomplete(query);
    if (response.isOkay) {
      setState(() {
        _suggestions = response.predictions;
      });
    }
  }

  Future<void> _selectSuggestion(Prediction suggestion) async {
    final details = await _places.getDetailsByPlaceId(suggestion.placeId!);
    if (details.isOkay) {
      final location = details.result.geometry!.location;
      final LatLng newPosition = LatLng(location.lat, location.lng);
      mapController?.animateCamera(CameraUpdate.newLatLng(newPosition));
      setState(() {
        _marker =
          Marker(
            markerId: MarkerId(suggestion.placeId!),
            position: newPosition,
            infoWindow: InfoWindow(title: suggestion.description),
          );
        _currentPosition = newPosition;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }
  LatLng? _selectedPosition;
  String? _selectedAddress;

  Future<void> _onMapTap(LatLng position) async {
    String address = 'Dirección no disponible';
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        address = '${p.street}, ${p.locality}, ${p.country}';
      }
    } catch (_) {}
    setState(() {
      _marker != null ? {_marker!} : {};
      _marker =
        Marker(
          markerId: MarkerId('tap_${position.latitude}_${position.longitude}'),
          position: position,
          infoWindow: InfoWindow(title: 'Punto seleccionado', snippet: address),
        );
      _selectedPosition = position;
      _selectedAddress = address;
    });
  }

  Future<void> _determinePosition() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      final latLng = LatLng(position.latitude, position.longitude);
      setState(() {
        _currentPosition = latLng;
        _marker =
          Marker(
            markerId: const MarkerId('ubicacion_actual'),
            position: latLng,
            infoWindow: const InfoWindow(title: 'Mi ubicacion'),
          );
      });
      _getAddress(latLng);
    }
  }

  Future<void> _getAddress(LatLng latLng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(latLng.latitude, latLng.longitude);
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        setState(() {
          _address = '${p.street}, ${p.locality}, ${p.country}';
        });
      }
    } catch (_) {
      setState(() {
        _address = 'Dirección no disponible';
      });
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Geolocalización'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Buscar ubicación...',
                    suffixIcon: Icon(Icons.search),
                  ),
                  onChanged: _getSuggestions,
                ),
                if (_suggestions.isNotEmpty)
                  Container(
                    height: 200,
                    child: ListView.builder(
                      itemCount: _suggestions.length,
                      itemBuilder: (context, index) {
                        final suggestion = _suggestions[index];
                        return ListTile(
                          title: Text(suggestion.description ?? ''),
                          onTap: () => _selectSuggestion(suggestion),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: _currentPosition == null
                ? const Center(child: CircularProgressIndicator())
                : Stack(
                    children: [
                      GoogleMap(
                        onMapCreated: _onMapCreated,
                        initialCameraPosition: CameraPosition(
                          target: _currentPosition!,
                          zoom: 16.0,
                        ),
                        myLocationEnabled: true,
                        myLocationButtonEnabled: false,
                        markers: _marker != null ? {_marker!} : {},
                        onTap: _onMapTap,
                      ),
                      Builder(
                        builder: (context) {
                          final latLng = _selectedPosition ?? _currentPosition;
                          final address = _selectedAddress ?? _address;
                          if (latLng == null) return SizedBox.shrink();
                          return Positioned(
                            top: 16,
                            left: 16,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  color: Colors.black.withOpacity(0.3),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Lat: ${latLng.latitude.toStringAsFixed(6)}',
                                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        'Lng: ${latLng.longitude.toStringAsFixed(6)}',
                                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                      ),
                                      if (address != null)
                                        Text(
                                          address,
                                          style: const TextStyle(color: Colors.white),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      Positioned(
                        top: 16,
                        right: 16,
                        child: FloatingActionButton(
                          backgroundColor: Colors.white.withOpacity(0.8),
                          child: const Icon(Icons.my_location),
                          onPressed: () async {
                            _marker != null ? {_marker!} : {};
                            await _determinePosition();
                            if (_currentPosition != null && mapController != null) {
                              mapController!.animateCamera(
                                CameraUpdate.newLatLng(_currentPosition!),
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}