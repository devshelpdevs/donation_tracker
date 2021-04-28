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

final tableDonations = 'temp_money_donations';
final tableUsages = 'temp_money_used_for';
final backgroundColor = kColorFromHex('#14142B');
final primaryColor = kColorFromHex('#115FA7');

const tableHeaderStyle = TextStyle(fontWeight: FontWeight.bold, fontSize: 16);

const server =
    const String.fromEnvironment('SERVER', defaultValue: '3fad0791.nhost.app');

const hasuraSecret = const String.fromEnvironment('HASURA_SECRET');
const userID = const String.fromEnvironment('USER_ID');
const authPassword = const String.fromEnvironment('AUTH_PASSWORD');

const graphQlEndPoint = 'hasura-$server/v1/graphql';

final WebSocketLink _socketLink = WebSocketLink(
  'wss://$graphQlEndPoint',
  config: SocketClientConfig(
    autoReconnect: true,
    inactivityTimeout: Duration(seconds: 30),
  ),
);

final HttpLink _httpLink = HttpLink('https://$graphQlEndPoint');

final _link =
    Link.split((request) => request.isSubscription, _socketLink, _httpLink);

final client = ValueNotifier<GraphQLClient>(
    GraphQLClient(link: _link, cache: GraphQLCache()));

String getDonation = """
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
""";

String getUsage = """
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
""";
