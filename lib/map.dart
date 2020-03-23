import 'package:flutter/material.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart' as bg;
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';
import 'package:lockdown/verify.dart';

const String MAP_TOKEN = 'pk.eyJ1IjoiY2hyaXN0b2NyYWN5IiwiYSI6ImVmM2Y2MDA1NzIyMjg1NTdhZGFlYmZiY2QyODVjNzI2In0.htaacx3ZhE5uAWN86-YNAQ';
const MAP_ZOOM = 17.5;

class MapPage extends StatefulWidget {
  final LatLng stationaryPosition;

  MapPage({Key key, this.stationaryPosition}) : super(key: key);
  
  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> with AutomaticKeepAliveClientMixin<MapPage> {
  List<CircleMarker> _stationaryMarker = [];
  List<CircleMarker> _currentPosition = [];
  LatLng _center = new LatLng(51.5, -0.09);
  MapController _mapController;
  MapOptions _mapOptions;

  @override
  bool get wantKeepAlive { return true; }

  @override
  void initState() {
    super.initState();
    _mapOptions = new MapOptions(
      onPositionChanged: _onPositionChanged,
      center: _center,
      zoom: MAP_ZOOM,
      maxZoom: MAP_ZOOM
    );
    _mapController = new MapController();
    bg.BackgroundGeolocation.onLocation(_onLocation);
    bg.BackgroundGeolocation.onMotionChange(_onMotionChange);
    bg.BackgroundGeolocation.getCurrentPosition();
  }

  void _onLocation(bg.Location location) {
    LatLng ll = new LatLng(location.coords.latitude, location.coords.longitude);
    _mapController.move(ll, _mapController.zoom);
    _updateCurrentPositionMarker(ll);
    _updateStationaryPositionMarker(ll);
  }

  void _onMotionChange(bg.Location location) async {
    LatLng ll = new LatLng(location.coords.latitude, location.coords.longitude);
    _mapController.move(ll, _mapController.zoom);
    _updateCurrentPositionMarker(ll);
    _updateStationaryPositionMarker(ll);
  }

  void _onPositionChanged(MapPosition pos, bool hasGesture) {
    _mapOptions.crs.scale(_mapController.zoom);
  }

  void _updateCurrentPositionMarker(LatLng ll) {
    _currentPosition.clear();
    _currentPosition.add(CircleMarker(
        point: ll,
        color: Colors.white,
        radius: 10
    ));
    _currentPosition.add(CircleMarker(
        point: ll,
        color: Colors.blue,
        radius: 7
    ));
  }

  void _updateStationaryPositionMarker(LatLng currentPosition) {
    _stationaryMarker.clear();
    _stationaryMarker.add(CircleMarker(
        point: (widget.stationaryPosition != null) ? widget.stationaryPosition : currentPosition,
        color: Color.fromRGBO(0xff, 0x57, 0x22, 0.5),
        useRadiusInMeter: true,
        radius: ALLOWED_DISTANCE_FROM_STATIONARY
    ));
  }

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: _mapController,
      options: _mapOptions,
      layers: [
        new TileLayerOptions(
          urlTemplate: "https://api.tiles.mapbox.com/v4/{id}/{z}/{x}/{y}@2x.png?access_token={accessToken}",
          additionalOptions: {
            'accessToken': MAP_TOKEN,
            'id': 'mapbox.streets',
          },
        ),
        new CircleLayerOptions(circles: _stationaryMarker),
        new CircleLayerOptions(circles: _currentPosition),
      ]
    );
  }
}