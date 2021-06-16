import 'dart:ui';

import 'package:deep_pick/deep_pick.dart';
import 'package:donation_tracker/constants.dart';
import 'package:donation_tracker/graphQlRequests.dart';
import 'package:donation_tracker/models/donation.dart';
import 'package:donation_tracker/models/usage.dart';
import 'package:graphql/client.dart';
import 'package:image/image.dart' as img;
import 'package:nhost_graphql_adapter/nhost_graphql_adapter.dart';
import 'package:nhost_sdk/nhost_sdk.dart';
import 'package:rxdart/rxdart.dart';

class StorageFileInfo {
  final String fileName;
  final DateTime lastChanged;

  String get imageLink => buildImageLink(fileName);
  StorageFileInfo(this.fileName, this.lastChanged);
}

class NhostService {
  late final GraphQLClient client;
  final bool hasWriteAccess;
  static final nhostClient = NhostClient(baseUrl: nhostBaseUrl);

  late Stream<List<Donation>> donationTableUpdates;
  late Stream<List<Usage>> usageTableUpdates;
  late Stream<OperationException> errorUpdates;

  NhostService([this.hasWriteAccess = false]) {
    print(nhostBaseUrl);
    print(server);
    client = createNhostGraphQLClient(graphQlEndPoint, nhostClient);
    startGraphQlSubscriptions();
  }

