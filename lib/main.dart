import 'package:donation_tracker/constants.dart';
import 'package:donation_tracker/donation_manager.dart';
import 'package:donation_tracker/presentation/donations.dart';
import 'package:donation_tracker/presentation/usage.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'nhost_service.dart';

void main() {
  GetIt.I.registerSingleton(NhostService());
  GetIt.I.registerSingleton(DonationManager());

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Usage overview of DevsHelpDevs\'donations',
      theme: ThemeData(
        scaffoldBackgroundColor: backgroundColor,
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  late final controller =
      TabController(initialIndex: 0, length: 2, vsync: this);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: backgroundColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SafeArea(
              child: TabBar(tabs: [
                Tab(
                  child: Text('Received Donations'.toUpperCase()),
                ),
                Tab(
                  child: Text('Used for'.toUpperCase()),
                )
              ], controller: controller),
            ),
            Expanded(
              child: TabBarView(
                controller: controller,
                children: [
                  Donations(),
                  DonationUsages(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
