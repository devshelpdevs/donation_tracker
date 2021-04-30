import 'package:donation_tracker/constants.dart';
import 'package:donation_tracker/graphQlRequests.dart';
import 'package:donation_tracker/models/donation.dart';
import 'package:donation_tracker/models/usage.dart';
import 'package:graphql/client.dart';
import 'package:nhost_graphql_adapter/nhost_graphql_adapter.dart';
import 'package:nhost_sdk/nhost_sdk.dart';
import 'package:rxdart/rxdart.dart';

class NhostService {
  bool hasWriteAccess = false;

  late final GraphQLClient client;

  final nhostClient = NhostClient(baseUrl: nhostBaseUrl);

  late Stream<List<Donation>> donationTableUpdates;
  late Stream<List<Usage>> usageTableUpdates;
  late Stream<OperationException> errorUpdates;

  /// for testing we can pass in optional adminSecret and graphQL Endpoint
  /// will be otherwise retrieved via `fromEnvironment`
  NhostService() {
    client = createNhostGraphQLClient(graphQlEndPoint, nhostClient);
  }

  void startGraphQlSubscriptions() {
    /// unless you are not logged in, not all properties are acessible
    /// That's why we have to use differen't gql requests
    final donationDoc = gql(
        nhostClient.auth.authenticationState != AuthenticationState.loggedIn
            ? getDonation
            : getDonationLoggedIn);
    final usageDoc = gql(getUsage);

    final Stream<QueryResult> donationTableUpdateStream = client
        .subscribe(SubscriptionOptions(document: donationDoc))
        .asBroadcastStream();
    donationTableUpdates = donationTableUpdateStream
        .where((event) => (!event.hasException) && (event.data != null))
        .map((event) {
      final itemsAsMap = event.data![tableDonations] as List;
      return itemsAsMap.map((x) => Donation.fromMap(x!)).toList();
    });

    final Stream<QueryResult> usageTableUpdateStream = client
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

    errorUpdates.listen((event) {
      print(event.toString());
    });
  }

  Future addDonation(Donation donation) async {
    final options = MutationOptions(document: gql(insertDonation), variables: {
      'donator': donation.name,
      'value': donation.amount,
      'donation_date': donation.date,
      'donator_hidden': donation.hiddenName
    });

    final result = await client.mutate(options);

    if (result.hasException) {
      throw result.exception!;
    }
  }

  Future<bool> loginUser(String userName, String pwd) async {
    try {
      await nhostClient.auth.login(
        email: userName,
        password: pwd,
      );
      return true;
    } catch (e) {
      return false;
    }
  }
}
