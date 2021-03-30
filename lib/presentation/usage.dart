import 'package:donation_tracker/constants.dart';
import 'package:donation_tracker/models/total.dart';
import 'package:donation_tracker/models/usage.dart';
import 'package:donation_tracker/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

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

        return HookBuilder(
          builder: (context) {
            final data = useMemoized<TotalData<Usage>>(() {
              var total = 0;
              final List<Usage> data = result.data![tableUsages]
                  .map((element) {
                    final donator = Usage.fromMap(element);
                    total += donator.amount;
                    return donator;
                  })
                  .cast<Usage>()
                  .toList();
              return TotalData(data, total);
            }, [result.timestamp]);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6),
                  child: Text('Total on current date: ${data.total.toCurrency()}', style: Theme.of(context).textTheme.headline6, textAlign: TextAlign.center),
                ),
                Divider(),
                Expanded(
                  child: DataTable(
                    rows: data.items
                        .map(
                          (data) {
                            return DataRow(
                              cells: [
                                DataCell(Text(data.createdAt.toDateTime().format())),
                                DataCell(Text(data.amount.toCurrency())),
                                DataCell(Text(data.whatFor)),
                                DataCell(
                                  ConstrainedBox(
                                    constraints: const BoxConstraints(maxWidth: 100, maxHeight: 60),
                                    child: data.imageLink == null
                                        ? Container()
                                        : Image.network(
                                            data.imageLink!,
                                            loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                                              if (loadingProgress == null) return child;
                                              return Center(
                                                child: CircularProgressIndicator(
                                                  value: loadingProgress.expectedTotalBytes != null
                                                      ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                                      : null,
                                                ),
                                              );
                                            },
                                            fit: BoxFit.contain,
                                          ),
                                  ),
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          content: Image.network(
                                            data.imageLink!,
                                            loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                                              if (loadingProgress == null) return child;
                                              return Center(
                                                child: CircularProgressIndicator(
                                                  value: loadingProgress.expectedTotalBytes != null
                                                      ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                                      : null,
                                                ),
                                              );
                                            },
                                            fit: BoxFit.contain,
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: Text('Close'),
                                            )
                                          ],
                                        );
                                      },
                                    );
                                  },
                                ),
                              ],
                            );
                          },
                        )
                        .cast<DataRow>()
                        .toList(),
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
                  ),
                ),
              ],
            );
          },
        );
      },
      options: SubscriptionOptions(
        document: gql(getUsage),
      ),
    );
  }
}
