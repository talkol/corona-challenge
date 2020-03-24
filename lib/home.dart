import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart' as bg;
import 'package:lockdown/failed.dart';
import 'package:lockdown/map.dart';
import 'package:lockdown/persistence.dart';
import 'package:lockdown/share.dart';
import 'package:lockdown/timer.dart';
import 'package:latlong/latlong.dart';
import 'package:lockdown/verify.dart';

class HomePage extends StatefulWidget {
  final DateTime initChallengeTimerStart;
  final LatLng initChallengeStationaryPosition;

  HomePage({Key key, this.initChallengeTimerStart, this.initChallengeStationaryPosition}) : super(key: key);
  
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  final GlobalKey screenshotContainer = new GlobalKey();
  TabController _tabController;
  String uiState; // 'out-map' , 'in-map' , 'in-timer'
  DateTime challengeTimerStart;
  LatLng challengeStationaryPosition;
  bool challengeStarting = false;
  bool shareStarting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final initialIndex = _initChallenge();
    _tabController = TabController(
        length: 2,
        initialIndex: initialIndex,
        vsync: this
    );
    _initBackgroundGeolocation();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkIfChallengeFailed();
    }
  }

  void _initBackgroundGeolocation() {
    bg.BackgroundGeolocation.ready(bg.Config(
        debug: false,
        logLevel: bg.Config.LOG_LEVEL_OFF, // bg.Config.LOG_LEVEL_VERBOSE,
        desiredAccuracy: bg.Config.DESIRED_ACCURACY_HIGH, // bg.Config.DESIRED_ACCURACY_MEDIUM,
        disableElasticity: true,
        distanceFilter: 50.0,
        stopOnTerminate: false,
        startOnBoot: true,
        maxDaysToPersist: 100,
        locationAuthorizationRequest: 'Always',
        locationAuthorizationAlert: {
          'titleWhenNotEnabled': 'Location services not enabled',
          'titleWhenOff': 'Location services not enabled',
          'instructions': 'To participate in the challenge you must enable "Always Allow" location tracking (very battery-efficient).',
          'cancelButton': 'Cancel',
          'settingsButton': 'Settings'
        }
    )).then((bg.State state) {
      if (!state.enabled) {
        bg.BackgroundGeolocation.start();
      }
    });
  }

  // returns initial tab index
  int _initChallenge() {
    challengeTimerStart = widget.initChallengeTimerStart;
    challengeStationaryPosition = widget.initChallengeStationaryPosition;
    if (challengeStationaryPosition == null) {
      uiState = 'out-map';
      return 0;
    }
    else {
      uiState = 'in-timer';
      return 1;
    }
  }

  Future<void> _startChallenge() async {
    setState(() {
      challengeStarting = true;
    });
    try {
      final location = await bg.BackgroundGeolocation.getCurrentPosition();
      final position = new LatLng(location.coords.latitude, location.coords.longitude);
      final time = new DateTime.now();
      await setPersistentChallenge(time, position);
      // enter lockdown
      setState(() {
        challengeTimerStart = time;
        challengeStationaryPosition = position;
        uiState = 'in-timer';
        challengeStarting = false;
      });
      _tabController.animateTo(1);
    } catch (e) {
      debugPrint('Error: $e');
      await Future.delayed(const Duration(seconds: 3));
      setState(() {
        challengeStarting = false;
      });
    }
  }

  Future<void> _endChallenge() async {
    await clearPersistentChallenge();
    // exit lockdown
    setState(() {
      challengeStationaryPosition = null;
      uiState = 'out-map';
    });
    _tabController.animateTo(0);
  }

  Future<void> _checkIfChallengeFailed() async {
    if (challengeStationaryPosition == null) return;
    final failure = await verifyDidChallengeFail(challengeTimerStart, challengeStationaryPosition);
    if (failure != null) {
      await setPersistentFailedMessage(failure);
      await clearPersistentChallenge();
      Route route = MaterialPageRoute(builder: (context) => FailedPage(reason: failure));
      Navigator.pushReplacement(context, route);
    }
  }

  Future<void> _share() async {
    setState(() {
      shareStarting = true;
    });
    try {
      await shareProgressImage(screenshotContainer.currentContext.findRenderObject());
    } catch (e) {
      debugPrint('Error: $e');
    }
    setState(() {
      shareStarting = false;
    });
  }

  Future<void> _buttonPressed(String buttonSide) async {
    if (_tabController.indexIsChanging) return;
    if (challengeStarting) return;
    if (shareStarting) return;

    if (uiState == 'out-map') {
      await _startChallenge();
    } else if (uiState == 'in-map') {
      if (buttonSide == 'left') {
        await _endChallenge();
      } else {
        // timer
        setState(() {
          uiState = 'in-timer';
        });
        _tabController.animateTo(1);
      }
    } else if (uiState == 'in-timer') {
      if (buttonSide == 'left') {
        // map
        setState(() {
          uiState = 'in-map';
        });
        _tabController.animateTo(0);
      } else {
        // share
        await _share();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: (uiState == 'out-map') ? Text('Start the challenge!') : Text("I'm in self-quarantine!"),
      ),
      body: TabBarView(
        controller: _tabController,
          children: [
            MapPage(stationaryPosition: challengeStationaryPosition),
            RepaintBoundary(
              key: screenshotContainer,
              child: TimerPage(startTime: challengeTimerStart)
            )
          ],
        physics: new NeverScrollableScrollPhysics()
      ),
      floatingActionButtonLocation:
        FloatingActionButtonLocation.centerDocked,
          floatingActionButton: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisAlignment: (uiState == 'out-map') ? MainAxisAlignment.center : MainAxisAlignment.spaceBetween,
              children: <Widget>[
                if (uiState != 'in-timer')
                  FloatingActionButton.extended(
                    heroTag: 'btn1',
                    onPressed: () async => await _buttonPressed('left'),
                    label: (uiState == 'out-map') ? 
                    ((challengeStarting) ? Text('Getting Location...') : Text('Enter Self-Quarantine'))
                    : Text('Quit Challenge')
                  )
                else 
                  FloatingActionButton(
                    heroTag: 'btn1',
                    onPressed: () async => await _buttonPressed('left'),
                    tooltip: 'My Location',
                    child: Icon(Icons.my_location),
                  ),
                if (uiState != 'out-map') FloatingActionButton(
                    heroTag: 'btn2',
                    onPressed: () async => await _buttonPressed('right'),
                    tooltip: (uiState == 'in-map') ? 'Timelapse' : 'Share',
                    child: (uiState == 'in-map') ? Icon(Icons.timelapse) : Icon(Icons.share)
                  ),
              ],
            ),
          )
    );
  }
}