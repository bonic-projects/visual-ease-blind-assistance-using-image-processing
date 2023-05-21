import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:visual_ease_flutter/services/user_service.dart';

import '../../../app/app.bottomsheets.dart';
import '../../../app/app.locator.dart';
import '../../../app/app.logger.dart';
import '../../../app/app.router.dart';
import '../../../models/appuser.dart';
import '../../../services/firestore_service.dart';
import '../../common/app_strings.dart';

class HomeViewModel extends BaseViewModel {
  final log = getLogger('HomeViewModel');

  final _snackBarService = locator<SnackbarService>();
  final _navigationService = locator<NavigationService>();
  final _userService = locator<UserService>();
  final _firestoreService = locator<FirestoreService>();
  final _bottomSheetService = locator<BottomSheetService>();
  AppUser? get user => _userService.user;

  void onModelRdy() async {
    setBusy(true);
    if (user == null) {
      await _userService.fetchUser();
    }
    if (user!.userRole == "bystander") {
      await getBlinds();
    }
    setBusy(false);
  }

  List<AppUser> _blinds = <AppUser>[];
  List<AppUser> get blinds => _blinds;

  // Future
  Future getBlinds() async {
    _blinds = await _firestoreService.getUsersWithBystander();
    log.i("Users count: ${_blinds.length}");
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
    _navigationService.replaceWithLoginRegisterView();
  }

  void showBottomSheetUserSearch() async {
    final result = await _bottomSheetService.showCustomSheet(
      variant: BottomSheetType.notice,
      title: ksHomeBottomSheetTitle,
      description: ksHomeBottomSheetDescription,
    );
    if (result != null) {
      if (result.confirmed) {
        log.i("Bystander added: ${result.data.fullName}");
        _snackBarService.showSnackbar(
            message: "${result.data.fullName} added as bystander");
      }
      // _bottomSheetService.
    }
  }

  void openMapView(AppUser user) {
    _navigationService.navigateToMapView(user: user);
  }
}
