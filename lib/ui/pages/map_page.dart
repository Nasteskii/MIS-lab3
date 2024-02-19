import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:raspored/models/term.dart';
import 'package:raspored/view_models/term_view_model.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late GoogleMapController _controller;
  LocationData? _currentLocation;
  late Set<Marker> _markers = {};
  List<LatLng> polyLinesCoordinates = [];
  static const CameraPosition initialCameraPosition = CameraPosition(
      target: LatLng(37.42796133580664, -122.085749655962), zoom: 8);

  void _getLocation() async {
    bool serviceEnabled;

    serviceEnabled = await Location.instance.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await Location.instance.requestService();
      if (!serviceEnabled) {
        return;
      }
    }
    _getCurrentLocation();
  }

  void _getCurrentLocation() async {
    Location location = Location();
    try {
      _currentLocation = await location.getLocation();
    } catch (e) {
      print('Error: $e');
    }
  }

  void _getPolyPoints() async {
    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        'AIzaSyA9dYDx65ZhEJJTYDBU5nc0BJbe-LBIG9M',
        PointLatLng(_currentLocation!.latitude!, _currentLocation!.longitude!),
        PointLatLng(
            _markers.last.position.latitude, _markers.last.position.longitude));
    if (result.points.isNotEmpty) {
      for (var point in result.points) {
        polyLinesCoordinates.add(LatLng(point.latitude, point.longitude));
      }
      setState(() {});
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _controller = controller;
  }

  Set<Marker> createMarkers(List<Term> terms) {
    return terms.map((term) {
      return Marker(
        markerId: MarkerId(term.courseName),
        position: term.latLng,
        infoWindow: InfoWindow(
          title: term.courseName,
          snippet: term.dateTime.toString(),
        ),
      );
    }).toSet();
  }

  @override
  Widget build(BuildContext context) {
    _markers = createMarkers(context.read<TermViewModel>().terms);
    _getLocation();
    _getPolyPoints();
    if (_currentLocation != null) {
      _markers.add(Marker(
        markerId: const MarkerId("currentLocation"),
        position:
            LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!),
        infoWindow: const InfoWindow(
          title: "Your position",
        ),
      ));
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlue,
        title: const Text("Мапа"),
        centerTitle: true,
        elevation: 3,
        shadowColor: Colors.black,
      ),
      body: Expanded(
        child: GoogleMap(
          onMapCreated: _onMapCreated,
          myLocationEnabled: true,
          initialCameraPosition: initialCameraPosition,
          markers: _markers,
          polylines: {
            Polyline(
              polylineId: const PolylineId("route"),
              points: polyLinesCoordinates,
              color: Colors.lightBlue,
              width: 6,
            ),
          },
        ),
      ),
    );
  }
}
