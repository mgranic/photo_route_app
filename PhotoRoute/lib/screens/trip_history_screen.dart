import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_route/screens/trip_gallery_screen.dart';
import 'package:http/http.dart';
import '../database_mgr/trip_descripton_db.dart';

class TripHistoryScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _TripHistoryScreen();
}

class _TripHistoryScreen extends State<TripHistoryScreen> {

  late Future<List<TripDescriptionModel>> _tripHistory;
  static bool _tripSelectMode = false;
  static Map<int?, bool> _selectList = Map<int, bool>();

  _TripHistoryScreen() {
    TripDescriptionDb dbHandler = TripDescriptionDb();
    _tripHistory = dbHandler.getFinishedTrips();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Trip History"),
        actions: _constructActionMenu()
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            FutureBuilder(future: _tripHistory, builder: _tripHistoryListConstructor)
          ],
        ),
      ),
    );
  }

  /// Construct trip history list that will be displayed on the screen
  Widget _tripHistoryListConstructor(BuildContext context, AsyncSnapshot<List<TripDescriptionModel>> snapshot) {

    if(snapshot.hasData != true || snapshot.data == null) {
      return Text('Fetching data');
    }

    return ListView.builder(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemCount: snapshot.data!.length,
        itemBuilder: (BuildContext ctx, int index) {

          // add items to list only if you are not in "select mode"
          // otherwise this list has to be the same in order to change state (color)
          // of selected item
          if (_tripSelectMode != true) {
            _selectList[snapshot.data![index]!.id] = false;
          }
          return GestureDetector(
            child:
            ListTile(
              selected: _selectList[snapshot.data![index]!.id]!,
              key: Key('$index-${snapshot.data![index]!.id}'),
              title: Text('${snapshot.data![index]!.name}'),
              subtitle: Text("trip description"),
              tileColor: _selectList[snapshot.data![index]!.id]! ? Colors.blueGrey : Colors.white,
              textColor: Colors.black,
              selectedColor: Colors.blue,
            ),
            onTap: () {
              _tripTapHandler(
                  snapshot.data![index]!.id,
                  snapshot.data![index]!.start_time,
                  snapshot.data![index]!.end_time
              );
            },
            onLongPress: () {
              _tripLongPressHandler(index,
                  snapshot.data![index]!.name,
                  snapshot.data![index]!.id,
                  snapshot.data![index]!.start_time,
                  snapshot.data![index]!.end_time);
            },
          );
        });
  }

  /// callback executed when you tap on a trip in the "Trip History" list
  /// id is trip ID, start is trip start timestamp, end is trip end timestamp
  /// Once you tap on trip it should take you to the "Trip Details" screen
  Future<void> _tripTapHandler(int? dbId, DateTime? start, DateTime? end) async {

    // if selection mode is enabled every tap on list item will add the list to the selection
    if (_tripSelectMode == true) {
      setState(() {
        // invert selection flag (true or false)
        _selectList[dbId] = !_selectList[dbId]! ;
      });
    } else {

      // ask for permissions to access storage (gallery)
      final permitted = await PhotoManager.requestPermission();
      // if permission is rejected, do not navigate to "details" screen
      if (!permitted) return;

      // TODO: Navigate to trip_details screen
      // for now navigate to trip_gallery_screen
      Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => TripGalleryScreen(dbId!, start!, end!))
      );
    }
  }

  /// callback executed when you tap and hold on a trip in the "Trip History" list
  /// id is trip ID and name is trip name. index is trip list index
  /// start is time of the trip start
  /// end is time of the trip end
  /// Once you tap and hold the trip menu with "select more", "delete" and
  /// "upload" should appear
  void _tripLongPressHandler(int index, String? name, int? dbId, DateTime? start, DateTime? end) {
    _fetchAssets(start, end);

    setState(() {
      // invert selection flag (true or false)
      _selectList[dbId] = !_selectList[dbId]!;
      // enter selection mode and show delete/cancel menu
      _tripSelectMode = true;
    });
  }

  /// delete selected trips from the database and from the screen (widget list)
  void _deleteTripHandler() {
    print('delete trip handler');
    List<int> ids = <int>[];
    TripDescriptionDb dbHandler = TripDescriptionDb();
    _selectList.forEach((k,v) {
      if (_selectList[k] == true) {
        // deselect
        _selectList[k] = false;
        ids.add(k!);
        dbHandler.deleteFromTripDescriptionById(ids);
      }
    });

    setState(() {
      _tripHistory = dbHandler.getFinishedTrips();
      _tripSelectMode = false;
    });
  }

  /// Upload selected trips to the server
  /// // ids is list containing all trip IDs from DB
  void _uploadSelectionHandler(List<int> ids) {
    //final String url = 'https://localhost:7081/WeatherForecast/testPostRequest?param=mob_poslao'; // on device
    //final String url = 'https://localhost:7081/WeatherForecast/testPostRequestBody';
    final String url = 'https://192.168.2.146:7081/DatabaseManager/UploadImage'; //'https://192.168.1.80:7081/DatabaseManager/UploadImage';
    //final String url = 'http://10.0.2.2:7081/WeatherForecast/testPostRequest'; // on emulator
    //final String url = 'https://10.0.2.2:4040/';
    //final String url = 'https://localhost:8081/';
    post(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json'
      },
      body: jsonEncode(<String, String>{
        'name': 'slika sa mobitela',
      }),
    ).then((response) {
      print(response?.body);
    }).catchError((err) {
      //print('Server communication error: ${err.toString()}');
    })
        .timeout(Duration(seconds: 2), onTimeout: () {
      //print(' HTTP request timeout');
    });

    //post(Uri.parse('${url}isAlive'), body: {"param1": 'parm1'});
  }

  ///  function that fetches the assets, and updates the state
  _fetchAssets(DateTime? tripStart, DateTime? tripEnd) async {
    final String url = 'https://192.168.2.146:7081/DatabaseManager/UploadImage2';
    MultipartRequest request;
    Uri uri = Uri.parse(url);
    // Set onlyAll to true, to fetch only the 'Recent' album
    // which contains all the photos/videos in the storage
    final albums = await PhotoManager.getAssetPathList(onlyAll: true);
    final recentAlbum = albums.first;

    // Now that we got the album, fetch all the assets it contains
    final recentAssets = await recentAlbum.getAssetListRange(
      start: 0, // start at index 0
      end: 200, // get 200 images
      //end: 1000000, // end at a very big index (to get all the assets)
    );


      for (var i = 0; i < recentAssets.length; i++) {
        if (recentAssets[i].createDtSecond! <= ((tripEnd!.millisecondsSinceEpoch/1000).ceil() + (tripEnd!.timeZoneOffset.inMilliseconds/1000).ceil()) &&
            recentAssets[i].createDtSecond! >= ((tripStart!.millisecondsSinceEpoch/1000).floor() + (tripStart!.timeZoneOffset.inMilliseconds/1000).floor())) {
          // TODO: mategr use this file path to send the image to the server as described here:
          // https://medium.com/geekculture/flutter-how-to-upload-photos-taken-from-the-camera-and-other-files-via-http-386d04218e02
          recentAssets[i].file.then((imageFile) async {
            print('************** ${imageFile?.path} ************* ${imageFile?.uri} **********');
            request = MultipartRequest('POST', uri);
            request.files.add(await MultipartFile.fromPath('files', imageFile!.path));
            StreamedResponse response = await request.send();
          });



          //http.StreamedResponse response = await request.send();
          break;
        }
      }
  }

  /// deselect all selected trips from the list and hide action menu
  /// (delete and cancel buttons in the appbar)
  void _cancelSelectionHandler() {
    setState(() {
      _selectList.forEach((k,v) => _selectList[k] = false);
      _tripSelectMode = false;
    });
  }

  List<Widget> _constructActionMenu() {
    List<Widget> actionMenu = <Widget>[];

    if (_tripSelectMode == true) {
      actionMenu.add(
          IconButton (
            icon: Icon(Icons.delete),
            onPressed: _deleteTripHandler,
          )
      );
      actionMenu.add(
        IconButton(
          icon: Icon(Icons.upload),
          onPressed: () {
            List<int> ids = <int>[];
            _selectList.forEach((k,v) {
              if (_selectList[k] == true) {
                // deselect
                _selectList[k] = false;
                ids.add(k!);
              }
            });
            setState(() {
              _tripSelectMode = false;
            });

            _uploadSelectionHandler(ids);
          }
        )
      );
      actionMenu.add(
          IconButton (
            icon: Icon(Icons.cancel),
            onPressed: _cancelSelectionHandler,
          )
      );
    }

    return actionMenu;
  }

}