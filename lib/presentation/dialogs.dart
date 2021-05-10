import 'package:donation_tracker/presentation/button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:layout/layout.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

const Radius _kDefaultBarTopRadius = Radius.circular(15);

class BarBottomSheet extends StatelessWidget {
  final Widget child;
  final Widget? control;
  final Clip? clipBehavior;
  final double? elevation;
  final ShapeBorder? shape;
  final bool expanded;
  final bool notTopControl;

  const BarBottomSheet(
      {Key? key,
      required this.child,
      this.control,
      this.clipBehavior,
      this.shape,
      this.elevation,
      this.expanded = false,
      this.notTopControl = true})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final displayAsDialog =
        context.layout.value(xs: false, sm: false, md: true);
    final borderRadius = displayAsDialog
        ? const BorderRadius.all(_kDefaultBarTopRadius)
        : const BorderRadius.only(
            topLeft: _kDefaultBarTopRadius,
            topRight: _kDefaultBarTopRadius,
          );
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Align(
        alignment: displayAsDialog ? Alignment.center : Alignment.bottomCenter,
        child: Column(
          mainAxisAlignment: displayAsDialog
              ? MainAxisAlignment.center
              : MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (displayAsDialog || !notTopControl)
              const SizedBox(
                height: 12,
              ),
            if (!displayAsDialog && !notTopControl) ...[
              Align(
                alignment: Alignment.bottomCenter,
                child: SafeArea(
                  bottom: false,
                  child: control ??
                      Container(
                        height: 6,
                        width: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                ),
              ),
              const SizedBox(height: 8)
            ],
            Flexible(
              fit: FlexFit.loose,
              child: Material(
                shape:
                    shape ?? RoundedRectangleBorder(borderRadius: borderRadius),
                clipBehavior: clipBehavior ?? Clip.hardEdge,
                elevation: elevation ?? 2,
                child: SizedBox(
                  width: double.infinity,
                  height: displayAsDialog || !expanded ? null : double.infinity,
                  child: MediaQuery.removePadding(
                    context: context,
                    removeTop: true,
                    child: child,
                  ),
                ),
              ),
            ),
            SizedBox(height: displayAsDialog ? 20 : 0),
          ],
        ),
      ),
    );
  }
}

class SheetFluidFormat extends FluidLayoutFormat {
  @override
  Map<LayoutBreakpoint, double> get maxFluidWidth => {
        LayoutBreakpoint.xs: 576,
        LayoutBreakpoint.sm: 720,
        LayoutBreakpoint.md: 720,
        LayoutBreakpoint.lg: 720,
        LayoutBreakpoint.xl: 720
      };

  @override
  LayoutValue<double> get margin => LayoutValue.constant(0);
}

Future<T?> showFluidBarModalBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  Color? backgroundColor,
  double? elevation,
  ShapeBorder? shape,
  double? closeProgressThreshold,
  Clip? clipBehavior,
  Color barrierColor = Colors.black87,
  bool bounce = true,
  bool expand = false,
  AnimationController? secondAnimation,
  Curve? animationCurve,
  bool useRootNavigator = false,
  bool isDismissible = true,
  bool enableDrag = true,
  Widget? topControl,
  Duration? duration,
  double? maxWidth,
  bool noTopControl = true,
}) async {
  assert(debugCheckHasMediaQuery(context));
  assert(debugCheckHasMaterialLocalizations(context));
  final result = await Navigator.of(context, rootNavigator: useRootNavigator)
      .push(ModalBottomSheetRoute<T>(
    builder: builder,
    bounce: bounce,
    closeProgressThreshold: closeProgressThreshold,
    containerBuilder: (_, __, child) => Layout(
      format: SheetFluidFormat(),
      child: FluidMargin(
        maxWidth: maxWidth,
        child: BarBottomSheet(
          notTopControl: noTopControl,
          control: topControl,
          clipBehavior: clipBehavior,
          shape: shape,
          elevation: elevation,
          expanded: expand,
          child: child,
        ),
      ),
    ),
    secondAnimationController: secondAnimation,
    expanded: expand,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    isDismissible: isDismissible,
    modalBarrierColor: barrierColor,
    enableDrag: enableDrag,
    animationCurve: animationCurve,
    duration: duration,
  ));
  return result;
}

Future<bool> showQueryDialog(BuildContext context, String title, String message,
    {String trueText = 'Yes', String falseText = 'Cancel'}) async {
  return (await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            Button(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              text: trueText,
            ),
            Button(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              text: falseText,
            ),
          ],
        );
      }))!;
}
