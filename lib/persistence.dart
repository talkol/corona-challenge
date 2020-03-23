import 'package:tuple/tuple.dart';
import 'package:latlong/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

const PERSISTENCE_KEY_TIMESTAMP = 'timestamp';
const PERSISTENCE_KEY_LATITUDE = 'latitude';
const PERSISTENCE_KEY_LONGITUDE = 'longitude';
const PERSISTENCE_KEY_FAILED_MSG = 'failedmsg';

Future<Tuple2<DateTime, LatLng>> getPersistentChallenge() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  if (!prefs.containsKey(PERSISTENCE_KEY_TIMESTAMP) ||
      !prefs.containsKey(PERSISTENCE_KEY_LATITUDE) ||
      !prefs.containsKey(PERSISTENCE_KEY_LONGITUDE)) {
        return new Tuple2(null, null);
      }
  final timestamp = prefs.getInt(PERSISTENCE_KEY_TIMESTAMP);
  final latitude = prefs.getDouble(PERSISTENCE_KEY_LATITUDE);
  final longitude = prefs.getDouble(PERSISTENCE_KEY_LONGITUDE);
  return new Tuple2(
    DateTime.fromMillisecondsSinceEpoch(timestamp), 
    new LatLng(latitude, longitude)
  );
}

Future<void> setPersistentChallenge(DateTime time, LatLng position) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setInt(PERSISTENCE_KEY_TIMESTAMP, time.millisecondsSinceEpoch);
  await prefs.setDouble(PERSISTENCE_KEY_LATITUDE, position.latitude);
  await prefs.setDouble(PERSISTENCE_KEY_LONGITUDE, position.longitude);
}

Future<void> clearPersistentChallenge() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.remove(PERSISTENCE_KEY_TIMESTAMP);
  await prefs.remove(PERSISTENCE_KEY_LATITUDE);
  await prefs.remove(PERSISTENCE_KEY_LONGITUDE);
}

Future<bool> getPersistentFailedMessage() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getBool(PERSISTENCE_KEY_FAILED_MSG) ?? false;
}

Future<void> setPersistentFailedMessage() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setBool(PERSISTENCE_KEY_FAILED_MSG, true);
}

Future<void> clearPersistentFailedMessage() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.remove(PERSISTENCE_KEY_FAILED_MSG);
}