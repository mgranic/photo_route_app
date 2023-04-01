import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

import 'gallery_subscreens/image_screen.dart';
import 'gallery_subscreens/video_screen.dart';

class TripGalleryScreen  extends StatefulWidget {
  late int _id;
  late DateTime _tripStart;
  late DateTime _tripEnd;

  TripGalleryScreen(this._id, this._tripStart, this._tripEnd);

  @override
  State<StatefulWidget> createState() => _TripGalleryScreen(_id, _tripStart, _tripEnd);
  
}

// https://dev.to/aouahib/build-a-flutter-gallery-to-display-all-the-photos-and-videos-in-your-phone-pb6
class _TripGalleryScreen extends State<TripGalleryScreen> {
  late int _id;
  late DateTime _tripStart;
  late DateTime _tripEnd;
  // This will hold all the assets (images and videos) we fetched
  List<AssetEntity> assets = [];

  _TripGalleryScreen(this._id, this._tripStart, this._tripEnd);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trip gallery'),
      ),
      body: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          // A grid view with 3 items per row
          crossAxisCount: 3,
        ),
        itemCount: assets.length,
        itemBuilder: (_, index) {
          return _AssetThumbnail(asset: assets[index]);
        },
      ),
    );
  }

  @override
  void initState() {
    // _fetchAssets function should be called when we first navigate to the Gallery screen
    // so ve override initState function
    _fetchAssets();
    super.initState();
  }

  ///  function that fetches the assets, and updates the state
  _fetchAssets() async {
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

    // Update the state and notify UI
    //setState(() => assets = recentAssets);

    setState(() {
      for (var i = 0; i < recentAssets.length; i++) {
        if (recentAssets[i].createDtSecond! <= ((_tripEnd.millisecondsSinceEpoch/1000).ceil() + (_tripEnd.timeZoneOffset.inMilliseconds/1000).ceil()) &&
            recentAssets[i].createDtSecond! >= ((_tripStart.millisecondsSinceEpoch/1000).floor() + (_tripStart.timeZoneOffset.inMilliseconds/1000).floor())) {
          assets.add(recentAssets[i]);
        }
      }
    });

  }
  
}

class _AssetThumbnail extends StatelessWidget {
  const _AssetThumbnail({
    Key ?key,
    required this.asset,
  }) : super(key: key);

  final AssetEntity ?asset;

  @override
  Widget build(BuildContext context) {
    // We're using a FutureBuilder since thumbData is a future
    return FutureBuilder<Uint8List?>(
      future: asset?.thumbData,
      builder: (_, snapshot) {
        final bytes = snapshot.data;
        // If we have no data, display a spinner
        if (bytes == null) return CircularProgressIndicator();
        // If there's data, display it as an image
        return InkWell(
          onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) {
                    if (asset?.type == AssetType.image) {
                      // If this is an image, navigate to ImageScreen
                      return ImageScreen(imageFile: _createNonNullableFuture(asset!.file));
                    } else {
                      // if it's not, navigate to VideoScreen
                      return VideoScreen(videoFile: _createNonNullableFuture(asset!.file));
                    }
                  },
                ),
              );
          },
          child: Stack(
            children: [
              // Wrap the image in a Positioned.fill to fill the space
              Positioned.fill(
                child: Image.memory(bytes, fit: BoxFit.cover),
              ),
              // Display a Play icon if the asset is a video
              if (asset?.type == AssetType.video)
                Center(
                  child: Container(
                    color: Colors.blue,
                    child: Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  /// This function is used to convert Future<File?>? into Future<File>
  Future<File> _createNonNullableFuture(Future<File?>? futureFile) async{
    File file = (await futureFile!)!;
    return file;
  }

}