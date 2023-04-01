import 'package:flutter/material.dart';
import 'package:photo_route/database_mgr/trip_descripton_db.dart';
import 'package:photo_route/screens/main_menu_screen.dart';
import 'package:photo_route/screens/trip_screen.dart';

import '../common_modules/shared_preferences/shared_preferences_handler.dart';

class NewTripScreen extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => _NewTripScreen();

}

class _NewTripScreen extends State<NewTripScreen> {
  bool _tripNameInvalid = false;

  TextEditingController textController = TextEditingController();

  /*_NewTripScreen() {
    Navigator.pop(context,true);
  }*/

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text("Create new trip"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              obscureText: false,
              controller: textController,
              decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Trip name',
                  errorText: _tripNameInvalid ? 'Enter trip name' : null
              ),),
            ElevatedButton(
                onPressed: _createNewTrip, child: const Text('Start the trip'))
          ],
        ),
      ),
    );
  }

  /// Function that takes the text written in text field "Trip name" and creates
  /// database entry with that name. This database entry will be used to store the
  /// data about the trip
  /// Function also navigates user to the "Trip" screen which show the active trip
  void _createNewTrip() async {
    // make sure trip name is not empty or null
    if (textController.text.isEmpty) {
      setState(() {
        _tripNameInvalid = true;
      });
      return;
    }
    setState(() {
      _tripNameInvalid = false;
    });

    TripDescriptionModel tripDesc = TripDescriptionModel.createTrip(textController.text);
    TripDescriptionDb tripDescriptionDb = TripDescriptionDb();

    tripDesc.id = await tripDescriptionDb.createNewTrip(tripDesc);

    Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => TripScreen(tripDesc))
    );

  }

}
