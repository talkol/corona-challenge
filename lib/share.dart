import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:lockdown/persistence.dart';
import 'package:wc_flutter_share/wc_flutter_share.dart';
import 'package:image/image.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_alert/flutter_alert.dart';

const TIMER_MIN_ASPECT_RATIO = 1.42;
const HOW_OFTEN_TO_ASK_SHARE = 3; // 1 every 3 foregrounds
const SHARE_COUNTER_DONT_ASK = -1;

Future<void> shareProgressImage(RenderRepaintBoundary boundary) async {
  while (boundary.debugNeedsPaint ?? false) {
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

Future<void> shareLinkPopup(BuildContext context) async {
  final counter = await getPersistentShareCounter();
  if (counter == SHARE_COUNTER_DONT_ASK) return;
  await setPersistentShareCounter(counter + 1);
  if (counter % HOW_OFTEN_TO_ASK_SHARE == 0) {
    showAlert(
      context: context,
      title: 'Promote self-quarantine!',
      body: '\nSend the app link to friends with an IM like Facebook Messenger or WhatsApp.',
      actions: [
        AlertAction(
          text: 'Share',
          isDefaultAction: true,
          onPressed: () {
            WcFlutterShare.share(
              sharePopupTitle: 'Share',
              text: 'Do the Corona Challenge to show your support for self-quarantine! https://orbs.page.link/corona',
              mimeType: 'text/plain'
            );
          },
        ),
        AlertAction(
          text: 'Not now',
          onPressed: () {},
        ),
        AlertAction(
          text: 'Stop asking',
          onPressed: () {
            setPersistentShareCounter(SHARE_COUNTER_DONT_ASK);
          },
        ),
      ],
      cancelable: false,
    );
  }
}