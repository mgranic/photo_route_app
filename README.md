# PhotoRoute
## _Collect images and automatically create photo album from a trip_

Flutter application tested on both iOS and Android that allows you to create a trip and automaticaly generate photo album from it. Application records all the photos that are taken while trip is active and groups them in the trip photo album.

While in TripHistory menu you can tap and hold on any trip and menu will popup in AppBar/TaskBar that will allow you to upload the trip to server or delete the trip. You can also select multiple trip to perform an action on multiple trips at the same time.

There is also .NET web service in the repo that handles uploading photo album to web server. Idea is to be able to upload my photo albums directly to my web server/computer.

The idea came to me while doing motorcycle trips so that's why sometimes in the code it is written "moto route", but later on i used it on my regular trips so i renamed the repo/project to photo route but never really refactored the app.

## Features

- create new trip and end the trip
- view trip history
- view trip photo gallery
- upload trip photo album to server (tap+hold on trip)
- delete trip photo album (tap+hold on trip)

### Main screen
![PhotoRoute screenshot](resources/main_screen.jpg "HomePage")

### Create trip
![PhotoRoute screenshot](resources/create_trip_screen.jpg "Create trip")

### Ongoing trip
![PhotoRoute screenshot](resources/ongoing_trip.jpg "Ongoing trip")

### Main screen while trip is active (cannot start another trip)
![PhotoRoute screenshot](resources/main_screen_trip_active.jpg "HomePage trip active")

### Trip history (list of finished trips/photo albums)
![PhotoRoute screenshot](resources/trip_history.jpg "List of trips")

### Trip gallery (photo gallery)
![PhotoRoute screenshot](resources/trip_gallery.jpg "List of photos")

### Trip history menu (upload/delete albums)
![PhotoRoute screenshot](resources/upload_delete_album.jpg "Upload/delete trips")