import 'package:flutter_background_geolocation/flutter_background_geolocation.dart' as bg;
import 'package:latlong/latlong.dart';

const double ALLOWED_DISTANCE_FROM_STATIONARY = 100; // in meters
const MAX_MINUTES_ALLOWED_OUTSIDE = 10;

Future<bool> verifyDidChallengeFail(DateTime challengeTimerStart, LatLng challengeStationaryPosition) async {
  final distanceCalculator = new Distance();
  final locations = await bg.BackgroundGeolocation.locations;
  bool isOutside = false;
  DateTime firstOutsideTime;
  for (var location in locations) {
    final time = DateTime.parse(location['timestamp']);
    if (time.isBefore(challengeTimerStart)) continue;
    final position = new LatLng(location['coords']['latitude'], location['coords']['longitude']);
    final distance = distanceCalculator.as(LengthUnit.Meter, challengeStationaryPosition, position);
    if (distance > ALLOWED_DISTANCE_FROM_STATIONARY) {
      if (!isOutside) firstOutsideTime = time;
      isOutside = true;
      if (time.difference(firstOutsideTime).inMinutes > MAX_MINUTES_ALLOWED_OUTSIDE) return true;
    } else {
      isOutside = false;
    }
  }
  return false;
}