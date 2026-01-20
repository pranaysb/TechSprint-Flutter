import 'package:cloud_firestore/cloud_firestore.dart';

class EventService {
  static final _db = FirebaseFirestore.instance;

  static Stream<QuerySnapshot> allEvents() {
    return _db.collection("Events").snapshots();
  }

  static Stream<QuerySnapshot> eventsByDate(String date) {
    return _db.collection("Events").where("date", isEqualTo: date).snapshots();
  }

  static Future addEvent(Map<String, dynamic> data) async {
    await _db.collection("Events").add(data);
  }
}