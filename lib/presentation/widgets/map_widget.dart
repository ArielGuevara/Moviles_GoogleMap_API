import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapWidget extends StatefulWidget {
  final LatLng? initialPosition;
  final LatLng? markerPosition;
  final double markerHue;
  final BitmapDescriptor? customMarkerIcon;
  final Function(LatLng)? onMapTap;
  final Function(GoogleMapController)? onMapCreated;

  const MapWidget({
    Key? key,
    this.initialPosition,
    this.markerPosition,
    this.markerHue = BitmapDescriptor.hueViolet,
    this.customMarkerIcon,
    this.onMapTap,
    this.onMapCreated,
  }) : super(key: key);

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  GoogleMapController? _controller;

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: widget.initialPosition ?? const LatLng(0.400000, -78.516667),
        zoom: 15,
      ),
      myLocationEnabled: true,
      myLocationButtonEnabled: false,
      markers: widget.markerPosition != null
          ? {
              Marker(
                markerId: const MarkerId('selected'),
                position: widget.markerPosition!,
                icon: BitmapDescriptor.defaultMarkerWithHue(widget.markerHue),
              ),
            }
          : {},
      onTap: widget.onMapTap,
      onMapCreated: (controller) {
        _controller = controller;
        if (widget.onMapCreated != null) {
          widget.onMapCreated!(controller);
        }
      },
    );
  }
}