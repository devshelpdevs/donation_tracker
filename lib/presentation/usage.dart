import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it_mixin/get_it_mixin.dart';

import '../constants.dart';
import '../models/usage.dart';
import '../utils.dart';
import 'package:layout/layout.dart';

import 'usage/widgets/user_picture_for_has_date.dart';

class DonationUsages extends StatelessWidget with GetItMixin {
  final ValueNotifier<List<Usage>> usageUpdates;
  final bool hasUsageDates;

  DonationUsages(
      {Key? key, required this.usageUpdates, required this.hasUsageDates})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final usages =
        watch<ValueListenable<List<Usage>>, List<Usage>>(target: usageUpdates);
    final columnSpacing = LayoutValue.fromBreakpoint(
      xs: 4.0,
      md: 16.0,
      lg: 32.0,
      xl: 56.0,
    );
    final dataRowHeight = LayoutValue.fromBreakpoint(
      xs: 80.0,
      md: 64.0,
      lg: 56.0,
      xl: 48.0,
    );
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DataTable(
            columnSpacing: columnSpacing.resolve(context),
            dataRowHeight: dataRowHeight.resolve(context),
            columns: [
              if (hasUsageDates)
                const DataColumn(
                  label: Text('Date', style: tableHeaderStyle),
                ),
              const DataColumn(
                label: Text('Amount', style: tableHeaderStyle),
              ),
              const DataColumn(
                label: Text('Usage', style: tableHeaderStyle),
              ),
              const DataColumn(
                label: Text('Receiver', style: tableHeaderStyle),
              ),
            ],
            rows: usages
                .map((data) {
                  {
                    return DataRow(
                      cells: [
                        if (hasUsageDates)
                          DataCell(
                            Text(data.date?.toDateTime().format() ?? 'missing'),
                          ),
                        DataCell(
                          Text(
                            data.amount.toCurrency(),
                            textAlign: TextAlign.justify,
                          ),
                        ),
                        DataCell(
                          Expanded(
                            child: Text(
                              data.whatFor,
                            ),
                          ),
                        ),
                        DataCell(
                          UserPictureWhenHasDate(
                            data: data,
                            hasDate: hasUsageDates,
                          ),
                        ),
                      ],
                    );
                  }
                })
                .cast<DataRow>()
                .toList(),
          ),
        ],
      ),
    );
  }
}
