import 'package:flutter/material.dart';
import 'package:raspored/models/term.dart';
import 'package:raspored/services/term_service.dart';

class TermViewModel extends ChangeNotifier {
  final TermService _termService = TermService();
  bool _isLoading = true;
  List<Term> terms = [];

  bool get isLoading => _isLoading;

  Future<void> loadTerms() async {
    await Future<void>.delayed(const Duration(seconds: 4));
    terms = _termService.terms;

    notifyListeners();
    _isLoading = false;
  }

  void addTerm(Term term) {
    _termService.addTerm(term);

    notifyListeners();
  }

  void updateTerm(Term oldTerm, Term newTerm) {
    _termService.updateTerm(oldTerm, newTerm);

    notifyListeners();
  }

  void removeTerm(Term term) {
    _termService.removeTerm(term);

    notifyListeners();
  }
}
