import 'package:flutter/material.dart';
import 'package:lockdown/failed.dart';
import 'package:lockdown/home.dart';
import 'package:lockdown/persistence.dart';
import 'package:lockdown/welcome.dart';
import 'package:latlong/latlong.dart';

Future<Null> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final persistentChallenge = await getPersistentChallenge();
  final persistentFailedMessage = await getPersistentFailedMessage();
  runApp(LockdownApp(persistentChallenge.item1, persistentChallenge.item2, persistentFailedMessage));
}

class LockdownApp extends StatelessWidget {
  final DateTime initChallengeTimerStart;
  final LatLng initChallengeStationaryPosition;
  final String initFailedMessage;

  LockdownApp(this.initChallengeTimerStart, this.initChallengeStationaryPosition, this.initFailedMessage);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Corona Challenge',
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
      ),
      home: (initFailedMessage != null) ? FailedPage(reason: initFailedMessage) : (
        (initChallengeStationaryPosition == null) ? 
          WelcomePage() : 
          HomePage(initChallengeTimerStart: initChallengeTimerStart, initChallengeStationaryPosition: initChallengeStationaryPosition)
      ),
    );
  }
}
