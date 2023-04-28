import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';

import 'package:stacked/stacked.dart';
import 'package:stacked_firebase_auth/stacked_firebase_auth.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:visual_ease_flutter/services/camera_service.dart';
import 'package:visual_ease_flutter/services/location_service.dart';
import 'package:visual_ease_flutter/services/storage_service.dart';

import '../../../app/app.bottomsheets.dart';
import '../../../app/app.locator.dart';
import '../../../app/app.logger.dart';
import '../../../services/imageprocessing_service.dart';

import 'package:perfect_volume_control/perfect_volume_control.dart';

import '../../../services/regula_service.dart';
import '../../../services/tts_service.dart';

class InAppViewModel extends BaseViewModel {
  final log = getLogger('InAppViewModel');
  final _bottomSheetService = locator<BottomSheetService>();

  // final _snackBarService = locator<SnackbarService>();
  // final _navigationService = locator<NavigationService>();
  final TTSService _ttsService = locator<TTSService>();
  final ImageProcessingService _imageProcessingService =
      locator<ImageProcessingService>();
  final _ragulaService = locator<RegulaService>();
  final _storageService = locator<StorageService>();
  final _authService = locator<FirebaseAuthenticationService>();
  final _camService = locator<CameraService>();
  final _locService = locator<LocationService>();

  CameraController get controller => _camService.controller;
  late StreamSubscription<double> _subscription;
  void onModelReady() async {
    _subscription = PerfectVolumeControl.stream.listen((value) {
      if (_image == null && !isBusy) {
        captureImageAndLabel();
      }
      if (_image != null && !isBusy) {
        log.i("Volume button got!");
        getLabel();
      }
    });
    setBusy(true);
    await _camService.initCam();
    setBusy(false);
    _locService.initialise();
  }

  Future captureImageAndLabel() async {
    _image = await _camService.takePicture();
    getLabel();
  }

  @override
  void dispose() {
    // call your function here
    _locService.dispose();
    _camService.dispose();
    _subscription.cancel();
    super.dispose();
  }

  final ImagePicker _picker = ImagePicker();
  XFile? _imageFile;
  File? _image;
  File? get imageSelected => _image;
  // InputImage? _inputImage;

  getImageCamera() async {
    setBusy(true);
    // picking image
    _imageFile = await _picker.pickImage(source: ImageSource.camera);

    if (_imageFile != null) {
      log.i("CCC");
      // _dlibService.addImageFace(await _imageFile!.readAsBytes());
      _image = File(_imageFile!.path);
    } else {
      _bottomSheetService.showCustomSheet(
        variant: BottomSheetType.alert,
        title: "No images selected",
        // description: error,
      );
    }
    setBusy(false);
  }

  getImageGallery() async {
    setBusy(true);
    // picking image
    _imageFile = await _picker.pickImage(source: ImageSource.gallery);

    if (_imageFile != null) {
      _image = File(_imageFile!.path);
    } else {
      _bottomSheetService.showCustomSheet(
        variant: BottomSheetType.alert,
        title: "No images selected",
        // description: error,
      );
    }
    setBusy(false);
  }

  List<String> _labels = <String>[];
  List<String> get labels => _labels;

  void getLabel() async {
    setBusy(true);

    _storageService.uploadFile(
        _image!, "log/users/${_authService.currentUser!.uid}/log");

    log.i("Getting label");

    _labels = <String>[];

    _labels = await _imageProcessingService.getTextFromImage(_image!);

    setBusy(false);

    String text = _imageProcessingService.processLabels(_labels);
    log.i("SPEAK");
    await _ttsService.speak(text);
    await Future.delayed(const Duration(milliseconds: 2000));
    if (text == "Person detected") await processFace();
    _image = null;
    await Future.delayed(const Duration(seconds: 1));
    setBusy(false);
  }

  Future processFace() async {
    _ttsService.speak("Identifying person");
    setBusy(true);
    String? person = await _ragulaService.checkMatch(_image!.path);
    setBusy(false);
    if (person != null) {
      _labels.clear();
      _labels.add(person);
      notifyListeners();
      await _ttsService.speak(person);
      await Future.delayed(const Duration(milliseconds: 1500));
    } else {
      await _ttsService.speak("Not identified!");
      await Future.delayed(const Duration(milliseconds: 1500));
    }
    log.i("Person: $person");
  }

  Future speak(String text) async {
    _ttsService.speak(text);
  }
}
