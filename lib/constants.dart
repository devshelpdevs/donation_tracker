import 'package:flutter/material.dart';
import 'package:graphql/client.dart';

Color kColorFromHex(String color) {
  final hexColorTrim = color
      .toUpperCase()
      .replaceAll('#', '')
      .replaceAll('0X', '')
      .padLeft(8, 'F');
  return Color(int.parse(hexColorTrim, radix: 16));
}

const tableDonations = 'temp_money_donations';
const tableUsages = 'temp_money_used_for';
final backgroundColor = kColorFromHex('#14142B');
final primaryColor = kColorFromHex('#115FA7');

const tableHeaderStyle = TextStyle(fontWeight: FontWeight.bold, fontSize: 16);

const server =
    String.fromEnvironment('SERVER', defaultValue: '3fad0791.nhost.app');

const hasuraSecret = String.fromEnvironment('HASURA_SECRET');
const userID = String.fromEnvironment('USER_ID');
const authPassword = String.fromEnvironment('AUTH_PASSWORD');

const graphQlEndPoint = 'hasura-$server/v1/graphql';

final WebSocketLink _socketLink = WebSocketLink(
  'wss://$graphQlEndPoint',
  config: const SocketClientConfig(
    autoReconnect: true,
    inactivityTimeout: Duration(seconds: 30),
  ),
);

final HttpLink _httpLink = HttpLink('https://$graphQlEndPoint');

final _link =
    Link.split((request) => request.isSubscription, _socketLink, _httpLink);

final client = ValueNotifier<GraphQLClient>(
    GraphQLClient(link: _link, cache: GraphQLCache()));

String getDonation = '''
  subscription GetDonation {
    $tableDonations(order_by: {donation_date: desc}) {
      created_at
      donator
      id
      updated_at
      value
      donation_date
    }
  }
''';

String getUsage = '''
  subscription GetUsage {
    $tableUsages(order_by: {usage_date: desc}) {
      created_at
      id
      storage_image_name
      updated_at
      usage
      value
      usage_date
    }
  }
''';

// xs: 0 – 599
// sm: 600 – 1023
// md: 1024 – 1439
// lg: 1440 – 1919
// xl: 1920 +
