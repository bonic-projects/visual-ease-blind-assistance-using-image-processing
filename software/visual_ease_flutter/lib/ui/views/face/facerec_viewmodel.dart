import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
// import 'package:vision/ui/setup_snackbar_ui.dart';

import '../../../app/app.bottomsheets.dart';
import '../../../app/app.locator.dart';
import '../../../app/app.logger.dart';

//main.dart

import 'package:http/http.dart' as http;

import '../../../services/regula_service.dart';

class FaceRecViewModel extends BaseViewModel {
  final log = getLogger('FaceRecViewModel');

  final _snackBarService = locator<SnackbarService>();
  final _ragulaService = locator<RegulaService>();
  final _bottomSheetService = locator<BottomSheetService>();

  File? _image;
  File? get imageSelected => _image;

  void onModelReady() async {
    setBusy(true);
    log.i("Model ready");
    await getImagesFromDirectory();
    setBusy(false);
  }

  String? _name;
  String? get name => _name;

  void setName(String value) {
    _name = value;
    log.i(_name);
    if (_name != null && _name!.isNotEmpty) {
      saveImage();
    }
  }

  void saveImage() async {
    setBusy(true);
    String? imgPath = await _ragulaService.setFaceAndGetImagePath(_name!);
    if (imgPath != null) {
      getImagesFromDirectory();
    } else {
      _bottomSheetService.showCustomSheet(
        variant: BottomSheetType.alert,
        title: "Canceled",
        description: "Select again",
      );
    }
    setBusy(false);
  }

  List<String> _images = <String>[];
  List<String> get images => _images;

  Future getImagesFromDirectory() async {
    log.i("Getting images..");
    final Directory directory = await getApplicationDocumentsDirectory();
    _images = directory
        .listSync()
        .map((item) => item.path)
        .where((item) => item.endsWith(".png"))
        .toList(growable: false);
    log.i(_images);
    notifyListeners();
  }

  void deleteImage(String path) {
    File img = File(path);
    img.delete();
    getImagesFromDirectory();
  }
}
