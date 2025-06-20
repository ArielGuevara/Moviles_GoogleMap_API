import 'package:flutter/material.dart';
import '../widgets/search_box.dart';
import '../widgets/location_info_card.dart';
import '../widgets/map_widget.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import '../../services/location_service.dart';
import '../../services/places_service.dart';
import 'package:geocoding/geocoding.dart';

class MapPage extends StatefulWidget {
  const MapPage({Key? key}) : super(key: key);

  @override
  State<MapPage> createState() => _MapPageState();
}


class _MapPageState extends State<MapPage> {
  final _searchController = TextEditingController();
  final _locationService = LocationService();
  final _placesService = PlacesService('AIzaSyBTqXtB6zvGbF94g4S3EsCR_U-JbfaBbpI');

  LatLng? _selectedPosition;
  String? _address;
  GoogleMapController? _mapController;
  BitmapDescriptor? _customIcon;

  @override
  void initState() {
    super.initState();
    // Espera a que el mapa esté creado antes de mover la cámara
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _goToMyLocation();
    });
  }


  Future<List<String>> _getSuggestions(String query) async {
    final predictions = await _placesService.searchPlaces(query);
    return predictions.map((p) => p.description ?? '').toList();
  }

  Future<void> _onSuggestionSelected(String suggestion) async {
    final predictions = await _placesService.searchPlaces(suggestion);
    if (predictions.isNotEmpty) {
      final place = predictions.first;
      final details = await _placesService.getPlaceDetails(place.placeId!);
      if (details != null) {
        final location = details.geometry!.location;
        final LatLng newPosition = LatLng(location.lat, location.lng);
        _mapController?.animateCamera(CameraUpdate.newLatLng(newPosition));
        setState(() {
          _selectedPosition = newPosition;
          _address = place.description;
          _searchController.clear();
        });
      }
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

  void _onMapTap(LatLng position) {
    setState(() {
      _selectedPosition = position;
      _address = null;
    });
    _getAddress(position);
  }

  Future<void> _goToMyLocation() async {
    final pos = await _locationService.getCurrentLocation();
    if (pos != null) {
      final latLng = LatLng(pos.latitude, pos.longitude);
      setState(() {
        _selectedPosition = latLng;
        _address = null;
      });
      _mapController?.animateCamera(CameraUpdate.newLatLng(latLng));
      _getAddress(latLng);
    }
  }

  @override
  Widget build(BuildContext context) {
    // _goToMyLocation();
    return Scaffold(
      extendBodyBehindAppBar: true,

      body: Stack(
        children: [
          // Mapa de fondo
          MapWidget(
            markerPosition: _selectedPosition,
            customMarkerIcon: _customIcon,
            onMapTap: _onMapTap,
            onMapCreated: (controller) {
              _mapController = controller;
            },
          ),
          // Buscador flotante
          Positioned(
            top: MediaQuery.of(context).padding.top,
            left: 20,
            right: 20,
            child: Material(
              elevation: 8,
              borderRadius: BorderRadius.circular(16),
              child: SearchBox(
                controller: _searchController,
                suggestionsCallback: _getSuggestions,
                onSuggestionSelected: _onSuggestionSelected,
              ),
            ),
          ),
          // Tarjeta de información de ubicación
          if (_selectedPosition != null)
            LocationInfoCard(
              latitude: _selectedPosition!.latitude,
              longitude: _selectedPosition!.longitude,
              address: _address,
            ),
          // Botón de ubicación flotante
          Positioned(
            top: 140,
            right: 24,
            child: FloatingActionButton(
              backgroundColor: Colors.white,
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.my_location, color: Colors.deepPurple),
              onPressed: _goToMyLocation,
            ),
          ),
        ],
      ),
    );
  }
}