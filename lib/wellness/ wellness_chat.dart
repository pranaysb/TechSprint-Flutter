import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'wellness_service.dart';

class WellnessChat extends StatefulWidget {
  @override
  State<WellnessChat> createState() => _WellnessChatState();
}

class _WellnessChatState extends State<WellnessChat> {
  final controller = TextEditingController();
  List<Map> chats = [];
  bool loading = false;

  Future sendMsg(String msg) async {
    setState(() {
      chats.add({"user": msg});
      loading = true;
    });

    final reply = await getWellnessReply(msg);

    setState(() {
      chats.add({"ai": reply});
      loading = false;
    });

    FirebaseFirestore.instance.collection("wellness_chats").add({
      "message": msg,
      "reply": reply,
      "createdAt": FieldValue.serverTimestamp(),
    });
  }

  Widget bubble(String text, bool isUser) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8),
        padding: EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isUser ? Colors.indigo : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(text,
            style: TextStyle(color: isUser ? Colors.white : Colors.black)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("MindCare AI")),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(16),
              children: chats.map((c) {
                if (c.containsKey("user")) {
                  return bubble(c["user"], true);
                } else {
                  return bubble(c["ai"], false);
                }
              }).toList(),
            ),
          ),

          if (loading) Padding(
            padding: EdgeInsets.all(8),
            child: CircularProgressIndicator(),
          ),

          // QUICK MOODS
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: ["😔","😰","😡","😴","🙂"].map((e) {
                return TextButton(
                  child: Text(e, style: TextStyle(fontSize: 22)),
                  onPressed: () => sendMsg("I feel $e"),
                );
              }).toList(),
            ),
          ),

          Padding(
            padding: EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: InputDecoration(
                        hintText: "Type your thoughts...",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16))),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    final t = controller.text.trim();
                    if (t.isNotEmpty) {
                      controller.clear();
                      sendMsg(t);
                    }
                  },
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}