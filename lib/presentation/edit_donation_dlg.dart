import 'package:donation_tracker/_managers/donation_manager.dart';
import 'package:donation_tracker/models/donation.dart';
import 'package:donation_tracker/presentation/button.dart';
import 'package:donation_tracker/presentation/dialogs.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:reactive_forms/reactive_forms.dart';

Future<void> showAddEditDonationDlg(BuildContext context,
    [Donation? donation]) async {
  final form = FormGroup({
    'id': FormControl<int>(value: donation?.id),
    'donator': FormControl<String>(value: donation?.name),
    'donator_hidden': FormControl<String>(value: donation?.hiddenName),
    'value': FormControl<double>(
        value: (donation?.amount ?? 0.0) / 100.0,
        validators: [Validators.required, Validators.number]),
    'donation_date': FormControl<DateTime>(
        value: donation?.date != null
            ? DateTime.tryParse(donation!.date)
            : DateTime.now()),
  });
  final shouldSave = await showFluidBarModalBottomSheet<bool>(
      context: context,
      builder: (context) {
        return DonationDialogContent(
          form: form,
          newDonation: donation == null,
        );
      });
  if (shouldSave == true) {
    final newDonation = Donation(
        id: form.value['id'] as int?,
        name: form.value['donator'] as String?,
        hiddenName: form.value['donator_hidden'] as String?,
        amount: ((form.value['value'] as double) * 100.0).toInt(),
        date: (form.value['donation_date'] as DateTime).toIso8601String());
    GetIt.I<DonationManager>().upsertDonation!(newDonation);
  }
}

class DonationDialogContent extends StatelessWidget {
  const DonationDialogContent(
      {Key? key, required this.form, required this.newDonation})
      : super(key: key);

  final FormGroup form;
  final bool newDonation;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blue.shade900,
      child: ReactiveForm(
        formGroup: form,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                newDonation ? 'Add Donation' : 'Edit Donation',
                style: Theme.of(context).textTheme.headline4,
              ),
              ReactiveTextField<int>(
                formControlName: 'id',
                decoration: InputDecoration(labelText: 'ID'),
                readOnly: true,
              ),
              SizedBox(height: 8),
              ReactiveTextField<String>(
                formControlName: 'donator',
                decoration: InputDecoration(labelText: 'Name'),
              ),
              SizedBox(height: 8),
              ReactiveTextField<String>(
                formControlName: 'donator_hidden',
                decoration: InputDecoration(labelText: 'Hidden Name'),
              ),
              SizedBox(height: 8),
              ReactiveTextField<double>(
                formControlName: 'value',
                decoration: InputDecoration(labelText: 'Amount'),
              ),
              SizedBox(height: 8),
              ReactiveTextField<DateTime>(
                formControlName: 'donation_date',
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Birthday',
                  suffixIcon: ReactiveDatePicker<DateTime>(
                    firstDate: DateTime.now().subtract(Duration(days: 30)),
                    lastDate: DateTime.now(),
                    formControlName: 'donation_date',
                    builder: (context, picker, child) {
                      return IconButton(
                        onPressed: picker.showPicker,
                        icon: const Icon(Icons.date_range),
                      );
                    },
                  ),
                ),
              ),
              SizedBox(height: 48),
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Button(
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    },
                    text: 'Cancel',
                  ),
                  Button(
                    onPressed: () {
                      Navigator.of(context).pop(true);
                    },
                    text: 'Save',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
