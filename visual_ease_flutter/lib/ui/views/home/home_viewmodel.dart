import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:visual_ease_flutter/services/user_service.dart';

import '../../../app/app.locator.dart';
import '../../../app/app.logger.dart';
import '../../../app/app.router.dart';
import '../../../models/appuser.dart';

class HomeViewModel extends BaseViewModel {
  final log = getLogger('HomeViewModel');

  // final _snackBarService = locator<SnackbarService>();
  final _navigationService = locator<NavigationService>();
  final _userService = locator<UserService>();
  AppUser? get user => _userService.user;

  void onModelRdy() async {
    setBusy(true);
    if (user == null) {
      await _userService.fetchUser();
    }
    setBusy(false);
  }

  void openInAppView() {
    _navigationService.navigateTo(Routes.inAppView);
  }

  // void openHardwareView() {
  //   _navigationService.navigateTo(Routes.hardwareView);
  // }

  void openFaceTrainView() {
    _navigationService.navigateTo(Routes.faceRecView);
  }

  void openFaceTestView() {
    // _navigationService.navigateTo(Routes.faceTest);
  }

  void logout() {
    _userService.logout();
    _navigationService.replaceWithLoginView();
  }
}
