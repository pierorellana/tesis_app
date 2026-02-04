import 'package:flutter/material.dart';
import 'package:tesis_app/modules/login_without_qr/models/catalogue_response.dart';
import '../helpers/global_helper.dart';
import '../widgets/alert_template.dart';

class FunctionalProvider extends ChangeNotifier {
  List<Widget> alerts = [];
  List<Widget> pages = [];
  List<Widget> notifications = [];
  Widget? _floatingActionButton;

  Widget? getFloatingActionButton() => _floatingActionButton;

  Future<void> Function()? _refreshPage;

  EntryMethodItem entryMethodItem = EntryMethodItem.none;

  String? lastQrValue;

  bool isFaceAuthorized = true;

  List<CatalogueResponse> catalogue = [];

  void showAlert({
    required GlobalKey key,
    required Widget content,
    bool closeAlert = false,
    bool animation = true,
    double padding = 20,
    bool addPostFrameCallback = true,
  }) {
    final newAlert = Container(
      key: key,
      color: Colors.transparent,
      child: AlertTemplate(
        content: content,
        keyToClose: key,
        dismissAlert: closeAlert,
        animation: animation,
        padding: padding,
      ),
    );
    alerts.add(newAlert);
    notifyListeners();
  }

  void addPage({required GlobalKey key, required Widget content}) {
    pages.add(content);
    notifyListeners();
  }

  void dismissPage({required GlobalKey key}) {
    pages.removeWhere((page) => key == page.key);
    notifyListeners();
  }

  void dismissAlert({required GlobalKey key}) {
    alerts.removeWhere((alert) => key == alert.key);
    notifyListeners();
  }

  Future<void> addNotification({
    required GlobalKey key,
    required Widget content,
    int seconds = 4,
  }) async {
    notifications.add(Container(key: key, child: content));
    notifyListeners();
    await Future.delayed(Duration(seconds: seconds));
    dismissNotification(key: key);
  }

  void dismissNotification({required GlobalKey key}) {
    // GlobalHelper.logger.w('key: $key');
    notifications.removeWhere((notification) => key == notification.key);
    notifyListeners();
  }

  void clearAllAlert() {
    alerts = [];
    pages = [];
    notifyListeners();
  }

  Future<void> Function()? get refreshPage => _refreshPage;

  void setRefreshPage(Future<void> Function()? refreshPageIn) {
    _refreshPage = refreshPageIn;
    notifyListeners();
  }

  void clearRefreshPage() {
    _refreshPage = null;
    notifyListeners();
  }

  void setEntryMethodItem(EntryMethodItem value) {
    if (entryMethodItem == value) return;
    entryMethodItem = value;

    _refreshPage = null;
    _floatingActionButton = const SizedBox.shrink();

    notifyListeners();
  }

  void setLastQrValue(String value) {
    lastQrValue = value;
    notifyListeners();
  }

  void setFaceAuthorized(bool value) {
    if (isFaceAuthorized == value) return;
    isFaceAuthorized = value;
    notifyListeners();
  }

  void setCatalogue(List<CatalogueResponse> list) {
    catalogue = list;
    notifyListeners();
  }
}
