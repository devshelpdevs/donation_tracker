
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

Color kColorFromHex(String color) {
  final hexColorTrim = color.toUpperCase().replaceAll('#', '').replaceAll('0X', '').padLeft(8, 'F');
  return Color(int.parse(hexColorTrim, radix: 16));
}

final tableDonations = 'temp_money_donations';
final tableUsages = 'temp_money_used_for';
final backgroundColor = kColorFromHex('#14142B');
final primaryColor = kColorFromHex('#115FA7');

final WebSocketLink _socketLink = WebSocketLink(
  'wss://hasura-3fad0791.nhost.app/v1/graphql',
  config: SocketClientConfig(
    autoReconnect: true,
    inactivityTimeout: Duration(seconds: 30),
  ),
);

final HttpLink _httpLink = HttpLink(
  'https://hasura-3fad0791.nhost.app/v1/graphql',
);

final _link = Link.split((request) => request.isSubscription, _socketLink, _httpLink);

final client = ValueNotifier<GraphQLClient>(GraphQLClient(link: _link, cache: GraphQLCache()));

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