import 'package:flutter/material.dart';
import 'package:lockdown/home.dart';

class WelcomePage extends StatefulWidget {
  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {

  void _moveToNextPage() {
    Route route = MaterialPageRoute(builder: (context) => HomePage());
    Navigator.pushReplacement(context, route);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome'),
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
                    child: Image(image: AssetImage('assets/sofa.png'))
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(50.0, 0, 50.0, 70.0),
                    child: Text(
                      'Protect yourself by staying home. How long can you last?',
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
            child: Padding(
              padding: const EdgeInsets.fromLTRB(80.0, 0, 80.0, 18.0),
              child: Image(image: AssetImage('assets/credit.png'))
            ),
          ),
        ]
      ),
      floatingActionButtonLocation:
        FloatingActionButtonLocation.centerDocked,
        floatingActionButton: Padding(
          padding: const EdgeInsets.all(55.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
                FloatingActionButton.extended(
                  onPressed: _moveToNextPage,
                  label: Text('Show My Location')
                )
            ],
          ),
        )
    );
  }
}