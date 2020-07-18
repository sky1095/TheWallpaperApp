abstract class Source {
  final String link;
  const Source(this.link);
}

class PhotoSource extends Source {
  const PhotoSource(String link) : super(link);
}
