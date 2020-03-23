import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:wc_flutter_share/wc_flutter_share.dart';
import 'package:image/image.dart';
import 'package:flutter/services.dart' show rootBundle;

Future<void> shareProgressImage(RenderRepaintBoundary boundary) async {
  ui.Image screenshot = await boundary.toImage();
    ByteData screenshotBytes = await screenshot.toByteData(format: ui.ImageByteFormat.png);
    final timerImage = decodePng(screenshotBytes.buffer.asUint8List());
    ByteData templateBytes = await rootBundle.load('assets/share-template.png');
    final templateImage = decodePng(templateBytes.buffer.asUint8List());
    final resizedTimerImage = copyResize(timerImage, width: 523, interpolation: Interpolation.linear);
    copyInto(templateImage, resizedTimerImage, dstX: 1018, dstY: 126);    
    await WcFlutterShare.share(
      sharePopupTitle: 'Share Progress',  
      fileName: 'progress.png',
      mimeType: 'image/png',
      bytesOfFile: encodePng(templateImage)
    );
}