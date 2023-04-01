import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesHandler {

  /// If shared preference is null or 0 it means trip was NOT started
  /// If shared preference is NOT null or 0 it means trip was started.
  /// In this case shared preference has value of trip ID in database
  Future<int> checkActionType() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? action = prefs.getInt('action_type');

    if(action == null || action == 0) {
      // render new trip button
      return 0;
    } else {
      // render end trip button
      return action;
    }
  }

  /// Write a value "value" into a shared preference named "prefName"
  void writeSharedPref(String prefName, dynamic value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt(prefName, value);
  }
}