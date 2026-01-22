import 'package:flutter/material.dart';

class StatusTimeline extends StatelessWidget {
  final String status;
  StatusTimeline(this.status);

  int get step {
    if (status == "Pending") return 0;
    if (status == "In Progress") return 1;
    return 2;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children:[
        _dot("Pending",0),
        _dot("In Progress",1),
        _dot("Resolved",2),
      ],
    );
  }

  Widget _dot(String label,int i){
    final active=i<=step;
    return Column(children:[
      CircleAvatar(radius:8, backgroundColor:active?Colors.green:Colors.grey),
      SizedBox(height:4),
      Text(label,style:TextStyle(fontSize:11))
    ]);
  }
}