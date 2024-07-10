import 'package:flutter_sound/flutter_sound.dart';
import 'dart:async';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:record/record.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../core/audio_helper/audio_classification_helper.dart';
import 'package:permission_handler/permission_handler.dart';

class MainScreenController extends GetxController {

// TfliteFlutterPlatform _tfliteFlutterPlatform=TfliteFlutterPlatform.;
  static const platform =
  MethodChannel('org.tensorflow.audio_classification/audio_record');

  Record audioRecord=Record();

  bool recordPlaying=false;
  final sampleRate = 16000; // 16kHz
  static const expectAudioLength = 975; // milliseconds
  final int requiredInputBuffer = (16000 * (expectAudioLength / 1000)).toInt();
  late AudioClassificationHelper helper;
  List<MapEntry<String, double>> classification = List.empty();
  final List<Color> primaryProgressColorList = [
    const Color(0xFFF44336),
    const Color(0xFFE91E63),
    const Color(0xFF9C27B0),
    const Color(0xFF3F51B5),
    const Color(0xFF2196F3),
    const Color(0xFF00BCD4),
    const Color(0xFF009688),
    const Color(0xFF4CAF50),
    const Color(0xFFFFEB3B),
    const Color(0xFFFFC107),
    const Color(0xFFFF9800)
  ];
  final List<Color> backgroundProgressColorList = [
    const Color(0x44F44336),
    const Color(0x44E91E63),
    const Color(0x449C27B0),
    const Color(0x443F51B5),
    const Color(0x442196F3),
    const Color(0x4400BCD4),
    const Color(0x44009688),
    const Color(0x444CAF50),
    const Color(0x44FFEB3B),
    const Color(0x44FFC107),
    const Color(0x44FF9800)
  ];
  bool showError = false;



  @override
  void onInit() {
    // TODO: implement onInit
   initRecorder();
    //loadModel();
    super.onInit();
  }




  @override
  void onReady() {
    // TODO: implement onReady

  }

  @override
  void onClose() {
    // TODO: implement onClose
    //closeRecorder();
    audioRecord.dispose();
    super.onClose();
  }


 /* Future<void> loadModel() async {
    String? res = await Tflite.loadModel(
      model: "assets/models/yamnet.tflite",
      labels: "assets/models/yamnet_label_list.txt"
    );
    print(res);
  }*/

  /*Future<void> runModelOnAudio(String audioPath) async {
    var recognitions = await Tflite.runModelOnAudio(
      path: audioPath,  // path to the audio file
      inputType: 'rawAudio',  // depends on your model
      sampleRate: 16000,  // the sample rate your model expects
    );
    print(recognitions);
  }*/
 /* Future<void> startRecording() async {
      }

  Future<void> stopRecording() async {
     }*/
  Future<void> startRecorder() async {
    try {
      print("START RECODING+++++++++++++++++++++++++++++++++++++++++++++++++");
      if (await audioRecord.hasPermission()) {

        await audioRecord.start();
        recordPlaying = true;
      }
    } catch (e, stackTrace) {
      print("START RECODING+++++++++++++++++++++${e}++++++++++${stackTrace}+++++++++++++++++");
    }
    update();
  }
  Future<void> requestPermission() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.microphone,
      Permission.speech,
      Permission.audio,
    ].request();
    print('statuses[Permission.microphone]  ${statuses[Permission.microphone]}');
  }
     /* return await platform.invokeMethod('requestPermissionAndCreateRecorder', {
        "sampleRate": sampleRate,
        "requiredInputBuffer": requiredInputBuffer
      });*//*
  }
  Future<PermissionStatus> requestPermission(Permission permission) async {
    final status = await permission.request();
      print(status);
return status;
  }
*/

  Future<Float32List> getAudioFloatArray() async {
    var audioFloatArray = Float32List(0);
    try {
      audioRecord.onStateChanged().listen((event) async {
        final Float32List result =
            await platform.invokeMethod('getAudioFloatArray');
        audioFloatArray = result;
        print('get audio float array');

      });
/*

      final Float32List result =
          await platform.invokeMethod('getAudioFloatArray');
      audioFloatArray = result;
      print('get audio float array');
*/

    } on PlatformException catch (e) {
      log("Failed to get audio array: '${e.message}'.");
    }
    return audioFloatArray;
  }

  Future<void> closeRecorder() async {
    try {
      print("STOP RECODING+++++++++++++++++++++++++++++++++++++++++++++++++");
      await audioRecord.stop();
      recordPlaying= false;
    } catch (e) {
      print("STOP RECODING+++++++++++++++++++++${e}+++++++++++++++++++++++++++");
    }

  }

  Future<void> initRecorder() async {
    await requestPermission();
    helper = AudioClassificationHelper();
    await helper.initHelper();
    /* Permission ?permission;
    PermissionStatus success = await permission!.request();
    print("success abd  ${success}");*/
    if (true) {
      startRecorder();
      Timer.periodic(const Duration(milliseconds: expectAudioLength), (timer) {
        // classify here
        runInference();
      });
    } else {
      // show error here
      showError = true;

    }
    update();
  }

  Future<void> runInference() async {
    Float32List inputArray = await getAudioFloatArray();
    final result =
        await helper.inference(inputArray.sublist(0, requiredInputBuffer));
    // take top 3 classification
    classification = (result.entries.toList()
          ..sort(
            (a, b) => a.value.compareTo(b.value),
          ))
        .reversed
        .take(3)
        .toList();
    update();
    //log(classification());

  }

}
