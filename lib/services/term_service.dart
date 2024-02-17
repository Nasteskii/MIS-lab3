import 'package:raspored/main.dart';
import 'package:raspored/models/term.dart';

class TermService {
  final List<Term> _terms = [];

  TermService() {}

  List<Term> get terms => _terms;

  Future<void> addTerm(Term term) async {
    if (term.courseName != '') {
      _terms.add(term);
      scheduleNotification(term);
    }
  }

  Future<void> updateTerm(Term oldTerm, Term newTerm) async {
    if (_terms.isNotEmpty && _terms.contains(oldTerm)) {
      final index = _terms.indexOf(oldTerm);
      if (newTerm.courseName != '') {
        _terms[index] = newTerm;
      }
    }
  }

  Future<void> removeTerm(Term term) async {
    if (_terms.isNotEmpty && _terms.contains(term)) {
      _terms.remove(term);
    }
  }
}
