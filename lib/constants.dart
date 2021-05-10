import 'package:flutter/material.dart';

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

const graphQlEndPoint = 'https://hasura-$server/v1/graphql';

const nhostBaseUrl = 'https://backend-$server';

String buildImageLink(String fileName, bool peopleStorage) =>
    '$nhostBaseUrl/storage/o/${peopleStorage ? 'people' : 'public'}/$fileName';
