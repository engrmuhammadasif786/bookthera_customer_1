import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:bookthera_customer_1/network/RestApis.dart';
import 'package:bookthera_customer_1/utils/Constants.dart';
import 'package:bookthera_customer_1/utils/resources/Colors.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;
import 'package:url_launcher/url_launcher_string.dart';

import '../main.dart';

Future<void> launchURL(String url, {bool forceWebView = true, Map<String, String>? header}) async {
  await url_launcher.launchUrl(Uri.parse(url), mode: LaunchMode.inAppWebView);
}

String parseHtmlString(String? htmlString) {
  return parse(parse(htmlString).body!.text).documentElement!.text;
}

extension SExt on String {
  int getYear() {
    return DateTime.parse(this).year;
  }

  String? getFormattedDate({String format = defaultDateFormat}) {
    try {
      return DateFormat(format).format(DateTime.parse(this));
    } on FormatException catch (e) {
      return e.source;
    }
  }

  bool get isVideoPlayerFile => this.contains("mp4") || this.contains("m4v") || this.contains("mkv") || this.contains("mov");

  String get urlFromIframe {
    var document = parse(this);
    dom.Element? link = document.querySelector('iframe');
    String? iframeLink = link != null ? link.attributes['src'].validate() : '';
    return iframeLink.validate();
  }

  bool get isYoutubeUrl {
    for (var exp in [
      RegExp(r"^https:\/\/(?:www\.|m\.)?youtube\.com\/watch\?v=([_\-a-zA-Z0-9]{11}).*$"),
      RegExp(r"^https:\/\/(?:www\.|m\.)?youtube(?:-nocookie)?\.com\/embed\/([_\-a-zA-Z0-9]{11}).*$"),
      RegExp(r"^https:\/\/youtu\.be\/([_\-a-zA-Z0-9]{11}).*$")
    ]) {
      Match? match = exp.firstMatch(this);
      if (match != null && match.groupCount >= 1) return true;
    }
    return false;
  }
}

class CardNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    var text = newValue.text;

    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }

    var buffer = new StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      var nonZeroIndex = i + 1;
      if (nonZeroIndex % 4 == 0 && nonZeroIndex != text.length) {
        buffer.write('  '); // Add double spaces.
      }
    }

    var string = buffer.toString();
    return newValue.copyWith(
        text: string,
        selection: new TextSelection.collapsed(offset: string.length));
  }
}

class CardMonthInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    var text = newValue.text;

    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }

    var buffer = new StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      var nonZeroIndex = i + 1;
      if (nonZeroIndex % 2 == 0 && nonZeroIndex != text.length) {
        buffer.write('/'); 
      }
    }

    var string = buffer.toString();
    return newValue.copyWith(
        text: string,
        selection: new TextSelection.collapsed(offset: string.length));
  }
}

// String getPostType(PostType postType) {
//   if (postType == PostType.MOVIE) {
//     return 'Movie';
//   } else if (postType == PostType.TV_SHOW) {
//     return 'TV Show';
//   } else if (postType == PostType.EPISODE) {
//     return 'Episode';
//   }
//   return '';
// }

Future<void> callNativeWebView(Map params) async {
  const platform = const MethodChannel('webviewChannel');

  if (isMobile) {
    await platform.invokeMethod('webview', params);
  }
}

class TabIndicator extends Decoration {
  final BoxPainter painter = TabPainter();

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) => painter;
}

class TabPainter extends BoxPainter {
  Paint? _paint;

  TabPainter() {
    _paint = Paint()..color = colorPrimary;
  }

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    Size size = Size(configuration.size!.width, 3);
    Offset _offset = Offset(offset.dx, offset.dy + 40);
    final Rect rect = _offset & size;
    canvas.drawRRect(
        RRect.fromRectAndCorners(
          rect,
          bottomRight: Radius.circular(0),
          bottomLeft: Radius.circular(0),
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
        ),
        _paint!);
  }
}

Future<void> launchUrl(String url, {bool forceWebView = false}) async {
  log(url);
  await url_launcher.launchUrl(Uri.parse(url), mode: LaunchMode.inAppWebView).catchError((e) {
    log(e);
    toast('Invalid URL: $url');
  });
}

String urlFromIframe({required String embedContent}) => parse(embedContent).getElementsByTagName('iframe')[0].attributes['src']!;

Future<String> prepareSaveDir() async {
  final _localPath = (await getCachedDirPath())!;
  final savedDir = Directory(_localPath);
  bool hasExisted = await savedDir.exists();
  if (!hasExisted) {
    savedDir.create();
  }
  return savedDir.path;
}

Future<String?> getCachedDirPath() async {
  var externalStorageDirPath;
  if (Platform.isAndroid) {
    try {
      final directory = await getTemporaryDirectory();
      externalStorageDirPath = directory.path;
    } catch (e) {
      log("No path detected.");
    }
  } else if (Platform.isIOS) {
    externalStorageDirPath = (await getApplicationDocumentsDirectory()).absolute.path;
  }
  return externalStorageDirPath;
}

Future<File> getFilePath(String fileName) async {
  final filePath = await getCachedDirPath();
  File srcFilepath = File("$filePath/downloads/$fileName");
  return srcFilepath;
}
