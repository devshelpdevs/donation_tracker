import 'package:donation_tracker/models/donator.dart';
import 'package:donation_tracker/models/usage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

final backgroundColor = Color.fromARGB(1, 20, 20, 43);
final primaryColor = Color.fromARGB(1, 17, 95, 167);

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

final link = Link.split((request) => request.isSubscription, (socketLink), httpLink);

final client = ValueNotifier<GraphQLClient>(GraphQLClient(link: link, cache: GraphQLCache()));

String getDonation = """
  subscription GetDonation {
    temp_money_donations {
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
    temp_money_used_for {
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
      title: 'Flutter Demo',
      theme: ThemeData(
        scaffoldBackgroundColor: backgroundColor,
        brightness: Brightness.dark,
        //primaryColor: primaryColor,
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends HookWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  Widget build(BuildContext context) {
    final controller = useTabController(initialLength: 2);
    return Scaffold(
      body: Column(
        children: [
          SafeArea(
              child: TabBar(tabs: [
            Tab(
              child: Text('Donations'),
            ),
            Tab(
              child: Text('Usages'),
            )
          ], controller: controller)),
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
    );
  }
}

class Donations extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Subscription(
        builder: (QueryResult result) {
          if (result.hasException) {
            return Text(result.exception.toString());
          }

          if (result.isLoading) {
            return Center(
              child: const CircularProgressIndicator(),
            );
          }
          return ListView.separated(
            itemBuilder: (context, index) {
              if (index == 0) {
                return Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Text(
                          'Donator',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text(
                        'Amount',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                );
              }
              final data = Donator.fromMap(result.data['temp_money_donations'][index - 1]);
              return Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text(
                        data.name,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(
                      data.amount,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              );
            },
            separatorBuilder: (context, index) => Divider(),
            itemCount: result.data['temp_money_donations'].length + 1,
          );
        },
        options: SubscriptionOptions(
          document: gql(getDonation),
        ),
      ),
    );
  }
}

class DonationUsages extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Subscription(
        builder: (QueryResult result) {
          if (result.hasException) {
            return Text(result.exception.toString());
          }

          if (result.isLoading) {
            return Center(
              child: const CircularProgressIndicator(),
            );
          }
          return ListView.separated(
            itemBuilder: (context, index) {
              if (index == 0) {
                return Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text(
                        'Amount',
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Text(
                          'Usage',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                );
              }
              final data = Usage.fromMap(result.data['temp_money_used_for'][index - 1]);
              return Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(
                      data.amount,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text(
                        data.whatFor,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              );
            },
            separatorBuilder: (context, index) => Divider(),
            itemCount: result.data['temp_money_used_for'].length + 1,
          );
        },
        options: SubscriptionOptions(
          document: gql(getUsage),
        ),
      ),
    );
  }
}
