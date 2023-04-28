import 'package:stacked/stacked.dart';
import 'package:stacked_firebase_auth/stacked_firebase_auth.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:visual_ease_flutter/app/app.router.dart';

import '../../../app/app.bottomsheets.dart';
import '../../../app/app.locator.dart';
import '../../../app/app.logger.dart';
import '../../../models/appuser.dart';
import '../../../services/user_service.dart';

class LoginViewModel extends FormViewModel {
  final log = getLogger('LoginViewModel');
  final _authenticationService = locator<FirebaseAuthenticationService>();
  final _bottomSheetService = locator<BottomSheetService>();
  final _userService = locator<UserService>();
  final _navigationService = locator<NavigationService>();

  List<String> userTypes = ['blind', 'bystander'];

  void login() async {
    if (_role == null) {
      _bottomSheetService.showCustomSheet(
        variant: BottomSheetType.alert,
        title: "Not selected",
        description: "Select user role",
      );
      return null;
    }
    setBusy(true);
    final result = await _authenticationService.signInWithGoogle();
    log.i(result.errorMessage);
    if (result.user != null) {
      AppUser? _user = null; //await _userService.fetchUser();
      if (_user == null) {
        String? error = await _userService.createUpdateUser(
          AppUser(
              id: result.user!.uid,
              fullName: result.user!.displayName ?? "nil",
              photoUrl: result.user!.photoURL ?? "nil",
              regTime: DateTime.now(),
              email: result.user!.email!,
              userRole: _role ?? 'blind',
              latitude: 0.0,
              longitude: 0.0,
              place: ""),
        );
        if (error == null) {
          setBusy(false);
          _navigationService.replaceWithHomeView();
        } else {
          log.i("Firebase error");
          _bottomSheetService.showCustomSheet(
            variant: BottomSheetType.alert,
            title: "Upload Error",
            description: error,
          );
        }
      } else {
        setBusy(false);
        _navigationService.replaceWithHomeView();
      }
    } else {
      log.i("Error: ${result.errorMessage}");
      setBusy(false);
      _bottomSheetService.showCustomSheet(
        variant: BottomSheetType.alert,
        title: "Error",
        description: result.errorMessage ?? "Enter valid credentials",
      );
    }
  }

  String? _role;
  void setRole(String? value) {
    _role = value;
  }
}
