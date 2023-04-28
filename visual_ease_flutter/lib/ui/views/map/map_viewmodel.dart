import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:stacked/stacked.dart';
import 'package:visual_ease_flutter/models/appuser.dart';

import '../../../app/app.locator.dart';
import '../../../app/app.logger.dart';
import '../../../services/firestore_service.dart';

class MapViewModel extends BaseViewModel {
  final log = getLogger('MapViewModel');
  final _firestoreService = locator<FirestoreService>();

  late GoogleMapController _mapController;
  late CameraPosition _cameraPosition;
  late LatLng _currentLocation;

  double get latitude => _currentLocation.latitude;
  double get longitude => _currentLocation.longitude;

  AppUser? _user;
  AppUser? get user => _user;
  void onModelReady(AppUser user) async {
    getUserLocation(user);
  }

  Future<void> getUserLocation(AppUser user) async {
    setBusy(true);
    _user = await _firestoreService.getUser(userId: user.id);
    if (_user != null) {
      // Set the current location and camera position
      _currentLocation = LatLng(_user!.latitude, _user!.longitude);
      _cameraPosition = CameraPosition(
        target: _currentLocation,
        zoom: 15.0,
      );

      setBusy(false);
      notifyListeners();
    }
  }

  void onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    _mapController
        .animateCamera(CameraUpdate.newCameraPosition(_cameraPosition));
  }
}
