import 'package:flutter_background_geolocation/flutter_background_geolocation.dart' as bg;
import 'package:latlong/latlong.dart';

const double ALLOWED_DISTANCE_FROM_STATIONARY = 100; // in meters
const MAX_MINUTES_ALLOWED_OUTSIDE = 10;
const FAILURE_LEFT_ZONE = 'left-zone';
const FAILURE_NO_LOCATION = 'no-location';

Future<String> verifyDidChallengeFail(DateTime challengeTimerStart, LatLng challengeStationaryPosition) async {
  // check failure because left quanatine zone  
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
      if (time.difference(firstOutsideTime).inMinutes > MAX_MINUTES_ALLOWED_OUTSIDE) {
        return FAILURE_LEFT_ZONE;
      }
    } else {
      isOutside = false;
    }
  }

  // check failure because location services not "always allow"
  final providerState = await bg.BackgroundGeolocation.providerState;
  if (!providerState.enabled) {
    return FAILURE_NO_LOCATION;
  }
  if (providerState.status != bg.ProviderChangeEvent.AUTHORIZATION_STATUS_ALWAYS) {
    return FAILURE_NO_LOCATION;
  }

  // no failure
  return null;
}