import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../utils/connections.dart';

class MapService {
  String generateMapUrl(double lat, double lng) {
    final apiKey = mapKey;
    final url = 'https://maps.googleapis.com/maps/api/staticmap'
        '?center=$lat,$lng'
        '&zoom=14'
        '&size=600x400'
        '&markers=color:red|$lat,$lng'
        '&key=$apiKey';

    return url;
  }

  Future<LatLng> openMap(BuildContext context, Route route) async {
    final result = await Navigator.push(
      context,
      route,
    );

    if (result != null && result is LatLng) {
      return result;
    }
    return LatLng(41.99812940, 21.42543550);
  }
}
