import 'package:photo_route/database_mgr/sqlite_db_handler.dart';

import '../common_modules/shared_preferences/shared_preferences_handler.dart';

class TripDescriptionDb extends SqliteDbHandler {

  TripDescriptionDb() : super();

  /// insert new row into trip_description table
  /// This table does not insert "end_time" parameter because this creates the new trip
  /// end_time will be entered when the trip is finished (modify table)
  ///
  /// Set shared preference indicating active trip. Set trip ID int it
  Future<int> createNewTrip(TripDescriptionModel trip) async {

    SharedPreferencesHandler pref = SharedPreferencesHandler();

    trip.id = await insertIntoTable('trip_description',
                                 'name, start_time',
                                 ''' '${trip.name}',
                                     datetime('now') ''');

    // this is async function, but should be ok
    pref.writeSharedPref('action_type', trip.id!);

    return trip!.id!;
  }

  /// Update trip data with "end_time" entry
  /// This marks the end of the trip and updates the row for particular
  /// trip in trip_description table
  ///
  /// Reset shared preference indicating inactive trip. Set 0 into it
  Future<int> finishTrip(TripDescriptionModel trip) async {
    SharedPreferencesHandler pref = SharedPreferencesHandler();
    // this is async function, but should be ok
    pref.writeSharedPref('action_type', 0);
    return await updateTable('trip_description',
                             '''end_time = datetime('now')''',
                             'id = ${trip.id}');
  }

  /// select all from trip_description table and return the data in a list
  /// of TripDescriptionModel type
  /// There is a possibility this method throws an error (database table empty) and
  /// it needs to be handled by the caller
  Future<List<TripDescriptionModel>> selectAllFromTripDescription() async {
    // get data from database
    var tripDescriptionData = await selectFromTable('trip_description', '*');
    List<TripDescriptionModel> tripDescList =  [];

    try {
      // iterate database data and populate list with it
      for (Map row in tripDescriptionData) {

        // each list entry is one row in database table
        tripDescList.add(TripDescriptionModel(row['id'],
            row['name'],
            DateTime.parse(row['start_time']),
            DateTime.parse(row['end_time'])));
      }
    } catch (e) {
      rethrow;
    }


    // return the list contaning database data
    return tripDescList;
  }

  /// select all from trip_description table and return the data in a list
  /// of TripDescriptionModel type
  /// There is a possibility this method throws an error (database table empty) and
  /// it needs to be handled by the caller
  Future<List<TripDescriptionModel>> getFinishedTrips() async {
    // get data from database
    var tripDescriptionData = await selectFromTableConditional('trip_description', '*', 'end_time IS NOT NULL');
    List<TripDescriptionModel> tripDescList =  [];

    try {
      // iterate database data and populate list with it
      for (Map row in tripDescriptionData) {

        // each list entry is one row in database table
        tripDescList.add(TripDescriptionModel(row['id'],
            row['name'],
            DateTime.parse(row['start_time']),
            DateTime.parse(row['end_time'])));
      }
    } catch (e) {
      rethrow;
    }


    // return the list containing database data
    return tripDescList;
  }

  /// delete all from trip_description table where IDs match
  Future<void> deleteFromTripDescriptionById(List<int> ids) async {
    String s = '';
    for(var el in ids) {
      s += '$el,';
    }
    s = s.substring(0, s.length - 1);
    await deleteRowsById('trip_description', s);
  }

  /// delete all from trip_description table
  Future<void> truncateTripDescription() async {
    await truncateTable('trip_description');
  }
}

class TripDescriptionModel {
  int? id;
  String? name;
  DateTime? start_time;
  DateTime? end_time;

  /*TripDescriptionModel(int id, String name, String start_time, String end_time) {
    this.id = id;
    this.name = name;
    this.start_time = start_time;
    this.end_time = end_time;
  }*/
  TripDescriptionModel(this.id, this.name, this.start_time, this.end_time);
  TripDescriptionModel.createTrip(this.name);
}