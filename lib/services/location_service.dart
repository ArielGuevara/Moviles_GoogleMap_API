import 'package:geolocator/geolocator.dart';

    class LocationService {
      /// Solicita permisos de ubicación al usuario.
      Future<bool> requestPermission() async {
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }
        return permission == LocationPermission.always ||
            permission == LocationPermission.whileInUse;
      }

      /// Obtiene la ubicación actual del dispositivo.
      Future<Position?> getCurrentLocation() async {
        bool hasPermission = await requestPermission();
        if (!hasPermission) return null;
        return await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
      }

      /// Devuelve un stream de posiciones para ubicación en tiempo real.
      Stream<Position>? getPositionStream() {
        return Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 10,
          ),
        );
      }
    }