  Future<bool> loginUser(String userName, String pwd) async {
    try {
      await nhostClient.auth.login(
        email: userName,
        password: pwd,
      );
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  void startGraphQlSubscriptions() {
    /// unless you are not logged in, not all properties are acessible
    /// That's why we have to use differen't gql requests
    final donationDoc =
        gql(hasWriteAccess ? getDonationLoggedInRequest : getDonationsRequest);
    final usageDoc =
        gql(hasWriteAccess ? getUsageLoggedInRequest : getUsagesRequest);

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

  /// Donation CRUD Operations

  Future<int> addDonation(Donation donation) async {
    assert(hasWriteAccess, 'Your aren\'t logged in! This shouldn be possible');
    final options = MutationOptions(
      document: gql(insertDonationRequest),
      variables: {
        'donator': donation.name,
        'value': donation.amount,
        'donation_date': donation.date,
        'donator_hidden': donation.hiddenName
      },
    );

    final result = await client.mutate(options);

    if (result.hasException) {
      throw result.exception!;
    }
    return pick(
            result.data, 'insert_temp_money_donations', 'returning', 0, 'id')
        .asIntOrThrow();
  }

  Future<int> updateDonation(Donation donation) async {
    assert(hasWriteAccess, 'Your aren\'t logged in! This shouldn be possible');
    final options = MutationOptions(
      document: gql(updateDonationRequest),
      variables: {
        'id': donation.id,
        'donator': donation.name,
        'value': donation.amount,
        'donation_date': donation.date,
        'donator_hidden': donation.hiddenName
      },
    );

    final result = await client.mutate(options);

    if (result.hasException) {
      throw result.exception!;
    }
    return pick(result.data, 'update_temp_money_donations_by_pk', 'id')
        .asIntOrThrow();
  }

  Future deleteDonation(Donation donation) async {
    assert(hasWriteAccess, 'Your aren\'t logged in! This shouldn be possible');
    assert(donation.id != null);
    final options = MutationOptions(
      document: gql(deleteDonationRequest),
      variables: {
        'id': donation.id!,
      },
    );

    final result = await client.mutate(options);

    if (result.hasException) {
      throw result.exception!;
    }
  }

  Future<Donation> getDonation(int id) async {
    final options = QueryOptions(
        document: gql(getDonationRequestById),
        variables: {
          'id': id,
        },
        fetchPolicy: FetchPolicy.networkOnly);

    final result = await client.query(options);

    if (result.hasException) {
      throw result.exception!;
    }

    final data = result.data!['temp_money_donations_by_pk'];
    if (data == null) {
      throw Exception('Donation Id:$id not found!');
    }
    return Donation.fromMap(data);
  }

  /// Usage CRUD operations

  Future<int> addUsage(Usage usage) async {
    assert(hasWriteAccess, 'Your aren\'t logged in! This shouldn be possible');
    final options = MutationOptions(
      document: gql(insertUsageRequest),
      variables: {
        'storage_image_name': usage.image,
        'storage_image_name_person': usage.imageReceiver,
        'usage': usage.whatFor,
        'value': usage.amount,
        'usage_date': usage.date,
        'receivers_name': usage.name,
        'receiver_hidden_name': usage.hiddenName
      },
    );

    final result = await client.mutate(options);

    if (result.hasException) {
      throw result.exception!;
    }
    return pick(result.data, 'insert_temp_money_used_for_one', 'id')
        .asIntOrThrow();
  }

  Future<int> updateUsage(Usage usage) async {
    assert(hasWriteAccess, 'Your aren\'t logged in! This shouldn be possible');
    final options = MutationOptions(
      document: gql(updateUsageRequest),
      variables: {
        'id': usage.id,
        'storage_image_name': usage.image,
        'storage_image_name_person': usage.imageReceiver,
        'usage': usage.whatFor,
        'value': usage.amount,
        'usage_date': usage.date,
        'receivers_name': usage.name,
        'receiver_hidden_name': usage.hiddenName
      },
    );

    final result = await client.mutate(options);

    if (result.hasException) {
      throw result.exception!;
    }
    return pick(result.data, 'update_temp_money_used_for_by_pk', 'id')
        .asIntOrThrow();
  }

  Future deleteUsage(Usage usage) async {
    assert(usage.id != null);
    assert(hasWriteAccess, 'Your aren\'t logged in! This shouldn be possible');
    final options = MutationOptions(
      document: gql(deleteUsageRequest),
      variables: {
        'id': usage.id!,
      },
    );

    final result = await client.mutate(options);

    if (result.hasException) {
      throw result.exception!;
    }
  }

  Future<Usage> getUsage(int id) async {
    final options = QueryOptions(
        document: gql(getUsageRequestById),
        variables: {
          'id': id,
        },
        fetchPolicy: FetchPolicy.networkOnly);

    final result = await client.query(options);

    if (result.hasException) {
      throw result.exception!;
    }

    var data = result.data!['temp_money_used_for_by_pk'];
    if (data == null) {
      throw Exception('Usage Id:$id not found!');
    }
    return Usage.fromMap(data);
  }

  Future<List<StorageFileInfo>> getAvailableFiles([bool people = false]) async {
    return (await nhostClient.storage
            .getDirectoryMetadata(people ? 'public/people/' : 'public/'))
        .where((entry) =>
            ((entry.contentLength ?? 0) > 0) &&
            (!people ? !entry.key.contains('people') : true))
        .map((entry) {
      return StorageFileInfo(
        entry.key.substring(entry.key.indexOf('/') + 1),
        entry.lastModified!,
      );
    }).toList()
          ..sort((b, a) => a.lastChanged.compareTo(b.lastChanged));
  }

  Future<void> upLoadImage(
      {required bool people,
      required Image image,
      required String fileName}) async {
    final startOfEnding = fileName.lastIndexOf('.');
    late String uploadFileName;
    if (startOfEnding >= 0) {
      uploadFileName = fileName.substring(0, startOfEnding);
    } else {
      uploadFileName = fileName;
    }
    uploadFileName += '.jpg';
    final data = (await image.toByteData(format: ImageByteFormat.rawRgba))!
        .buffer
        .asInt8List();
    final encoder = img.JpegEncoder(quality: 60);
    final jpgData = encoder
        .encodeImage(img.Image.fromBytes(image.width, image.height, data));
    await nhostClient.storage.uploadBytes(
        filePath: (people ? 'public/people/' : 'public/') + uploadFileName,
        bytes: jpgData);
  }
}
