import 'package:animate_do/animate_do.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart' hide Title;
import '../../env/theme/app_theme.dart';
import '../helpers/responsive.dart';
import '../providers/functional_provider.dart';
import 'filled_button.dart';
import 'text_button.dart';

Text titleAlerts({
  required String title,
  required Color color,
  required double fontSize,
}) {
  return Text(
    title,
    style: TextStyle(
      fontSize: fontSize, //19/,
      fontWeight: FontWeight.bold,
      color: color,
    ),
  );
}

Padding messageAlerts(Size size, {required String message}) {
  return Padding(
    padding: EdgeInsets.symmetric(horizontal: size.width * 0.02),
    child: Text(
      message,
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppTheme.hinText,
      ),
    ),
  );
}

class AlertLoading extends StatefulWidget {
  const AlertLoading({super.key});

  @override
  _AlertLoadingState createState() => _AlertLoadingState();
}

class _AlertLoadingState extends State<AlertLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.5, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Brightness theme = Theme.of(context).brightness;
    return Material(
      type: MaterialType.transparency,
      child: Opacity(
        opacity: 0.85,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: SizedBox(
            height: 250,
            width: 200,
            // height: 130,
            // width: 150,
            child: Stack(
              alignment: Alignment.center,
              children: [
                FadeTransition(
                  opacity: _animation,
                  child: Image.asset(
                     AppTheme.logoAppCargandoWhite,    
                    fit: BoxFit.cover,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : null,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AlertGeneric extends StatefulWidget {
  final bool dismissable;
  final GlobalKey? keyToClose;
  final Widget content;
  final bool? heightOption;
  final double? left;
  final double? right;

  const AlertGeneric({
    super.key,
    this.left = 15,
    this.right = 15,
    required this.content,
    this.heightOption = false,
    this.dismissable = false,
    this.keyToClose,
  });

  @override
  State<AlertGeneric> createState() => _AlertGenericState();
}

class _AlertGenericState extends State<AlertGeneric> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Stack(
      children: [
        Container(
          // padding: EdgeInsets.only(
          //   left: widget.left ?? 15,
          //   right: widget.left ?? 15,
          //   top: 15,
          //   bottom: 15,
          // ),
          width: double.infinity,
          height: widget.heightOption == true ? size.height * 0.54 : null,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: AppTheme.white,
          ),
          child: Material(
            type: MaterialType.transparency,
            child: widget.content,
          ),
        ),
        if (widget.dismissable)
          Positioned(
            top: -3,
            right: 0,
            child: SizedBox(
              height: 50,
              width: 50,
              child: CloseButton(
                style: const ButtonStyle(
                  iconColor: WidgetStatePropertyAll(AppTheme.hinText),
                ),
                onPressed: () {
                  final fp = Provider.of<FunctionalProvider>(
                    context,
                    listen: false,
                  );
                  fp.dismissAlert(key: widget.keyToClose!);
                },
              ),
            ),
          ),
      ],
    );
  }
}

class AlertTemplate extends StatefulWidget {
  final Widget content;
  final GlobalKey keyToClose;
  final bool? dismissAlert;
  final bool? animation;
  final double? padding;

  const AlertTemplate({
    super.key,
    required this.content,
    required this.keyToClose,
    this.dismissAlert = false,
    this.animation = true,
    this.padding = 20,
  });

  @override
  State<AlertTemplate> createState() => _AlertTemplateState();
}

class _AlertTemplateState extends State<AlertTemplate> {
  late GlobalKey keySummoner;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive.of(context);

    return ZoomOut(
      controller: (controller) {
        //animateController = controller;
        //debugPrint('controller de animacion ZoomIn: $controller' );
        // _typeAnimation('zoom-in', animationController);
      },
      animate: false,
      duration: const Duration(milliseconds: 200),
      child: Scaffold(
        backgroundColor: Colors.black45,
        body: Stack(
          children: [
            GestureDetector(
              onTap: () {
                final fp = Provider.of<FunctionalProvider>(
                  context,
                  listen: false,
                );
                widget.dismissAlert == true
                    ? fp.dismissAlert(key: widget.keyToClose)
                    : null;
              },
              child: Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.transparent,
              ),
            ),
            Container(
              padding: EdgeInsets.all(
                responsive.isTablet ? responsive.wp(14) : widget.padding ?? 20,
              ),
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // /const Expanded(child: SizedBox()),
                      widget.animation == true
                          ? FadeInUpBig(
                              animate: true,
                              controller: (controller) {
                                //animateController = controller;
                                //debugPrint('controller de animacion FadeInUpBig');
                                //_typeAnimation('fade-in-up-big', animetionControllerContent);
                              },
                              duration: const Duration(milliseconds: 400),
                              child: widget.content,
                            )
                          : widget.content,
                      // const Expanded(child: SizedBox()),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SuccessGeneric extends StatelessWidget {
  final GlobalKey keyToClose;
  final void Function()? onPressed;
  final String? message;
  final String? title;

  const SuccessGeneric({
    super.key,
    required this.keyToClose,
    this.onPressed,
    this.title,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final responsive = Responsive(context);

    return Column(
      children: [
        SizedBox(height: size.height * 0.015),
        SvgPicture.asset(AppTheme.iconCheckPath),
        const SizedBox(height: 25),
        titleAlerts(
          fontSize: responsive.dp(1.98),
          title: title ?? '¡Estamos listos!',
          color: AppTheme.primaryColor,
        ),
        SizedBox(height: size.height * 0.015),
        messageAlerts(size, message: message ?? 'mensaje'),
        SizedBox(height: size.height * 0.025),
        FilledButtonWidget(
          borderRadius: 15,
          width: size.width * 0.05,
          color: AppTheme.primaryColor,
          textButtonColor: AppTheme.white,
          text: 'Aceptar',
          onPressed:
              onPressed ??
              () {
                final fp = Provider.of<FunctionalProvider>(
                  context,
                  listen: false,
                );
                fp.dismissAlert(key: keyToClose);
              },
        ),
        SizedBox(height: size.height * 0.01),
      ],
    );
  }
}

class ConfirmContent extends StatelessWidget {
  final String message;
  final void Function() confirm;
  final void Function() cancel;
  const ConfirmContent({
    super.key,
    required this.message,
    required this.confirm,
    required this.cancel,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Column(
      children: [
        SizedBox(height: size.height * 0.015),
        SvgPicture.asset(AppTheme.iconCautionPath),
        const SizedBox(height: 15),
        messageAlerts(size, message: message),
        const SizedBox(height: 25),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButtonWidget(onPressed: cancel, nameButton: 'Cancelar'),
            SizedBox(width: size.width * 0.08),
            FilledButtonWidget(
              onPressed: confirm,
              width: size.width * 0.05,
              text: 'Confirmar',
              textButtonColor: AppTheme.white,
            ),
          ],
        ),
        SizedBox(height: size.height * 0.01),
      ],
    );
  }
}

class IncompleteParams extends StatelessWidget {
  final GlobalKey keyToClose;
  final String message;
  const IncompleteParams({
    super.key,
    required this.keyToClose,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final responsive = Responsive(context);

    return Column(
      children: [
        SizedBox(height: size.height * 0.015),
        SvgPicture.asset(AppTheme.iconCautionPath),
        SizedBox(height: size.height * 0.03),
        titleAlerts(
          title: '¡Oops, algo falló!',
          color: AppTheme.primaryColor,
          fontSize: responsive.dp(1.98),
        ),
        SizedBox(height: size.height * 0.04),
        messageAlerts(size, message: message),
        SizedBox(height: size.height * 0.025),
        FilledButtonWidget(
          textButtonColor: AppTheme.white,
          borderRadius: 20,
          width: size.width * 0.05,
          color: AppTheme.primaryColor,
          text: 'Aceptar',
          onPressed: () {
            final fp = Provider.of<FunctionalProvider>(context, listen: false);
            fp.dismissAlert(key: keyToClose);
          },
        ),
        SizedBox(height: size.height * 0.01),
      ],
    );
  }
}

class NotificationGeneric extends StatelessWidget {
  const NotificationGeneric({
    super.key,
    this.keyToClose,
    this.isError = false,
    required this.message,
    this.isWarning = false,
  });
  final GlobalKey? keyToClose;
  final bool? isError;
  final String message;
  final bool? isWarning;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return SafeArea(
      child: Material(
        type: MaterialType.transparency,
        child: GestureDetector(
          onTap: () {
            final fp = Provider.of<FunctionalProvider>(context, listen: false);
            fp.dismissNotification(key: keyToClose!);
          },
          child: FadeInDownBig(
            duration: const Duration(milliseconds: 700),
            child: Container(
              width: size.width,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.grey,
                    spreadRadius: 0.5,
                    blurRadius: 4.5,
                  ),
                ],
                color: isWarning == true
                    ? AppTheme.actionWarning
                    : (isError!
                          ? AppTheme.actionError
                          : AppTheme.actionSuccessLight),
              ),
              margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: isWarning == true
                    ? CrossAxisAlignment.center
                    : CrossAxisAlignment.start,
                children: [
                  isWarning == true
                      ? const Icon(
                          Icons.warning_amber_rounded,
                          color: AppTheme.white,
                          size: 23,
                        )
                      : (isError!
                            ? const Icon(
                                Icons.error_outline,
                                color: AppTheme.white,
                                size: 23,
                              )
                            : const Icon(
                                Icons.check_circle,
                                color: AppTheme.dark,
                                size: 23,
                              )),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      textAlign: TextAlign.start,
                      message,
                      style: TextStyle(
                        color: isWarning == true
                            ? AppTheme.white
                            : (isError! ? AppTheme.white : AppTheme.dark),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 2),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class WarningGeneric extends StatelessWidget {
  final String? title;
  final String message;
  final void Function() function;
  final void Function()? cancel;
  final String? namePage;
  final bool? isNamePage;

  const WarningGeneric({
    super.key,
    required this.message,
    required this.function,
    this.namePage = '',
    this.isNamePage = true,
    this.title,
    this.cancel,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final responsive = Responsive(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: const Color(0xFFfff7b538),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              SizedBox(height: size.height * 0.015),
              SvgPicture.asset(
                AppTheme.iconCautionPath,
                colorFilter: ColorFilter.mode(AppTheme.white, BlendMode.srcIn),
              ),
              const SizedBox(height: 15),
              Visibility(
                visible: title != null,
                child: titleAlerts(
                  title: title ?? '',
                  fontSize: responsive.dp(1.98),
                  color: AppTheme.white,
                ),
              ),
              const SizedBox(height: 15),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: size.width * 0.027),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    text: message,
                    style: TextStyle(
                      fontSize: responsive.isTablet ? responsive.dp(1.67) : 16,
                      fontWeight: FontWeight.w400,
                      color: AppTheme.white,
                    ),
                    children: <TextSpan>[
                      isNamePage == true
                          ? TextSpan(
                              text: ' $namePage',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.white,
                              ),
                            )
                          : const TextSpan(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 25),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (cancel != null)
              TextButtonWidget(
                onPressed: cancel,
                nameButton: 'Cancelar',
                fontSize: responsive.isTablet ? responsive.dp(1.6) : 16,
              ),
            if (cancel != null) SizedBox(width: size.width * 0.08),
            FilledButtonWidget(
              color: AppTheme.primaryColor,
              onPressed: function,
              width: size.width * 0.05,

              text: 'Aceptar',
            ),
          ],
        ),
        SizedBox(height: size.height * 0.01),
      ],
    );
  }
}


class ErrorGeneric extends StatelessWidget {
  final GlobalKey keyToClose;
  final String message;
  final String? messageButton;
  final void Function()? onPress;
  final bool? success;

  const ErrorGeneric(
      {super.key,
      required this.message,
      required this.keyToClose,
      this.messageButton,
      this.success = false,
      this.onPress});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Column(
      children: [
        SizedBox(height: size.height * 0.015),
        SvgPicture.asset(success == true
            ? AppTheme.iconErrorPath
            : AppTheme.iconCautionPath),
        SizedBox(height: size.height * 0.03),
        success == true
            ? titleAlerts(
                title: '¡Oops, algo falló!', color: AppTheme.actionError, fontSize: 13)
            : titleAlerts(title: '¡Atención!', color: AppTheme.actionWarning, fontSize: 13),
        SizedBox(height: size.height * 0.025),
        messageAlerts(size, message: message),
        SizedBox(height: size.height * 0.03),
        FilledButtonWidget(
          textButtonColor: AppTheme.white,
          borderRadius: 20,
          width: size.width * 0.05,
          color:
              success == true ? AppTheme.actionError : AppTheme.actionWarning,
          text: messageButton ?? 'Aceptar',
          onPressed: (onPress != null)
              ? onPress
              : () async {
                  final fp =
                      Provider.of<FunctionalProvider>(context, listen: false);
                  fp.dismissAlert(key: keyToClose);
                },
        ),
        SizedBox(height: size.height * 0.01),
      ],
    );
  }
}