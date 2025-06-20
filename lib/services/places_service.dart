// lib/services/places_service.dart
    import 'package:google_maps_webservice/places.dart';

    class PlacesService {
      final String apiKey;
      final GoogleMapsPlaces _places;

      PlacesService(this.apiKey) : _places = GoogleMapsPlaces(apiKey: apiKey);

      /// Busca lugares por texto.
      Future<List<Prediction>> searchPlaces(String query) async {
        final response = await _places.autocomplete(query, language: 'es');
        if (response.isOkay) {
          return response.predictions;
        }
        return [];
      }

      /// Obtiene detalles de un lugar por su placeId.
      Future<PlaceDetails?> getPlaceDetails(String placeId) async {
        final response = await _places.getDetailsByPlaceId(placeId, language: 'es');
        if (response.isOkay) {
          return response.result;
        }
        return null;
      }
    }