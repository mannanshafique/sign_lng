import 'dart:developer';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tflite_v2/tflite_v2.dart';

import 'main.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String answer = "";
  CameraController? cameraController;
  CameraImage? cameraImage;
  bool isModelBusy = false;

//  change the model name in main file at line number 35,36
  loadmodel() async {
    // await Tflite.close();
    try {
      await Tflite.loadModel(
        model: 'assets/model_unquant.tflite',
        // model: 'assets/hand_model.tflite',
        // labels: 'assets/custom_label.txt',
        labels: 'assets/labels.txt',
        // useGpuDelegate: true,
        // isAsset: false,
        // numThreads: 1
      );
    } on PlatformException {
      log('Failed to load model.');
    } catch (e) {
      log(e.toString());
    }
  }

  initCamera() {
    // cameraController = CameraController(cameras![0], ResolutionPreset.medium);

    // OR
    cameraController = CameraController(
        CameraDescription(
          name: '0', // 0 for back camera and 1 for front camera
          lensDirection: CameraLensDirection.back,
          sensorOrientation: 0,
        ),
        ResolutionPreset.medium);

    cameraController!.initialize().then(
      (value) {
        if (!mounted) {
          return;
        }
        setState(
          () {
            cameraController!.startImageStream(
              (image) => {
                if (true)
                  {
                    // setState(
                    //   () {
                    //     cameraImage = image;
                    //   },
                    // ),
                    cameraImage = image,

                    applymodelonimages(),
                  }
              },
            );
          },
        );
      },
    );
  }

  applymodelonimages() async {
    // if (isModelBusy) {
    //   return;
    // }
    // isModelBusy = true;
    if (cameraImage != null && cameraImage!.planes.isNotEmpty) {
      var predictions = await Tflite.runModelOnFrame(
          bytesList: cameraImage!.planes.map(
            (plane) {
              return plane.bytes;
            },
          ).toList(),
          imageHeight: cameraImage!.height,
          imageWidth: cameraImage!.width,
          imageMean: 127.5,
          imageStd: 127.5,
          rotation: 90,
          numResults: 2,
          threshold: 0.1,
          asynch: true);

      answer = '';
      if (predictions != null && predictions.isNotEmpty) {
        predictions!.forEach(
          (prediction) {
            answer +=
                prediction['label'].toString().substring(0, 1).toUpperCase() +
                    prediction['label'].toString().substring(1) +
                    " " +
                    (prediction['confidence'] as double).toStringAsFixed(3) +
                    '\n';
          },
        );
        setState(() {
          answer = answer;
        });
      }
      // isModelBusy = false;
      // predictions!.forEach(
      //   (prediction) {
      //     answer +=
      //         prediction['label'].toString().substring(0, 1).toUpperCase() +
      //             prediction['label'].toString().substring(1) +
      //             " " +
      //             (prediction['confidence'] as double).toStringAsFixed(3) +
      //             '\n';
      //   },
      // );

      // setState(
      //   () {
      //     answer = answer;
      //   },
      // );
    }
  }

  @override
  void initState() {
    super.initState();
    initCamera();
    loadmodel();
  }

  @override
  void dispose() async {
    Tflite.close();
    cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme:
          ThemeData(brightness: Brightness.dark, primaryColor: Colors.purple),
      debugShowCheckedModeBanner: false,
      home: SafeArea(
        child: Scaffold(
          body: cameraImage != null
              ? Container(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  color: Colors.blue,
                  child: Stack(
                    children: [
                      Positioned(
                        child: Center(
                          child: Container(
                            height: MediaQuery.of(context).size.height,
                            width: MediaQuery.of(context).size.width,
                            child: AspectRatio(
                              aspectRatio: cameraController!.value.aspectRatio,
                              child: CameraPreview(
                                cameraController!,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Container(
                            padding: EdgeInsets.all(10),
                            color: Colors.black87,
                            child: Center(
                              child: Text(
                                answer,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 20, color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                )
              : Container(),
        ),
      ),
    );
  }
}

// import 'dart:convert';
// import 'dart:developer';

// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:camera/camera.dart';
// import 'package:tflite_v2/tflite_v2.dart';

// class GestureDetectionScreen extends StatefulWidget {
//   @override
//   _GestureDetectionScreenState createState() => _GestureDetectionScreenState();
// }

// class _GestureDetectionScreenState extends State<GestureDetectionScreen> {
//   late CameraController _cameraController;
//   bool _isModelLoaded = false;
//   List<dynamic>? _output;
//   String _recognizedGesture = '';

//   @override
//   void initState() {
//     super.initState();
//     _initializeCamera();
//     _loadModel();
//   }

//   void _initializeCamera() async {
//     final cameras = await availableCameras();
//     final camera = cameras.first;

//     _cameraController = CameraController(
//       camera,
//       ResolutionPreset.medium,
//     );
//     await _cameraController.initialize();
//     setState(() {});
//     // Start camera stream and set up listener for camera frames
//     _cameraController.startImageStream((CameraImage cameraImage) {
//       _processCameraImage(cameraImage);
//     });
//   }

//   void _loadModel() async {
// await Tflite.loadModel(
//   model: 'assets/model_unquant.tflite',
//   labels: 'assets/labels.txt',
// );
//     setState(() {
//       _isModelLoaded = true;
//     });
//   }

//   void _processCameraImage(CameraImage cameraImage) async {
//     if (!_isModelLoaded ||
//         _cameraController == null ||
//         !_cameraController.value.isInitialized) {
//       return;
//     }

//     var input = _preprocessImage(cameraImage);
//     var output = await Tflite.runModelOnFrame(
//       bytesList: input,
//     );

//     setState(() {
//       _output = output!;
//       _recognizedGesture = _processOutput(output);
//     });
//   }

//   List<Uint8List> _preprocessImage(CameraImage cameraImage) {
//     var bytes = <Uint8List>[];

//     for (int planeIndex = 0;
//         planeIndex < cameraImage.planes.length;
//         planeIndex++) {
//       var plane = cameraImage.planes[planeIndex];
//       bytes.add(plane.bytes);
//     }
//     return bytes;
//   }

//   String _processOutput(List<dynamic> output) {
//     if (output == null || output.isEmpty) {
//       log('Recognition failed');
//       return 'Recognition failed';
//     }

//     // Assuming the model outputs probabilities for different gestures
//     var probabilities = output[0] as List<double>;

//     // Find the index of the highest probability
//     var maxIndex =
//         probabilities.indexOf(probabilities.reduce((a, b) => a > b ? a : b));

//     // Map the index to the corresponding gesture label
//     var gestureLabels = [
//       'I love you',
//       'Good Bye',
//       'Peace',
//       'A',
//       'F'
//     ]; // Example labels
//     if (maxIndex >= 0 && maxIndex < gestureLabels.length) {
//       log(gestureLabels[maxIndex]);
//       return gestureLabels[maxIndex];
//     } else {
//       log('Unknown gesture');
//       return 'Unknown gesture';
//     }
//   }

//   @override
//   void dispose() {
//     _cameraController?.dispose();
//     Tflite.close();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_cameraController == null || !_cameraController.value.isInitialized) {
//       return Scaffold(
//         appBar: AppBar(
//           title: Text('Gesture Detection'),
//         ),
//         body: Center(
//           child: CircularProgressIndicator(),
//         ),
//       );
//     }

//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Gesture Detection'),
//       ),
//       body: Stack(
//         children: [
//           CameraPreview(_cameraController),
//           Align(
//             alignment: Alignment.bottomCenter,
//             child: Container(
//               color: Colors.black.withOpacity(0.5),
//               padding: EdgeInsets.all(16),
//               child: Text(
//                 'Recognized Gesture: $_recognizedGesture',
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 20,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// import 'dart:async';
// import 'dart:developer';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:camera/camera.dart';
// import 'package:tflite_flutter/tflite_flutter.dart';

// class CameraScreen extends StatefulWidget {
//   @override
//   _CameraScreenState createState() => _CameraScreenState();
// }

// class _CameraScreenState extends State<CameraScreen> {
//   late CameraController _cameraController;
//   late List<CameraDescription> _cameras;
//   late Interpreter _interpreter;
//   late List<String> _labels;

//   bool _isModelLoaded = false;
//   String _recognizedGesture = '';

//   @override
//   void initState() {
//     super.initState();
//     _initializeCamera();
//     _loadModel();
//   }

//   Future<void> _initializeCamera() async {
//     _cameras = await availableCameras();
//     if (_cameras.isEmpty) {
//       print('No cameras found');
//       return;
//     }
//     _cameraController = CameraController(
//       _cameras[0],
//       ResolutionPreset.medium,
//     );
//     await _cameraController.initialize();
//     if (!mounted) return;
//     setState(() {
//       _isModelLoaded = true;
//     });
//     _cameraController.startImageStream(_processCameraImage);
//   }

//   Future<void> _loadModel() async {
//     _interpreter = await Interpreter.fromAsset('assets/model_unquant.tflite');
//     _interpreter.allocateTensors();
//     _loadLabels();
//   }

//   Future<void> _loadLabels() async {
//     final labelsFile = await File('assets/labels.txt').readAsLines();
//     setState(() {
//       _labels = labelsFile;
//     });
//   }

//   @override
//   void dispose() {
//     _cameraController.stopImageStream();
//     _cameraController.dispose();
//     _interpreter.close();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_cameraController == null ||
//         _cameras.isEmpty ||
//         !_cameraController.value.isInitialized) {
//       return Container(
//         color: Colors.red,
//       );
//     }
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Hand Gesture Recognition'),
//       ),
//       body: Stack(
//         children: [
//           CameraPreview(_cameraController),
//           Positioned(
//             bottom: 16.0,
//             left: 16.0,
//             child: Text(
//               _recognizedGesture,
//               style: TextStyle(
//                 fontSize: 20.0,
//                 color: Colors.white,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Future<void> _processCameraImage(CameraImage cameraImage) async {
//     if (!_isModelLoaded) {
//       log('Model is not loaded yet.');
//       return;
//     }
//     try {
//       var input = [cameraImage];
//       var output =
//           List.filled(1, List.filled(1, List.filled(1, List.filled(1, 0.0))));
//       log('$output');
//       _interpreter.run(input, output);
//       var predictedIndex = output[0][0][0].cast<double>().indexOf(
//           output[0][0][0].cast<double>().reduce((a, b) => a > b ? a : b));
//       setState(() {
//         _recognizedGesture = _labels[predictedIndex];
//       });
//       log('_recognizedGesture ${_recognizedGesture}');
//     } catch (e) {
//       log('Error recognizing gesture: $e');
//     }
//   }
// }
