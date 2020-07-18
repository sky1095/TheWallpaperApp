import 'dart:convert';
import 'dart:io';
// import 'package:http/http.dart' as http;
import 'package:the_wallpaper_app/api/collections.dart';
import 'package:the_wallpaper_app/api/endpoints.dart';
import 'package:the_wallpaper_app/api/imageFormats.dart';
import 'package:the_wallpaper_app/api/photo.dart';
import 'package:the_wallpaper_app/api/photoSource.dart';
import 'package:the_wallpaper_app/api/quota.dart';
import 'package:the_wallpaper_app/api/searchResult.dart';

class ApiService {
  static Quota _quota = Quota();
  final String apiKey;

  ApiService(this.apiKey);

  Future<String> _getData(String url) async {
    HttpClient client = new HttpClient();
    var req = await client.getUrl(Uri.parse(url));
    req.headers.add('Authorization', apiKey);
    var resp = await req.close();
    var data;
    if (resp.statusCode == 200) {
      data = await resp
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .single;
      // update quota.
      _quota = new Quota(
          remainingRequestsPerMonth:
              int.tryParse(resp.headers.value('X-Ratelimit-Remaining')));
    }

    return data;
  }

  Future<Quota> getQuota() async => _quota;

  Future<Photo> _getPhotoRandom() async {
    var url = Endpoints.photoRandom();

    String data = await _getData(url);

    if (data == null) return null;

    var o = jsonDecode(data);

    var photoData = o['photos'][0];
    // extract data
    return _buildPhoto(photoData);
  }

  Future<Photo> _getPhotoFromID(int id) async {
    var url = Endpoints.photo(id);

    String data = await _getData(url);

    if (data == null) return null;
    var photoData = jsonDecode(data);
    // extract data
    return _buildPhoto(photoData);
  }

  Photo _buildPhoto(photoData) {
    // extract data
    var src = photoData['src'];
    if (src != null) {
      var sources = <String, PhotoSource>{};
      ImageFormats.values.forEach((size) {
        var format = size.toString().replaceAll('ImageFormats.', '');
        sources[format] = PhotoSource(src[format]);
      });

      return Photo(
          photoData['id'],
          photoData['width'],
          photoData['height'],
          photoData['url'],
          photoData['photographer'],
          photoData['photographer_url'],
          sources);
    }
    return null;
  }

  /// [id] the id of the photo to return.
  /// if [id] is not specified, a random photo will be returned.
  Future<Photo> getPhoto({int id}) async =>
      id == null ? _getPhotoRandom() : _getPhotoFromID(id);

  Future<SearchResult<Photo>> searchPhotos(String query,
      {Collection collection = Collection.Regular,
      int resultsPerPage = 15,
      int page = 1}) async {
    var url = _getPhotoEndpoint(collection, query, page, resultsPerPage);

    String data = await _getData(url);

    if (data == null) return null;

    var resultData = jsonDecode(data);

    var photosData = resultData['photos'];

    if (photosData == null) return null;

    var photos = <Photo>[];

    for (dynamic photoData in photosData) {
      photos.add(_buildPhoto(photoData));
    }
    return new SearchResult(resultData['page'], resultData['per_page'],
        resultData['total_results'], resultData['next_page'], photos);
  }

  String _getPhotoEndpoint(
      Collection collection, String query, int page, int resultsPerPage) {
    switch (collection) {
      case Collection.Curated:
        return Endpoints.photoSearchCurated(
            page: page, perPage: resultsPerPage);
      case Collection.Popular:
        return Endpoints.photoSearchPopular(
            page: page, perPage: resultsPerPage);
      case Collection.Regular: // fallback to default
      default:
        return Endpoints.photoSearch(query,
            page: page, perPage: resultsPerPage);
    }
  }
}
