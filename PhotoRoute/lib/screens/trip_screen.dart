import 'package:flutter/material.dart';
import 'package:photo_route/common_modules/callbacks/trip_actions.dart';

import '../database_mgr/trip_descripton_db.dart';

/// This screen shows the ongoing trip. It consists of
/// a google map and "finish trip" button at the bottom
class TripScreen extends StatefulWidget {
  late TripDescriptionModel _tripDescriptionModel;

  TripScreen(this._tripDescriptionModel);

  @override
  State<StatefulWidget> createState() => _TripScreen(_tripDescriptionModel);
}

class _TripScreen extends State<TripScreen> {
  late TripDescriptionModel _tripDescModel;

  _TripScreen(this._tripDescModel);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Ongoing trip")
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
                onPressed: () {
                  TripActions tActions = TripActions();
                  tActions.endTrip(_tripDescModel, context);
                }, child: const Text('End the trip'))
          ],
        ),
      ),
    );
  }
}