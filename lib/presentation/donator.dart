
import 'package:donation_tracker/constants.dart';
import 'package:donation_tracker/models/donator.dart';
import 'package:donation_tracker/models/total.dart';
import 'package:donation_tracker/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

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

        return HookBuilder(
          builder: (context) {
            final data = useMemoized<TotalData<Donator>>(() {
              var total = 0;
              final List<Donator> data = result.data![tableDonations]
                  .map((element) {
                final donator = Donator.fromMap(element);
                total += donator.amount;
                return donator;
              })
                  .cast<Donator>()
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
                        .map((data) {
                      return DataRow(cells: [
                        DataCell(Text(data.name)),
                        DataCell(Text(data.createdAt.toDateTime().format())),
                        DataCell(Text(data.amount.toCurrency())),
                      ]);
                    })
                        .cast<DataRow>()
                        .toList(),
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
                  ),
                ),
              ],
            );
          },
        );
      },
      options: SubscriptionOptions(
        document: gql(getDonation),
      ),
    );
  }
}
