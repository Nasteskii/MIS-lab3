import 'package:google_maps_flutter/google_maps_flutter.dart';

class Term {
  final String courseName;
  final DateTime dateTime;
  final LatLng latLng;

  Term(this.courseName, this.dateTime, this.latLng);
}
