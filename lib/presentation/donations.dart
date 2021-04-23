import 'package:donation_tracker/donation_manager.dart';
import 'package:donation_tracker/models/donation.dart';
import 'package:donation_tracker/utils.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class Donations extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // return Subscription(
    //   builder: (QueryResult result) {
    //     if (result.hasException) {
    //       return Text(result.exception.toString());
    //     }

    // if (result.isLoading) {
    //   return Center(
    //     child: const CircularProgressIndicator(),
    //   );
    // }

    var total = 0;
    // final data = useMemoized<TotalData<Donator>>(() {
    //   var total = 0;
    //   final List<Donator> data = result.data![tableDonations]
    //       .map((element) {
    //         final donator = Donator.fromMap(element);
    //         total += donator.amount;
    //         return donator;
    //       })
    //       .cast<Donator>()
    //       .toList();
    //   return TotalData(data, total);
    // }, [result.timestamp]);

    return ValueListenableBuilder<List<Donation>>(
        valueListenable: GetIt.I<DonationManager>().donationUpdates,
        builder: (context, donations, child) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6),
                  child: Text('Total on current date: ${total.toCurrency()}',
                      style: Theme.of(context).textTheme.headline6,
                      textAlign: TextAlign.center),
                ),
                Divider(),
                DataTable(
                  rows: donations!
                      .map((data) {
                        return DataRow(cells: [
                          DataCell(Text(data.name)),
                          DataCell(Text(data.date.toDateTime().format())),
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
              ],
            ),
          );
        });
  }
}
