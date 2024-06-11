import 'dart:async';
import 'dart:developer';

import 'package:camera/camera.dart';
import 'package:tflite_v2/tflite_v2.dart';

import '../Model/resukt.dart';

class TFLiteHelper {
  static StreamController<List<Result>> tfLiteResultsController =
      new StreamController.broadcast();
  static List<Result> _outputs = <Result>[];
  static var modelLoaded = false;

  static Future<String?> loadModel() async {
    log("Loading model..");

    return Tflite.loadModel(
      model: "assets/model.tflite",
      labels: "assets/labels.txt",
    );
  }

  static classifyImage(CameraImage image) async {
    await Tflite.runModelOnFrame(
            bytesList: image.planes.map((plane) {
              return plane.bytes;
            }).toList(),
            //!_-
            imageHeight: image.height,
            imageWidth: image.width,
            imageMean: 127.5,
            imageStd: 127.5,
            rotation: 90,
            threshold: 0.4,
            asynch: true,
            //!--
            numResults: 1) //5
        .then((value) {
      if (value!.isNotEmpty) {
        log("Results loaded. ${value.length}");

        //Clear previous results
        _outputs.clear();

        value.forEach((element) {
          _outputs.add(Result(
              element['confidence'], element['index'], element['label']));

          log("${element['confidence']} , ${element['index']}, ${element['label']}");
        });
      }

      //Sort results according to most confidence
      _outputs.sort((a, b) => a.confidence.compareTo(b.confidence));

      //Send results
      tfLiteResultsController.add(_outputs);
    });
  }

  static void disposeModel() {
    Tflite.close();
    tfLiteResultsController.close();
  }
}
