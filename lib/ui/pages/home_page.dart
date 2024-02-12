import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:raspored/models/term.dart';
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

  final TextEditingController _subjectController = TextEditingController();
  DateTime _dateTime = DateTime.now();

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
        actions: FirebaseAuth.instance.currentUser != null
            ? [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
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
                            height: 300,
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
                                                    subjectName, _dateTime));
                                          }
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
      body: Column(children: [
        Expanded(
          child: context.read<TermViewModel>().terms.isEmpty
              ? const Text("Нема активни термини за полагање")
              : GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3),
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
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Text(
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
    );
  }
}
