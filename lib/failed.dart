import 'package:flutter/material.dart';
import 'package:lockdown/home.dart';
import 'package:lockdown/persistence.dart';
import 'package:lockdown/verify.dart';

class FailedPage extends StatefulWidget {
  final String reason; // 'left-zone' , 'no-location'

  FailedPage({Key key, @required this.reason}) : super(key: key);

  @override
  _FailedPageState createState() => _FailedPageState();
}

class _FailedPageState extends State<FailedPage> {

  Future<void> _moveToNextPage() async {
    await clearPersistentFailedMessage();
    Route route = MaterialPageRoute(builder: (context) => HomePage());
    Navigator.pushReplacement(context, route);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Oh no!'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Flexible(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(50.0, 0, 50.0, 0),
                    child: Image(image: AssetImage('assets/logo.png'))
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20.0, 0, 20.0, 0),
                    child: Image(image: AssetImage('assets/sofa-fail.png'))
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(50.0, 0, 50.0, 70.0),
                    child: Text(
                      (widget.reason == FAILURE_LEFT_ZONE) ? 'It seems you left your home area for a while.. Challenge failed!' :
                      (widget.reason == FAILURE_NO_LOCATION) ? 'It seems location tracking is not set to "Always Allow".. Challenge failed!' :
                      'Unknown failure.',
                      style: new TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0,
                      ),
                      textAlign: TextAlign.center,
                    )
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 30.0,
            child: Container()
          ),
        ]
      ),
      floatingActionButtonLocation:
        FloatingActionButtonLocation.centerDocked,
        floatingActionButton: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
                FloatingActionButton.extended(
                  onPressed: _moveToNextPage,
                  label: Text('Retry Challenge')
                )
            ],
          ),
        )
    );
  }
}