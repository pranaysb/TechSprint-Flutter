import 'package:flutter/material.dart';
import 'complaint_form.dart';
import 'complaint_status.dart';
import 'admin_dashboard.dart';
import 'complaint_analytics.dart';

class ComplaintHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length:3,
      child:Scaffold(
        appBar:AppBar(
          title:Text("Smart Complaints"),
          bottom:TabBar(tabs:[
            Tab(text:"My Complaints"),
            Tab(text:"New"),
            Tab(text:"Admin"),
          ]),
        ),
        body:TabBarView(children:[
          ComplaintStatus(),
          ComplaintForm(),
          DefaultTabController(
            length:2,
            child:Scaffold(
              appBar:TabBar(tabs:[
                Tab(text:"Dashboard"),
                Tab(text:"Analytics")
              ]),
              body:TabBarView(children:[
                AdminDashboard(),
                ComplaintAnalytics()
              ]),
            ),
          )
        ]),
      ),
    );
  }
}