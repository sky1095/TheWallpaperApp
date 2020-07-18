import 'package:the_wallpaper_app/api/imageFormats.dart';
import 'package:the_wallpaper_app/api/photoSource.dart';

class Photo {
  final int id;
  final int width;
  final int height;
  final String url;
  final String photographer;
  final String photographerURL;
  final Map<String, PhotoSource> sources;
  const Photo(this.id, this.width, this.height, this.url, this.photographer,
      this.photographerURL, this.sources);

  String get(ImageFormats format) =>
      sources[format.toString().replaceAll('ImageFormats.', '')].link;
}
