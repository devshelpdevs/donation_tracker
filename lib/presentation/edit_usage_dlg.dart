import 'package:donation_tracker/_managers/donation_manager.dart';
import 'package:donation_tracker/constants.dart';
import 'package:donation_tracker/models/usage.dart';
import 'package:donation_tracker/presentation/dialogs.dart';
import 'package:donation_tracker/presentation/select_image_dlg.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:reactive_forms/reactive_forms.dart';

import 'button.dart';

Future<void> showAddEditUsageDlg(BuildContext context,
    {Usage? usage, bool waiting = false}) async {
  final form = FormGroup({
    'id': FormControl<int>(value: usage?.id),
    'receivers_name': FormControl<String>(value: usage?.name),
    'receivers_hidden_name': FormControl<String>(value: usage?.hiddenName),
    'usage': FormControl<String>(value: usage?.whatFor),
    'value':
        FormControl<double>(value: (usage?.amount ?? 0.0) / 100.0, validators: [
      Validators.required,
    ]),
    'usage_date': FormControl<DateTime>(
        value: usage?.date != null
            ? DateTime.tryParse(usage!.date!)
            : waiting
                ? null
                : DateTime.now()),
    'storage_image_name': FormControl<String>(value: usage?.image),
    'storage_image_name_person':
        FormControl<String>(value: usage?.imageReceiver),
  });
  final shouldSave = await showFluidBarModalBottomSheet<bool>(
      context: context,
      builder: (context) {
        return UsageDialogContent(
          form: form,
          newUsage: usage == null,
          isWaitingEntry: waiting,
        );
      });
  if (shouldSave == true) {
    final newUsage = Usage(
        id: form.value['id'] as int?,
        name: form.value['receivers_name'] as String?,
        hiddenName: form.value['receivers_hidden_name'] as String?,
        amount: ((form.value['value'] as double) * 100.0).toInt(),
        date: (form.value['usage_date'] as DateTime?)?.toIso8601String(),
        whatFor: form.value['usage'] as String,
        image: form.value['storage_image_name'] as String?,
        imageReceiver: form.value['storage_image_name_person'] as String?);
    GetIt.I<DonationManager>().upsertUsage!(newUsage);
  }
}

class UsageDialogContent extends StatefulWidget {
  const UsageDialogContent(
      {Key? key,
      required this.form,
      required this.newUsage,
      required this.isWaitingEntry})
      : super(key: key);

  final FormGroup form;
  final bool newUsage;
  final bool isWaitingEntry;

  @override
  _UsageDialogContentState createState() => _UsageDialogContentState();
}

class _UsageDialogContentState extends State<UsageDialogContent> {
  @override
  Widget build(BuildContext context) {
    late String headerText;
    if (widget.isWaitingEntry) {
      if (widget.newUsage) {
        headerText = 'Add new Waiting Cause';
      } else {
        headerText = 'Edit Waiting Cause';
      }
    } else {
      if (widget.newUsage) {
        headerText = 'Add new Usage';
      } else {
        headerText = 'Edit Usage';
      }
    }
    return Container(
      color: Colors.blue.shade900,
      child: ReactiveForm(
        formGroup: widget.form,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                headerText,
                style: Theme.of(context).textTheme.headline4,
              ),
              ReactiveTextField<int>(
                formControlName: 'id',
                decoration: InputDecoration(labelText: 'ID'),
                readOnly: true,
              ),
              SizedBox(height: 8),
              ReactiveTextField<String>(
                formControlName: 'receivers_name',
                decoration: InputDecoration(labelText: 'Recivers Name'),
              ),
              SizedBox(height: 8),
              ReactiveTextField<String>(
                formControlName: 'receivers_hidden_name',
                decoration: InputDecoration(labelText: 'Hidden Name'),
              ),
              SizedBox(height: 8),
              ReactiveTextField<double>(
                formControlName: 'value',
                decoration: InputDecoration(labelText: 'Amount'),
              ),
              SizedBox(height: 8),
              ReactiveTextField<String>(
                formControlName: 'usage',
                decoration: InputDecoration(labelText: 'Description'),
                maxLines: 10,
              ),
              SizedBox(height: 8),
              if (!widget.isWaitingEntry)
                ReactiveTextField<DateTime>(
                  formControlName: 'usage_date',
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'Usage Date',
                    suffixIcon: ReactiveDatePicker<DateTime>(
                      firstDate: DateTime.now().subtract(Duration(days: 30)),
                      lastDate: DateTime.now(),
                      formControlName: 'usage_date',
                      builder: (context, picker, child) {
                        return IconButton(
                          onPressed: picker.showPicker,
                          icon: const Icon(Icons.date_range),
                        );
                      },
                    ),
                  ),
                ),
              if (widget.isWaitingEntry && !widget.newUsage)
                Button(
                  onPressed: () {
                    widget.form.control('usage_date').value = DateTime.now();
                    Navigator.of(context).pop(true);
                  },
                  text: 'Mark as received',
                ),
              SizedBox(height: 8),
              ReactiveTextField<String>(
                readOnly: true,
                formControlName: 'storage_image_name',
                decoration: InputDecoration(
                  labelText: 'Image',
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.image_search,
                        ),
                        onPressed: () async {
                          final fileName =
                              await showSelectImageDlg(context, false);
                          if (fileName != null) {
                            widget.form.control('storage_image_name').value =
                                fileName;
                          }
                          setState(() {});
                        },
                      ),
                      if (widget.form.value['storage_image_name'] is String &&
                          (widget.form.value['storage_image_name'] as String)
                              .isNotEmpty)
                        Image.network(
                          buildImageLink(widget.form.value['storage_image_name']
                              as String),
                          width: 64,
                        )
                    ],
                  ),
                ),
              ),
              SizedBox(height: 8),
              ReactiveTextField<String>(
                formControlName: 'storage_image_name_person',
                decoration: InputDecoration(
                  labelText: 'Receiver\'s Image',
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.image_search,
                        ),
                        onPressed: () async {
                          final fileName =
                              await showSelectImageDlg(context, true);
                          if (fileName != null) {
                            widget.form
                                .control('storage_image_name_person')
                                .value = fileName;
                          }
                          setState(() {});
                        },
                      ),
                      if (widget.form.value['storage_image_name_person']
                              is String &&
                          (widget.form.value['storage_image_name_person']
                                  as String)
                              .isNotEmpty)
                        Image.network(
                          buildImageLink(widget.form
                              .value['storage_image_name_person'] as String),
                          width: 64,
                        )
                    ],
                  ),
                ),
              ),
              SizedBox(height: 48),
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 8.0, top: 8, right: 8, bottom: 9),
                      child: Text(
                        'Cancel',
                        style: Theme.of(context)
                            .textTheme
                            .headline5!
                            .copyWith(color: Colors.white),
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: const Color(0xff115FA7),
                      side:
                          BorderSide(color: const Color(0xff115FA7), width: 3),
                      shape: StadiumBorder(),
                    ),
                  ),
                  Button(
                    text: 'Save',
                    onPressed: () {
                      Navigator.of(context).pop(true);
                    },
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
