import 'package:flutter/material.dart';

import '../../database_mgr/trip_descripton_db.dart';
import '../../screens/main_menu_screen.dart';

class TripActions {

  /// Update row in the database with timestamp of trip ending time
  /// This ends the trip and it will now be shown in "Trip History" screen
  /// after that navigate to main screen
  void endTrip(TripDescriptionModel tripDescModel,
               BuildContext ctx) async {
    TripDescriptionDb tripDescriptionDb = TripDescriptionDb();

    await tripDescriptionDb.finishTrip(tripDescModel);

    Navigator.push(
        ctx,
        MaterialPageRoute(builder: (context) => MotoRoute())
    );
  }
}