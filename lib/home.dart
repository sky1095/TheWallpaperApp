import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:the_wallpaper_app/api/apiConstant.dart';
import 'package:the_wallpaper_app/api/collections.dart';
import 'package:the_wallpaper_app/api/imageFormats.dart';
import 'package:the_wallpaper_app/api/photo.dart';
import 'package:the_wallpaper_app/wallPage.dart';
import 'api/imageFormats.dart';
import 'dart:ui';

import 'api/searchResult.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _apiService = ApiService("Your API key here");
  Photo randomPhoto;
  Size size;
  List<Photo> recent = [];
  List<Photo> popular = [];
  List<Photo> curated = [];

  @override
  void initState() {
    _apiService.getPhoto().then((photo) {
      setState(() {
        randomPhoto = photo;
        _apiService.getQuota().then(
            (quota) => print("Remaining request: ${quota.getRequestsPerHour}"));
      });
    });
    _apiService
        .searchPhotos("beach",
            collection: Collection.Regular, page: 1, resultsPerPage: 5)
        .then((value) {
      setState(() {
        recent = value.items;
      });
    });
    _apiService
        .searchPhotos("code",
            collection: Collection.Popular, page: 1, resultsPerPage: 5)
        .then((value) {
      setState(() {
        popular = value.items;
      });
    });
    _apiService
        .searchPhotos("code",
            collection: Collection.Curated, page: 1, resultsPerPage: 5)
        .then((value) {
      setState(() {
        curated = value.items;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.black,
      body: randomPhoto == null
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Stack(
              children: <Widget>[
                background(),
                SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.only(top: size.height / 3),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        backgroundTitle(),
                        showCategoryCarousel("Recent", recent),
                        showCategoryCarousel("Popular", popular),
                        showCategoryCarousel("Curated", curated),
                      ],
                    ),
                  ),
                ),
              ],
            ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        items: [
          BottomNavigationBarItem(
            title: Container(),
            icon: IconButton(
              onPressed: () {
                showSearch(
                  context: context,
                  delegate: WallpaperSearch(
                    apiService: _apiService,
                  ),
                );
              },
              icon: Icon(
                Icons.search,
                color: Colors.white,
              ),
            ),
          ),
          BottomNavigationBarItem(
            title: Container(),
            icon: Icon(
              Icons.home,
              color: Colors.white,
            ),
          )
        ],
      ),
    );
  }

  Widget showCategoryCarousel(
    String title,
    List<Photo> carouselType,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(left: 16.0),
          child: Text(
            title,
            style: GoogleFonts.raleway(
              textStyle: TextStyle(
                fontSize: (size.width * 6) / 100,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
        ),
        Container(
          width: size.width,
          height: (size.height * 17) / 100,
          child: ListView.builder(
            padding: EdgeInsets.all(16),
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            itemCount: carouselType.length,
            itemBuilder: (context, index) {
              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WallPage(
                        photo: carouselType[index],
                      ),
                    ),
                  );
                },
                child: Padding(
                  padding: EdgeInsets.only(left: 8.0),
                  child: Container(
                    width: (size.width * 30) / 100,
                    height: (size.height * 10) / 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: NetworkImage(
                          carouselType[index].get(ImageFormats.landscape),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        )
      ],
    );
  }

  Widget backgroundTitle() {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            "The Wallpaper App",
            style: GoogleFonts.raleway(
              textStyle: TextStyle(
                fontSize: (size.width * 10) / 100,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 8.0),
            child: Text(
              "Photo of the Day by Sudhanshu",
              style: GoogleFonts.raleway(
                textStyle: TextStyle(
                  fontSize: (size.width * 4) / 100,
                  fontWeight: FontWeight.w100,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget background() {
    return ShaderMask(
      shaderCallback: (rect) {
        return LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, Colors.black],
        ).createShader(
          Rect.fromLTRB(0, 0, rect.width, rect.height - 20),
        );
      },
      blendMode: BlendMode.darken,
      child: Container(
        height: size.height / 1.5,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(
              randomPhoto.get(
                ImageFormats.medium,
              ),
            ),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}

class WallpaperSearch extends SearchDelegate {
  final ApiService apiService;
  WallpaperSearch({this.apiService});

  @override
  String get searchFieldLabel => "Search...";

  @override
  ThemeData appBarTheme(BuildContext context) {
    return ThemeData.dark();
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = "";
        },
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back_ios),
      onPressed: () => Navigator.pop(context),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return FutureBuilder<SearchResult<Photo>>(
        future: apiService.searchPhotos(
          query,
          collection: Collection.Regular,
          page: 1,
          resultsPerPage: 16,
        ),
        builder: (context, snapshot) {
          print("building");
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              return GridView.builder(
                padding: EdgeInsets.all(16),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.7,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                ),
                itemCount: snapshot.data.items.length,
                itemBuilder: (context, index) => InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => WallPage(
                          photo: snapshot.data.items[index],
                        ),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: NetworkImage(
                          snapshot.data.items[index].get(ImageFormats.portrait),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text("Cant Find Yet"),
              );
            } else {
              return Center(
                child: Text("Something else happend"),
              );
            }
          } else {
            return Container();
          }
        });
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return query.isNotEmpty
        ? Center(
            child: CircularProgressIndicator(),
          )
        : Container();
  }
}
