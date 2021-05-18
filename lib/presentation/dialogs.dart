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
  bool useRootNavigator = true,
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

Future<UserCredentials?> showLoginDialog({
  required BuildContext context,
  String title = 'Login',
  String okButtonText = 'OK',
  String? cancelButtonText,
  String usernameLabel = 'User name',
  String passwordLabel = 'Password',
  String? header,
  String? userNamePrefill,
  String? Function(String)? usernameValidator,
  String? Function(String)? passwordValidator,
  bool barrierDismissible = false,
}) async {
  return await showDialog<UserCredentials>(
      context: context,
      builder: (context) => LoginWidget(
            dialogConfig: LoginDialogConfig(
              title: title,
              okButtonText: okButtonText,
              cancelButtonText: cancelButtonText,
              message: header,
              userNameLabel: usernameLabel,
              passwordLabel: passwordLabel,
              usernameValidator: usernameValidator,
              userNamePrefill: userNamePrefill,
              passwordValidator: passwordValidator,
            ),
          ));
}

class UserCredentials {
  final String userName;
  final String password;

  const UserCredentials({required this.userName, required this.password});
}

class LoginDialogConfig {
  final String? title;
  final String? message;
  final String? userNamePrefill;
  final String userNameLabel;
  final String passwordLabel;
  final String okButtonText;
  final String? cancelButtonText;
  final String? Function(String password)? usernameValidator;
  final String? Function(String password)? passwordValidator;

  LoginDialogConfig({
    this.title,
    this.message,
    required this.userNameLabel,
    required this.passwordLabel,
    required this.okButtonText,
    this.cancelButtonText,
    this.userNamePrefill,
    this.usernameValidator,
    this.passwordValidator,
  });
}

class LoginWidget extends StatefulWidget {
  final LoginDialogConfig dialogConfig;
  const LoginWidget({Key? key, required this.dialogConfig}) : super(key: key);

  @override
  LoginWidgetState createState() => LoginWidgetState();
}

class LoginWidgetState extends State<LoginWidget> {
  late TextEditingController userNameController;
  late TextEditingController passwordController;

  @override
  void initState() {
    userNameController =
        TextEditingController(text: widget.dialogConfig.userNamePrefill);
    passwordController = TextEditingController();
    super.initState();
  }

  String? passwordErrorText;
  String? userNameErrorText;

  @override
  Widget build(BuildContext context) {
    final dlgConfig = widget.dialogConfig;

    void onOk() {
      final passwordValidator = dlgConfig.passwordValidator ??
          (s) => s.isEmpty ? 'Password is mandatory!' : null;
      passwordErrorText = passwordValidator(passwordController.text);

      final userNameValidator = dlgConfig.usernameValidator ??
          (s) => s.isEmpty ? 'User name is mandatory!' : null;
      userNameErrorText = userNameValidator(userNameController.text);

      if (passwordErrorText != null || userNameErrorText != null) {
        setState(() {});
      } else {
        Navigator.of(context).pop(UserCredentials(
            userName: userNameController.text.trim(),
            password: passwordController.text));
      }
    }

    return AlertDialog(
      title: Text(dlgConfig.title ?? ''),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (dlgConfig.message != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Text(dlgConfig.message!),
              ),
            Text(dlgConfig.userNameLabel),
            TextField(
                keyboardType: TextInputType.emailAddress,
                controller: userNameController,
                decoration: InputDecoration(errorText: userNameErrorText)),
            const SizedBox(height: 16.0),
            Text(dlgConfig.passwordLabel),
            TextField(
              keyboardType: TextInputType.text,
              controller: passwordController,
              decoration: InputDecoration(errorText: passwordErrorText),
              obscureText: true,
              onSubmitted: (_) => onOk(),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        if (dlgConfig.cancelButtonText != null)
          Button(
            onPressed: () {
              Navigator.of(context).pop(null);
            },
            text: dlgConfig.cancelButtonText!,
          ),
        Button(
          onPressed: onOk,
          text: dlgConfig.okButtonText,
        ),
      ],
    );
  }
}
