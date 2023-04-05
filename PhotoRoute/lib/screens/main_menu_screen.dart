
import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:photo_route/common_modules/shared_preferences/shared_preferences_handler.dart';
import 'package:photo_route/database_mgr/trip_descripton_db.dart';
import 'package:photo_route/screens/trip_history_screen.dart';
import '../common_modules/callbacks/trip_actions.dart';
import 'new_trip_screen.dart';

class MotoRoute extends StatelessWidget {
  const MotoRoute({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Moto Route',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomeScreen(title: 'Moto Route Home Page'),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key, required this.title}) : super(key: key);

  final String title;
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  late Future<ElevatedButton> _button;
  /*_HomeScreenState() {
    _button = _renderActionButton();
  }*/

  @override
  Widget build(BuildContext context) {
    _button = _renderActionButton();
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            //ElevatedButton(onPressed: _navigateNewTripScreen, child: Text('New trip')),
            FutureBuilder(future: _button, builder: _newButtonConstructor),
            ElevatedButton(onPressed: _navigateTripHistoryScreen, child: Text('Trip history'))
          ],
        ),
      ),
    );
  }

  /// This function is executed when user presses "New trip" button and it will
  /// take you to the "New trip" screen
  void _navigateNewTripScreen() {
    Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => NewTripScreen())
    ).then(_onGoBack);
  }

  /// This function is executed when user presses "Trip history" button and it will
  /// take you to the "Trip history" screen
  void _navigateTripHistoryScreen() {
    Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => TripHistoryScreen())).then(_onGoBack);
  }



  /// If shared preference is null or 0 it means trip was NOT started so we should
  /// show "New trip" button
  /// If shared preference is NOT null or 0 it means trip was started so we should
  /// show "End trip" button. In this case shared preference has value of trip ID
  /// in database
  Future<ElevatedButton> _renderActionButton() async {
    SharedPreferencesHandler shph = SharedPreferencesHandler();
    int actionType = await shph.checkActionType();

    if (actionType == 0) {
      return ElevatedButton(onPressed: _navigateNewTripScreen, child: Text('New trip'));
    } else {
      TripActions tActions = TripActions();
      TripDescriptionModel tripDescModel = TripDescriptionModel(actionType, '', null, null);

      return ElevatedButton(onPressed: () {
        tActions.endTrip(tripDescModel, context);
      }, child: Text('End trip'));
    }

  }

  /// render propper button on the screen
  Widget _newButtonConstructor(BuildContext context, AsyncSnapshot<ElevatedButton> snapshot) {
    if (snapshot.hasData != true || snapshot.data == null) {
      return Text('Checking for active trips');
    }

    return ElevatedButton(onPressed: snapshot.data?.onPressed!,
        child: snapshot.data?.child!);
  }


  /// This function is called when you navigate back to main_menu from some
  /// other screen
  /// It forces "New trip" and "End trip" button rerender
  FutureOr _onGoBack(dynamic value) {
    setState(() {});
  }
}