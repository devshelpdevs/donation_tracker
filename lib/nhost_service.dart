import 'package:graphql/client.dart';
import 'package:rxdart/rxdart.dart';

import 'constants.dart';
import 'models/donation.dart';
import 'models/usage.dart';

class NhostService {
  bool get hasWriteAccess => hasuraSecret != '';

  static const tableDonations = 'temp_money_donations';
  static const tableUsages = 'temp_money_used_for';

  final WebSocketLink _socketLink = WebSocketLink(
    'wss://hasura-3fad0791.nhost.app/v1/graphql',
    config: const SocketClientConfig(
      autoReconnect: true,
      inactivityTimeout: Duration(seconds: 30),
    ),
  );

  final HttpLink _httpLink = HttpLink(
    'https://hasura-3fad0791.nhost.app/v1/graphql',
  );

  late final _link =
      Link.split((request) => request.isSubscription, _socketLink, _httpLink);

  late final client = GraphQLClient(link: _link, cache: GraphQLCache());

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

  late Stream<List<Donation>> donationTableUpdates;
  late Stream<List<Usage>> usageTableUpdates;
  late Stream<OperationException> errorUpdates;

  NhostService() {
    final donationDoc = gql(getDonation);
    final usageDoc = gql(getUsage);

    final donationTableUpdateStream = client
        .subscribe(SubscriptionOptions(document: donationDoc))
        .asBroadcastStream();
    donationTableUpdates = donationTableUpdateStream
        .where((event) => (!event.hasException) && (event.data != null))
        .map((event) {
      final itemsAsMap = event.data![tableDonations] as List;
      return itemsAsMap.map((x) => Donation.fromMap(x!)).toList();
    });

    final usageTableUpdateStream = client
        .subscribe(SubscriptionOptions(document: usageDoc))
        .asBroadcastStream();
    usageTableUpdates = usageTableUpdateStream
        .where((event) => (!event.hasException) && (event.data != null))
        .map((event) {
      final itemsAsMap = event.data![tableUsages] as List;
      return itemsAsMap.map((x) => Usage.fromMap(x!)).toList();
    });

    errorUpdates = usageTableUpdateStream
        .mergeWith([donationTableUpdateStream])
        .where((event) => event.hasException)
        .map((event) => event.exception!);
  }
}
