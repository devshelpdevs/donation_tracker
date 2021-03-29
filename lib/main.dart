import 'package:donation_tracker/models/donator.dart';
import 'package:donation_tracker/models/usage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

Color kColorFromHex(String color) {
  final hexColorTrim = color.toUpperCase().replaceAll('#', '').replaceAll('0X', '').padLeft(8, 'F');
  return Color(int.parse(hexColorTrim, radix: 16));
}

final tableDonations = 'temp_money_donations';
final tableUsages = 'temp_money_used_for';
final backgroundColor = kColorFromHex('#14142B');
final primaryColor = kColorFromHex('#115FA7');

final WebSocketLink socketLink = WebSocketLink(
  'wss://hasura-3fad0791.nhost.app/v1/graphql',
  config: SocketClientConfig(
    autoReconnect: true,
    inactivityTimeout: Duration(seconds: 30),
  ),
);

final HttpLink httpLink = HttpLink(
  'https://hasura-3fad0791.nhost.app/v1/graphql',
);

final link = Link.split((request) => request.isSubscription, socketLink, httpLink);

final client = ValueNotifier<GraphQLClient>(GraphQLClient(link: link, cache: GraphQLCache()));

String getDonation = """
  subscription GetDonation {
    $tableDonations {
      created_at
      donator
      id
      updated_at
      value
    }
  }
""";

String getUsage = """
  subscription GetUsage {
    $tableUsages {
      created_at
      id
      storage_image_name
      updated_at
      usage
      value
    }
  }
""";

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

class Donations extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Subscription(
      builder: (QueryResult result) {
        if (result.hasException) {
          return Text(result.exception.toString());
        }

        if (result.isLoading) {
          return Center(
            child: const CircularProgressIndicator(),
          );
        }
        final List data = result.data![tableDonations];
        return DataTable(
          rows: data.map((element) {
            final data = Donator.fromMap(element);
            return DataRow(cells: [
              DataCell(Text(data.name)),
              DataCell(Text(data.createdAt)),
              DataCell(Text(data.amount)),
            ]);
          }).cast<DataRow>().toList(),
          columns: [
            DataColumn(
              label: const Text('Name'),
            ),
            DataColumn(
              label: const Text('Date'),
            ),
            DataColumn(
              label: const Text('Amount'),
            ),
          ],
        );
      },
      options: SubscriptionOptions(
        document: gql(getDonation),
      ),
    );
  }
}

class DonationUsages extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Subscription(
      builder: (QueryResult result) {
        if (result.hasException) {
          return Text(result.exception.toString());
        }

        if (result.isLoading) {
          return Center(
            child: const CircularProgressIndicator(),
          );
        }
        final List data = result.data![tableUsages];
        return DataTable(
          rows: data.map((element) {
            final data = Usage.fromMap(element);
            return DataRow(cells: [
              DataCell(Text(data.createdAt)),
              DataCell(Text(data.amount)),
              DataCell(Text(data.whatFor)),
              DataCell(data.image == null? Container() : Image.network(data.image!)),
            ]);
          }).cast<DataRow>().toList(),
          columns: [
            DataColumn(
              label: const Text('Date'),
            ),
            DataColumn(
              label: const Text('Amount'),
            ),
            DataColumn(
              label: const Text('For'),
            ),
            DataColumn(
              label: const Text('Image'),
            ),
          ],
        );
      },
      options: SubscriptionOptions(
        document: gql(getUsage),
      ),
    );
  }
}
