import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:wc_flutter_share/wc_flutter_share.dart';
import 'package:image/image.dart';
import 'package:flutter/services.dart' show rootBundle;

const TIMER_MIN_ASPECT_RATIO = 1.42;

Future<void> shareProgressImage(RenderRepaintBoundary boundary) async {
  while (boundary.debugNeedsPaint) {
    await Future.delayed(const Duration(milliseconds: 10)); // yuck! https://stackoverflow.com/questions/57645037/unable-to-take-screenshot-in-flutter
  }
  ui.Image screenshot = await boundary.toImage();
  ByteData screenshotBytes = await screenshot.toByteData(format: ui.ImageByteFormat.png);
  final timerImage = decodePng(screenshotBytes.buffer.asUint8List());
  final timerAspectRatio = timerImage.height.toDouble() / timerImage.width.toDouble();
  ByteData templateBytes = await rootBundle.load('assets/share-template.png');
  final templateImage = decodePng(templateBytes.buffer.asUint8List());
  final resizedTimerImage = copyResize(timerImage, width: 523, interpolation: Interpolation.linear);
  int skipPixelsTop = ((timerAspectRatio - TIMER_MIN_ASPECT_RATIO) * 523 * 0.5).round();
  if (skipPixelsTop < 0) skipPixelsTop = 0;
  copyInto(templateImage, resizedTimerImage, dstX: 1018, dstY: 126, srcY: skipPixelsTop, srcH: resizedTimerImage.height - skipPixelsTop);    
  await WcFlutterShare.share(
    sharePopupTitle: 'Share Progress',  
    fileName: 'progress.png',
    mimeType: 'image/png',
    bytesOfFile: encodePng(templateImage)
  );
}