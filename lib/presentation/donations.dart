import 'package:donation_tracker/_managers/donation_manager.dart';
import 'package:donation_tracker/_services/nhost_service.dart';
import 'package:donation_tracker/constants.dart';
import 'package:donation_tracker/presentation/dialogs.dart';
import 'package:donation_tracker/presentation/edit_donation_dlg.dart';
import 'package:donation_tracker/utils.dart';
import 'package:flutter/material.dart';
import 'package:get_it_mixin/get_it_mixin.dart';

class Donations extends StatelessWidget with GetItMixin {
  @override
  Widget build(BuildContext context) {
    final hasWriteAccess = get<NhostService>().hasWriteAccess;
    final donations = watchX((DonationManager m) => m.donationUpdates);
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DataTable(
            rows: donations
                .map((data) {
                  return DataRow(cells: [
                    DataCell(Text(data.name ?? 'anonymous')),
                    DataCell(Text(data.date.toDateTime().format())),
                    DataCell(Text(data.amount.toCurrency())),
                    if (hasWriteAccess)
                      DataCell(
                        IconButton(
                          onPressed: () async {
                            await showAddEditDonationDlg(context, data);
                          },
                          icon: Icon(Icons.edit),
                        ),
                      ),
                    if (hasWriteAccess)
                      DataCell(IconButton(
                          onPressed: () async {
                            final shouldDelete = await showQueryDialog(
                                context,
                                'Warning!',
                                'Do you really want to delete this entry?');
                            if (shouldDelete) {
                              get<DonationManager>().deleteDonation!(data);
                            }
                          },
                          icon: Icon(Icons.delete)))
                  ]);
                })
                .cast<DataRow>()
                .toList(),
            columns: [
              DataColumn(
                label: const Text('Name', style: tableHeaderStyle),
              ),
              DataColumn(
                label: const Text('Date', style: tableHeaderStyle),
              ),
              DataColumn(
                label: const Text('Amount', style: tableHeaderStyle),
              ),
              if (hasWriteAccess)
                DataColumn(
                  label: const Text('Edit', style: tableHeaderStyle),
                ),
              if (hasWriteAccess)
                DataColumn(
                  label: const Text('Delete', style: tableHeaderStyle),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
