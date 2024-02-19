import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:raspored/models/term.dart';
import 'package:raspored/ui/pages/calendar_page.dart';
import 'package:raspored/ui/pages/map_page.dart';
import 'package:raspored/ui/widgets/date_time_picker_widget.dart';
import 'package:raspored/view_models/term_view_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class UserModel {
  final String? username;
  final String? address;
  final int? age;
  final String? id;

  UserModel({this.id, this.username, this.address, this.age});

  Map<String, dynamic> toJson() {
    return {
      "username": username,
      "age": age,
      "id": id,
      "address": address,
    };
  }
}

class _HomePageState extends State<HomePage> {
  final _formKey = GlobalKey<FormState>();
  late GoogleMapController mapController;
  static const CameraPosition initialCameraPosition = CameraPosition(
      target: LatLng(37.42796133580664, -122.085749655962), zoom: 8);

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  final TextEditingController _subjectController = TextEditingController();
  DateTime _dateTime = DateTime.now();
  Marker? _currentMarker;

  void updateDateTime(DateTime newDateTime) {
    _dateTime = newDateTime;
  }

  @override
  Widget build(BuildContext context) {
    context.watch<TermViewModel>().loadTerms();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlue,
        title: const Text("Термини за полагање"),
        centerTitle: true,
        elevation: 3,
        shadowColor: Colors.black,
        automaticallyImplyLeading: false,
        actions: FirebaseAuth.instance.currentUser! != null
            ? [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey,
                  ),
                  onPressed: () => showDialog<String>(
                    context: context,
                    builder: (BuildContext context) => AlertDialog(
                      title: const Text(
                        'Додади термин за полагање',
                        textAlign: TextAlign.center,
                      ),
                      content: SingleChildScrollView(
                        child: Form(
                          key: _formKey,
                          child: SizedBox(
                            height: 400,
                            width: 200,
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  TextFormField(
                                    controller: _subjectController,
                                    decoration: const InputDecoration(
                                        labelText: "Предмет"),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return "Внесете предмет";
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 20),
                                  DateTimePickerWidget(
                                      updateDateTime: updateDateTime),
                                  const SizedBox(height: 10),
                                  ElevatedButton(
                                    onPressed: () => showDialog<String>(
                                      context: context,
                                      builder: (BuildContext context) =>
                                          AlertDialog(
                                        title: const Text(
                                          'Додади локација',
                                          textAlign: TextAlign.center,
                                        ),
                                        content: Expanded(
                                          child: SizedBox(
                                            height: 300,
                                            width: 300,
                                            child: GoogleMap(
                                              onMapCreated: _onMapCreated,
                                              myLocationEnabled: true,
                                              initialCameraPosition:
                                                  initialCameraPosition,
                                              onTap: (latLng) {
                                                setState(() {
                                                  _currentMarker = Marker(
                                                    markerId: const MarkerId(
                                                        "marker1"),
                                                    position: latLng,
                                                  );
                                                });
                                                Navigator.pop(context, 'Add');
                                              },
                                              markers: _currentMarker != null
                                                  ? {_currentMarker!}
                                                  : {},
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    child: const Text(
                                      'Додади локација',
                                      style: TextStyle(color: Colors.lightBlue),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      ElevatedButton(
                                        onPressed: () =>
                                            Navigator.pop(context, 'Cancel'),
                                        child: const Text(
                                          'Откажи',
                                          style: TextStyle(
                                              color: Colors.lightBlue),
                                        ),
                                      ),
                                      const SizedBox(width: 20),
                                      ElevatedButton(
                                        onPressed: () {
                                          if (_formKey.currentState!
                                              .validate()) {
                                            String subjectName =
                                                _subjectController.text;
                                            context
                                                .read<TermViewModel>()
                                                .addTerm(Term(
                                                    subjectName,
                                                    _dateTime,
                                                    _currentMarker!.position));
                                          }
                                          _subjectController.text = '';
                                          _dateTime = DateTime.now();
                                          _currentMarker = null;
                                          Navigator.pop(context, 'Add');
                                        },
                                        child: const Text(
                                          'Додади',
                                          style: TextStyle(
                                              color: Colors.lightBlue),
                                        ),
                                      ),
                                    ],
                                  ),
                                ]),
                          ),
                        ),
                      ),
                    ),
                  ),
                  child: const Text(
                    'Додади',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    FirebaseAuth.instance.signOut();
                    print("Successfully signed out");
                  },
                  icon: const Icon(Icons.logout),
                ),
              ]
            : [
                IconButton(
                  onPressed: () {
                    Navigator.pushNamed(context, "/signIn");
                  },
                  icon: const Icon(Icons.login),
                ),
              ],
      ),
      body: Center(
        child: Column(children: [
          const SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return const CalendarPage();
                      },
                    ),
                  );
                },
                child: const Text(
                  "Календар",
                  style: TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(
                width: 50,
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return const MapPage();
                      },
                    ),
                  );
                },
                child: const Text(
                  "Мапа",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          Expanded(
            child: context.read<TermViewModel>().terms.isEmpty
                ? const Text("Нема активни термини за полагање")
                : GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2),
                    itemCount: context.watch<TermViewModel>().terms.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(10),
                        child: Card(
                          elevation: 3,
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              children: [
                                Text(
                                  context
                                      .watch<TermViewModel>()
                                      .terms[index]
                                      .courseName,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  textAlign: TextAlign.center,
                                  DateFormat('dd/MM/yyyy HH:mm').format(context
                                      .watch<TermViewModel>()
                                      .terms[index]
                                      .dateTime),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
          ),
        ]),
      ),
    );
  }
}
