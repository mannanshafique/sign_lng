import 'dart:developer';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'Helper/camera_helper.dart';
import 'Helper/tflite_helper.dart';
import 'Model/resukt.dart';
// import 'package:percent_indicator/linear_percent_indicator.dart';
// import 'package:asl/helpers/app_helper.dart';
// import 'package:asl/helpers/camera_helper.dart';
// import 'package:asl/helpers/tflite_helper.dart';
// import 'package:asl/models/result.dart';
// import 'package:flutter_tts/flutter_tts.dart';

class DetectScreen extends StatefulWidget {
  const DetectScreen({Key? key, this.title}) : super(key: key);

  final String? title;
  @override
  _DetectScreenState createState() => _DetectScreenState();
}

class _DetectScreenState extends State<DetectScreen>
    with TickerProviderStateMixin {
  // AnimationController _colorAnimController;
  // Animation _colorTween;
  // final FlutterTts flutterTts = FlutterTts();

  List<Result>? outputs;

  void initState() {
    super.initState();

    //Load TFLite Model
    TFLiteHelper.loadModel().then((value) {
      setState(() {
        TFLiteHelper.modelLoaded = true;
      });
    });

    //Initialize Camera
    CameraHelper.initializeCamera();

    //Setup Animation
    _setupAnimation();

    //Subscribe to TFLite's Classify events
    TFLiteHelper.tfLiteResultsController.stream.listen(
        (value) {
          value.forEach((element) {
            log(element.confidence.toString());
            // _colorAnimController.animateTo(element.confidence,
            //     curve: Curves.bounceIn, duration: Duration(milliseconds: 500));
          });

          //Set Results
          outputs = value;

          //Update results on screen
          setState(() {
            //Set bit to false to allow detection again
            CameraHelper.isDetecting = false;
          });
        },
        onDone: () {},
        onError: (error) {
          log('listen ${error}');
        });
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text(widget.title ?? '--')),
      ),
      body: FutureBuilder<void>(
        future: CameraHelper.initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // If the Future is complete, display the preview.
            return Stack(
              children: <Widget>[
                CameraPreview(CameraHelper.camera!),
                (outputs ?? []).isNotEmpty
                    ? _buildResultsWidget(width, outputs!)
                    : const SizedBox.shrink()
              ],
            );
          } else {
            // Otherwise, display a loading indicator.
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    TFLiteHelper.disposeModel();
    CameraHelper.camera?.dispose();
    log("dispose Clear resources.");
    super.dispose();
  }

  Widget _buildResultsWidget(double width, List<Result> outputs) {
    Future speak(String s) async {
      // await flutterTts.setLanguage("en-US");
      // await flutterTts.setPitch(1);
      // await flutterTts.setSpeechRate(0.5);
      // await flutterTts.speak(s);
    }

    return Positioned.fill(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          height: 200.0,
          width: width,
          color: Colors.white,
          child: outputs != null && outputs.isNotEmpty
              ? ListView.builder(
                  itemCount: outputs.length,
                  shrinkWrap: true,
                  padding: const EdgeInsets.all(20.0),
                  itemBuilder: (BuildContext context, int index) {
                    return Column(
                      children: <Widget>[
                        Text(
                          outputs[index].label,
                          // style: TextStyle(
                          //   color: _colorTween.value,
                          //   fontSize: 20.0,
                          // ),
                        ),
                        // AnimatedBuilder(
                        //     animation: _colorAnimController,
                        //     builder: (context, child) => LinearPercentIndicator(
                        //           width: width * 0.88,
                        //           lineHeight: 14.0,
                        //           percent: outputs[index].confidence,
                        //           progressColor: _colorTween.value,
                        //         )),
                        Text(
                          "${(outputs[index].confidence * 100.0).toStringAsFixed(2)} %",
                          // style: TextStyle(
                          //   color: _colorTween.value,
                          //   fontSize: 16.0,
                          // ),
                        ),
                        Center(
                          child: ElevatedButton(
                            onPressed: () {
                              speak("${outputs[index].label}");
                            },
                            child: Icon(
                              Icons.play_arrow,
                              size: 60,
                              color: Color(0xff375079),
                            ),
                          ),
                        ),
                      ],
                    );
                  })
              : Center(
                  child: Text("Wating for model to detect..",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20.0,
                      ))),
        ),
      ),
    );
  }

  void _setupAnimation() {
    // _colorAnimController =
    //     AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    // _colorTween = ColorTween(begin: Colors.green, end: Colors.red)
    //     .animate(_colorAnimController);
  }
}
