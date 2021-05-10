import 'dart:io';

import 'package:cropper/cropper.dart';
import 'package:donation_tracker/_services/nhost_service.dart';
import 'package:donation_tracker/presentation/button.dart';
import 'package:donation_tracker/presentation/dialogs.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/gestures/events.dart';
import 'package:get_it/get_it.dart';

Future<String?> showSelectImageDlg(
  BuildContext context,
  bool startShowingPeople,
) {
  return showFluidBarModalBottomSheet<String>(
    context: context,
    builder: (context) {
      return SelectImageDlg(
        startShowingPeople: startShowingPeople,
      );
    },
    enableDrag: false,
  );
}

class SelectImageDlg extends StatefulWidget {
  final bool startShowingPeople;

  const SelectImageDlg({Key? key, required this.startShowingPeople})
      : super(key: key);
  @override
  _SelectImageDlgState createState() => _SelectImageDlgState();
}

class _SelectImageDlgState extends State<SelectImageDlg> {
  bool showPeople = false;
  List<StorageFileInfo> files = [];
  XFile? fileToUpLoad;
  CropController cropController = CropController(scale: 1.0);
  TextEditingController textController = TextEditingController();

  @override
  void initState() {
    showPeople = widget.startShowingPeople;
    getImagesFromServer();
    super.initState();
  }

  void getImagesFromServer() {
    GetIt.I<NhostService>().getAvailableFiles(showPeople).then((files) {
      if (mounted) {
        setState(() {
          this.files = files;
        });
      }
    });
  }

  Widget buildSelector() {
    return CupertinoSegmentedControl<bool>(
        unselectedColor: Colors.grey.shade400,
        children: {
          false: Padding(
            child: Text('Stock Images'),
            padding: const EdgeInsets.all(8),
          ),
          true: Padding(
            child: Text('People'),
            padding: const EdgeInsets.all(8),
          ),
        },
        groupValue: showPeople,
        onValueChanged: (newVal) async {
          showPeople = newVal;
          files = await GetIt.I<NhostService>().getAvailableFiles(showPeople);
          setState(() {});
        });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      color: Colors.blue.shade900,
      child: LayoutBuilder(builder: (context, constraints) {
        final imagesize = constraints.maxWidth / 4;
        return fileToUpLoad == null
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Select Image',
                          style: Theme.of(context).textTheme.headline4),
                      buildSelector()
                    ],
                  ),
                  SizedBox(height: 16),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Wrap(
                        children: files
                            .map<Widget>((e) => ImageEntry(
                                  imagesize: imagesize,
                                  fileInfo: e,
                                  onImageSelected: (fileName) {
                                    Navigator.of(context).pop(fileName);
                                  },
                                ))
                            .toList(),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 24,
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Button(
                        onPressed: () {
                          Navigator.of(context).pop(null);
                        },
                        text: 'Cancel',
                      ),
                      Button(
                        onPressed: () async {
                          await upLoadImage();
                        },
                        text: 'Upload',
                      ),
                    ],
                  ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Crop Image',
                          style: Theme.of(context).textTheme.headline4),
                      Spacer(),
                      Text('upload to:'),
                      buildSelector()
                    ],
                  ),
                  SizedBox(height: 24),
                  Expanded(
                    child: Listener(
                      behavior: HitTestBehavior.opaque,
                      onPointerSignal: handleScrollWheel,
                      child: Crop(
                          helper: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                          ),
                          child: Image.file(
                            File(fileToUpLoad!.path),
                            fit: BoxFit.cover,
                          ),
                          controller: cropController),
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: textController,
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Button(
                        onPressed: () {
                          setState(() {
                            fileToUpLoad = null;
                          });
                        },
                        text: 'Cancel',
                      ),
                      Button(
                        onPressed: () async {
                          await cropAndUpload();
                        },
                        text: 'Cropp & Upload',
                      ),
                    ],
                  ),
                ],
              );
      }),
    );
  }

  Future<void> upLoadImage() async {
    final typeGroup = XTypeGroup(label: 'images', extensions: ['jpg', 'png']);
    fileToUpLoad = await openFile(acceptedTypeGroups: [typeGroup]);
    if (fileToUpLoad == null) {
      return;
    }
    textController.text = fileToUpLoad!.name;
    setState(() {});
  }

  void handleScrollWheel(PointerSignalEvent event) {
    if (event is PointerScrollEvent) {
      cropController.scale =
          (cropController.scale + event.scrollDelta.dy.sign * 0.2).clamp(0, 10);
    }
  }

  Future cropAndUpload() async {
    final croppedImage = await cropController.crop();
    //TODO error handling & busy state probably move to a Command
    await GetIt.I<NhostService>().upLoadImage(
        people: showPeople, image: croppedImage, fileName: textController.text);
    files = await GetIt.I<NhostService>().getAvailableFiles(showPeople);
    setState(() {
      fileToUpLoad = null;
    });
  }
}

class ImageEntry extends StatelessWidget {
  const ImageEntry({
    Key? key,
    required this.imagesize,
    required this.fileInfo,
    required this.onImageSelected,
  }) : super(key: key);

  final double imagesize;
  final StorageFileInfo fileInfo;
  final ValueChanged<String> onImageSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: imagesize,
      child: InkWell(
        onTap: () => onImageSelected(fileInfo.fileName),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AspectRatio(
              aspectRatio: 1.0,
              child: Image.network(
                fileInfo.imageLink,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              fileInfo.fileName.replaceAll('%20', ' '),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }
}
