import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:tesis_app/modules/home/pages/entry_selection_page.dart';
import 'package:tesis_app/modules/login_without_qr/pages/ingreso_sin_qr_page.dart';
import 'package:tesis_app/modules/scan_qr/pages/scan_qr_page.dart';
import 'package:tesis_app/modules/scan_qr/widgets/reject_validation.dart';
import 'package:tesis_app/modules/scan_qr/widgets/succes_validation.dart';
import 'package:tesis_app/modules/scan_qr/widgets/validate%20_code.dart';
import 'package:tesis_app/shared/helpers/global_helper.dart';
import 'package:tesis_app/shared/widgets/inactivity_widget.dart';
import '../providers/functional_provider.dart';
import 'alert_modal.dart';
import 'page_modal.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({
    super.key,
    this.nameInterceptor,
    this.keyDismissPage,
    this.requiredStack = true,
  });

  final String? nameInterceptor;
  final GlobalKey<State<StatefulWidget>>? keyDismissPage;
  final bool requiredStack;

  @override
  State<MainLayout> createState() => _LayoutState();
}

class _LayoutState extends State<MainLayout> {
  String versionApp = '';
  late FunctionalProvider fp;

  @override
  void initState() {
    fp = Provider.of<FunctionalProvider>(context, listen: false);
    _versionApp();
    BackButtonInterceptor.add(
      _backButton,
      name: widget.nameInterceptor,
      context: context,
    );
    super.initState();
  }

  Future<bool> _backButton(bool button, RouteInfo info) async {
    if (widget.nameInterceptor == null) {
      return true;
    } else {
      if (mounted) {
        if (button) return false;
        if (fp.alerts.isNotEmpty) return false;
        fp.dismissPage(key: widget.keyDismissPage!);
      }
      return true;
    }
  }

  Future<void> _versionApp() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String version = packageInfo.version;
    setState(() => versionApp = version);
  }

  @override
  void dispose() {
    BackButtonInterceptor.removeByName(widget.nameInterceptor.toString());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final entrySelected = context.select<FunctionalProvider, EntryMethodItem>(
      (p) => p.entryMethodItem,
    );

    return InactivityGuard(
      timeoutSeconds: 30,
      warningSeconds: 10,
      child: Stack(
        children: [
          Scaffold(resizeToAvoidBottomInset: false, body: _body(entrySelected)),
          if (widget.requiredStack) const PageModal(),
          if (widget.requiredStack) const AlertModal(),
        ],
      ),
    );
  }

  Widget _body(EntryMethodItem selected) {
    switch (selected) {
      case EntryMethodItem.scanQr:
        return const ScanQrPage();
      case EntryMethodItem.noQr:
        return const IngresoQrFlowPage();
      case EntryMethodItem.validatingQr:
        return const ValidateCodeWidget();
      case EntryMethodItem.successValidation:
        return const SuccessValidation();
      case EntryMethodItem.rejectValidation:
        return const RejectValidation();
      case EntryMethodItem.none:
        return const EntrySelectionPage();
    }
  }
}
