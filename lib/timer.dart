import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_circular_chart/flutter_circular_chart.dart';

class TimerPage extends StatefulWidget {
  final DateTime startTime;

  TimerPage({Key key, @required this.startTime}) : super(key: key);
  
  @override
  _TimerPageState createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage> with AutomaticKeepAliveClientMixin<TimerPage> {
  final GlobalKey<AnimatedCircularChartState> _chartKey = new GlobalKey<AnimatedCircularChartState>();
  String daysStr;
  String timeStr;
  String percentStr;
  String nextGoalStr;
  List<CircularStackEntry> chartData;
  Timer timer;

  @override
  bool get wantKeepAlive { return true; }

  @override
  void initState() {
    super.initState();
    timeStr = _generateTimerStr(0,0,0);
    chartData = _generateTimerChartData(0,0,0);
    timer = new Timer.periodic(const Duration(milliseconds:250), (Timer t) => _timerTick());
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  void _timerTick() {
    setState(() {
      final now = new DateTime.now();
      var duration = now.difference(widget.startTime);
      var h = duration.inHours % 24;
      var m = duration.inMinutes % 60;
      var s = duration.inSeconds % 60;
      daysStr = duration.inDays.toString();
      int nextGoalDays = ((duration.inDays.toDouble() / 7).floor() + 1) * 7;
      double percent = 100 * duration.inSeconds.toDouble() / Duration(days: nextGoalDays).inSeconds.toDouble();
      percentStr = percent.toStringAsFixed(1);
      nextGoalStr = nextGoalDays.toString();
      timeStr = _generateTimerStr(h,m,s);
      chartData = _generateTimerChartData(h,m,s);
      _chartKey.currentState.updateData(chartData);
    });
  }

  String _generateTimerStr(int h, int m, int s) {
    return '${h.toString().padLeft(2,'0')}:${m.toString().padLeft(2,'0')}:${s.toString().padLeft(2,'0')}';
  }

  List<CircularStackEntry> _generateTimerChartData(int h, int m, int s) {
    int stackCount = 3;
    List<CircularStackEntry> data = new List.generate(stackCount, (i) {
      int segCount = 2;
      List<CircularSegmentEntry> segments =  new List.generate(segCount, (j) {
        int value = s;
        int total = 60;
        if (i == 1) { value = m; total = 60; }
        if (i == 2) { value = h; total = 24; }
        if (j == 1) { value = total - value; }
        Color color;
        if (i == 0) color = (j == 0) ? Colors.teal[300] : Colors.teal[100];
        if (i == 1) color = (j == 0) ? Colors.cyan[800] : Colors.cyan[100];
        if (i == 2) color = (j == 0) ? Colors.deepOrange[400] : Colors.deepOrange[100];
        return new CircularSegmentEntry(value.toDouble(), color);
      });
      return new CircularStackEntry(segments);
    });

    return data;
  }

  @override
  Widget build(BuildContext context) {
    final _size = MediaQuery.of(context).size.width * 1.1;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            '$daysStr  DAYS',
            style: new TextStyle(
              color: Colors.grey[800],
              fontWeight: FontWeight.normal,
              fontSize: 48.0,
            ),
          ),
          new AnimatedCircularChart(
            key: _chartKey,
            size: Size(_size, _size),
            initialChartData: chartData,
            chartType: CircularChartType.Radial,
            edgeStyle: SegmentEdgeStyle.round,
            holeLabel: timeStr,
            labelStyle: new TextStyle(
              color: Colors.grey[700],
              fontWeight: FontWeight.normal,
              fontSize: 34.0,
            ),
          ),
          Text(
            '$percentStr% to $nextGoalStr day goal',
            style: new TextStyle(
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
              fontSize: 18.0,
            ),
          ),
        ],
      ),
    );
  }
}
