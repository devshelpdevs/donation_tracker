import 'package:donation_tracker/constants.dart';
import 'package:donation_tracker/presentation/donator.dart';
import 'package:donation_tracker/presentation/usage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:graphql_flutter/graphql_flutter.dart';


void main() {
  runApp(GraphQLProvider(
    child: MyApp(),
    client: client,
  ));
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

class MyHomePage extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final controller = useTabController(initialLength: 2);
    return Scaffold(
      body: Container(
        color: backgroundColor,
        child: Column(
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
}
