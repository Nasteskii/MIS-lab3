import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:raspored/models/term.dart';
import 'package:raspored/view_models/term_view_model.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  int getHashCode(DateTime key) {
    return key.day * 1000000 + key.month * 10000 + key.year;
  }

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  @override
  Widget build(BuildContext context) {
    List<Term> termsList = context.watch<TermViewModel>().terms;

    LinkedHashMap<DateTime, List<Term>> events =
        LinkedHashMap<DateTime, List<Term>>(
      equals: isSameDay,
      hashCode: getHashCode,
    )..addAll(termsList.fold({}, (map, term) {
            if (map.containsKey(term.dateTime)) {
              map[term.dateTime]?.add(term);
            } else {
              map[term.dateTime] = [term];
            }
            return map;
          }));

    List getEventForDay(DateTime day) {
      List<Term> terms = [];
      for (var term in termsList) {
        if (isSameDay(term.dateTime, day)) {
          terms.add(term);
        }
      }
      return terms;
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlue,
        title: const Text("Календар"),
        centerTitle: true,
        elevation: 3,
        shadowColor: Colors.black,
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2025, 12, 31),
            focusedDay: _focusedDay,
            eventLoader: getEventForDay,
            calendarFormat: _calendarFormat,
            onFormatChanged: (format) {
              if (_calendarFormat != format) {
                setState(() {
                  _calendarFormat = format;
                });
              }
            },
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              if (!isSameDay(_selectedDay, selectedDay)) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              }
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
          ),
          const SizedBox(
            height: 20,
          ),
          ListView(
            shrinkWrap: true,
            children: getEventForDay(_selectedDay!)
                .map((term) => ListTile(
                      title: Text(term.courseName),
                      subtitle: Text(term.dateTime.toString()),
                    ))
                .toList(),
          )
        ],
      ),
    );
  }
}
