import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:the_wallpaper_app/api/imageFormats.dart';
import 'package:the_wallpaper_app/api/photo.dart';
import 'package:wallpaper_manager/wallpaper_manager.dart';

class WallPage extends StatelessWidget {
  final Photo photo;
  WallPage({this.photo});

  void setAsWallpaper(String url) async {
    int location = WallpaperManager.BOTH_SCREENS;
    var file = await DefaultCacheManager().getSingleFile(url);
    final String result =
        await WallpaperManager.setWallpaperFromFile(file.path, location);
    print(result);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            image: DecorationImage(
              fit: BoxFit.cover,
              image: NetworkImage(
                photo.get(ImageFormats.portrait),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          child: Container(
            height: (MediaQuery.of(context).size.height * 6) / 100,
            width: MediaQuery.of(context).size.width,
            child: FlatButton(
              color: Colors.black.withOpacity(0.3),
              textColor: Colors.white,
              splashColor: Colors.green,
              child: Text("Set as Wallpaper"),
              onPressed: () {
                setAsWallpaper(photo.get(ImageFormats.portrait));
              },
            ),
          ),
        )
      ],
    );
  }
}
