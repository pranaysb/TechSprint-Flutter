import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ComplaintAnalytics extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection("complaints").snapshots(),
      builder: (_, snap){
        if(!snap.hasData) return Center(child:CircularProgressIndicator());

        int p=0,i=0,r=0;
        for(var d in snap.data!.docs){
          if(d["status"]=="Pending")p++;
          if(d["status"]=="In Progress")i++;
          if(d["status"]=="Resolved")r++;
        }

        return Padding(
          padding: EdgeInsets.all(20),
          child: Column(children:[
            _tile("Pending",p,Colors.orange),
            _tile("In Progress",i,Colors.blue),
            _tile("Resolved",r,Colors.green),
          ]),
        );
      },
    );
  }

  Widget _tile(String t,int v,Color c){
    return Container(
      margin:EdgeInsets.only(bottom:12),
      padding:EdgeInsets.all(16),
      decoration:BoxDecoration(color:c.withOpacity(.15),borderRadius:BorderRadius.circular(16)),
      child:Row(
        mainAxisAlignment:MainAxisAlignment.spaceBetween,
        children:[Text(t),Text(v.toString())],
      ),
    );
  }
}