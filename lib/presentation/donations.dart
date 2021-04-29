import 'package:flutter/material.dart';
import 'package:get_it_mixin/get_it_mixin.dart';

import '../constants.dart';
import '../donation_manager.dart';
import '../utils.dart';

// ignore: use_key_in_widget_constructors
class Donations extends StatelessWidget with GetItMixin {
  @override
  Widget build(BuildContext context) {
    final donations = watchX((DonationManager m) => m.donationUpdates);
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DataTable(
            rows: donations
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
              const DataColumn(
                label: Text('Name', style: tableHeaderStyle),
              ),
              const DataColumn(
                label: Text('Date', style: tableHeaderStyle),
              ),
              const DataColumn(
                label: Text('Amount', style: tableHeaderStyle),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
