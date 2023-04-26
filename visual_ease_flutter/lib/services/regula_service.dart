import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_face_api/face_api.dart' as Regula;
import 'package:path_provider/path_provider.dart';
import 'package:stacked_services/stacked_services.dart';

import '../app/app.locator.dart';
import '../app/app.logger.dart';

class RegulaService {
  final log = getLogger('RegulaService');
  final _bottomSheetService = locator<BottomSheetService>();

  // late Regula.FaceSDK _faceSDK;

  Future<void> initPlatformState() async {
    log.i("Regula started");
    Regula.FaceSDK.init().then(
      (json) {
        var response = jsonDecode(json);
        if (!response["success"]) {
          log.i("Init failed: ");
          log.i(json);
        }
      },
    );

    // const EventChannel('flutter_face_api/event/video_encoder_completion')
    //     .receiveBroadcastStream()
    //     .listen((event) {
    //   var response = jsonDecode(event);
    //   String transactionId = response["transactionId"];
    //   bool success = response["success"];
    //   log.i("video_encoder_completion:");
    //   log.i("    success: $success");
    //   log.i("    transactionId: $transactionId");
    // });
  }

  Future<Uint8List?> imageBitmap() async {
    final result = await Regula.FaceSDK.presentFaceCaptureActivity();
    if (result != null) {
      log.i("Result got");
      Regula.FaceCaptureResponse? response =
          Regula.FaceCaptureResponse.fromJson(json.decode(result));
      log.i(response?.exception?.message ?? "Error");
      if (response != null && response.image != null) {
        log.i("Image response");
        Uint8List imageFile =
            base64Decode(response.image!.bitmap!.replaceAll("\n", ""));
        return imageFile;
      }
    }
    return null;
  }

  Future<String?> setFaceAndGetImagePath() async {
    Uint8List? imageFile = await imageBitmap();
    if (imageFile != null) {
      log.i("Getting path..");
      // getting a directory path for saving
      final directory = await getApplicationDocumentsDirectory();
      File file = File(('${directory.path}/faceData.png'));
      file.writeAsBytesSync(imageFile); // This is a sync operation on a real
      // return base64Encode(imageFile);
      return file.path;
    }
    return null;
  }

  Regula.MatchFacesImage getMatchFacesImage(Uint8List imageFile, int type) {
    var image = Regula.MatchFacesImage();
    image.bitmap = base64Encode(imageFile);
    image.imageType = type;
    return image;
  }

  void setUserImage(String path) {
    final file = File(path).readAsBytesSync();
    final image = getMatchFacesImage(file, Regula.ImageType.LIVE);
    _image1.bitmap = image.bitmap;
    _image1.imageType = image.imageType;
    log.i("User image set:  $path type: ${_image1.imageType}");
  }

  final _image1 = Regula.MatchFacesImage();
  final _image2 = Regula.MatchFacesImage();

  Future<double?> checkMatch(String path, {bool isLiveness = false}) async {
    setUserImage(path);
    Uint8List? imageFile =
        isLiveness ? await checkLiveness() : await imageBitmap();
    if (imageFile == null) return null;
    log.i("second image captured");
    _image2.bitmap = base64Encode(imageFile);
    _image2.imageType = Regula.ImageType.LIVE;
    if (_image1.bitmap != null && _image1.bitmap != "") {
      log.i("Image 1 ready");
    }
    if (_image2.bitmap != null && _image2.bitmap != "") {
      log.i("Image 2 ready");
    }
    if (_image1.bitmap == null ||
        _image1.bitmap == "" ||
        _image2.bitmap == null ||
        _image2.bitmap == "") return null;

    log.i("Checking face");
    var request = Regula.MatchFacesRequest();
    request.images = [_image1, _image2];
    String value = await Regula.FaceSDK.matchFaces(jsonEncode(request));
    Regula.MatchFacesResponse? response =
        Regula.MatchFacesResponse.fromJson(json.decode(value));
    String str = await Regula.FaceSDK.matchFacesSimilarityThresholdSplit(
        jsonEncode(response!.results), 0.75);
    log.i("Checking face done");

    Regula.MatchFacesSimilarityThresholdSplit? split =
        Regula.MatchFacesSimilarityThresholdSplit.fromJson(json.decode(str));
    if (split!.matchedFaces.isNotEmpty) {
      log.i(
          "Matched face index: ${split.matchedFaces[0]!.first!.face!.faceIndex}");
      return (split.matchedFaces[0]!.similarity! * 100);
    }

    return null;
  }

  Future<Uint8List?> checkLiveness() async {
    var value = await Regula.FaceSDK.startLiveness();
    var result = Regula.LivenessResponse.fromJson(json.decode(value));
    Uint8List image = base64Decode(result!.bitmap!.replaceAll("\n", ""));
    if (result.liveness == Regula.LivenessStatus.PASSED) {
      log.i("Live image");
      // _bottomSheetService.showCustomSheet(
      //   variant: BottomSheetType.success,
      //   title: "Face unlocked",
      //   description: "You can now view the file.",
      // );
      return image;
    } else {
      return null;
    }
  }
}
