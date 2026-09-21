import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:gozy/utils/common_file_picker.dart';
import 'package:gozy/widgets/common_extension_functions.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart'
    as wf_android;
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart'
    as wf_pi;

import '../../../../../constant.dart';
import '../../../../../widgets/custom_stateful_widget.dart';
import '../../../custom_scaffold.dart';
import '../payout_preference_controller.dart';
import 'package:gozy/widgets/webviewx_plus/utils/webview_flutter_original_utils.dart';
import 'package:gozy/widgets/webviewx_plus/controller/impl/mobile.dart'
    as wvx;
import 'package:gozy/widgets/webviewx_plus/view/impl/mobile.dart';

class PayoutWebView extends CustomStatefulWidget {
  const PayoutWebView({super.key});

  @override
  PayoutWebViewState createState() => PayoutWebViewState();
}

class PayoutWebViewState extends CustomStatefulWidgetState {
  PayoutPreferenceController controller = Get.find();

  late wvx.WebViewXController webviewController;

  wf_android.AndroidWebViewController? get _androidWebViewController {
    final connector = webviewController.connector;
    if (connector.platform is wf_android.AndroidWebViewController) {
      return connector.platform as wf_android.AndroidWebViewController;
    }
    return null;
  }

  @override
  void initState() {
    isShowLoader = false;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.isLoading.value = true;
    });
    super.initState();
  }

  @override
  void dispose() {
    controller.isLoading.value = false;
    super.dispose();
  }

  void _configureAndroidWebViewIfNeeded() async {
    final androidController = _androidWebViewController;
    if (androidController == null) return;

    wf_android.AndroidWebViewController.enableDebugging(kDebugMode);
    unawaited(androidController.setMediaPlaybackRequiresUserGesture(false));
    unawaited(
      androidController.setOnPlatformPermissionRequest(
        _onPlatformPermissionRequest,
      ),
    );
    addFileSelectionListener();
  }

  void _onPlatformPermissionRequest(
      wf_pi.PlatformWebViewPermissionRequest request) {
    unawaited(Future<void>(() async {
      final permissionsToRequest = <Permission>[];
      if (request.types.contains(wf_pi.WebViewPermissionResourceType.camera)) {
        permissionsToRequest.add(Permission.camera);
      }
      if (request.types.contains(
        wf_pi.WebViewPermissionResourceType.microphone,
      )) {
        permissionsToRequest.add(Permission.microphone);
      }

      if (permissionsToRequest.isEmpty) {
        await request.grant();
        return;
      }

      final statuses = await permissionsToRequest.request();
      final allGranted = statuses.values.every((status) => status.isGranted);
      if (allGranted) {
        await request.grant();
      } else {
        await request.deny();
      }
    }));
  }

  Future<List<String>> _androidFilePicker(
      wf_android.FileSelectorParams params) async {
    final allowMultiple =
        params.mode == wf_android.FileSelectorMode.openMultiple;

    FileType type = FileType.any;
    List<String>? allowedExtensions;

    final acceptTypes = params.acceptTypes;
    if (acceptTypes.any((t) => t == 'image/*' || t.startsWith('image/'))) {
      type = FileType.image;
    } else if (acceptTypes
        .any((t) => t == 'video/*' || t.startsWith('video/'))) {
      type = FileType.video;
    } else if (acceptTypes
        .any((t) => t == 'audio/*' || t.startsWith('audio/'))) {
      type = FileType.audio;
    } else {
      final extensions = <String>{};
      for (final mime in acceptTypes) {
        final ext = _mimeToExtension(mime);
        if (ext != null) extensions.add(ext);
      }
      if (extensions.isNotEmpty) {
        type = FileType.custom;
        allowedExtensions = extensions.toList()..sort();
      }
    }

    final result = await CommonFilePicker.pickFiles(
      type: type,
      allowMultiple: allowMultiple,
      allowedExtensions: allowedExtensions,
      withReadStream: false,
    );

    if (result == null) return <String>[];
    return result.paths
        .whereType<String>()
        .map((path) => Uri.file(path).toString())
        .toList(growable: false);
  }

  String? _mimeToExtension(String mime) {
    switch (mime.toLowerCase()) {
      case 'application/pdf':
        return 'pdf';
      case 'image/jpeg':
        return 'jpg';
      case 'image/png':
        return 'png';
      case 'image/webp':
        return 'webp';
      case 'image/heic':
        return 'heic';
      case 'image/heif':
        return 'heif';
      case 'application/msword':
        return 'doc';
      case 'application/vnd.openxmlformats-officedocument.wordprocessingml.document':
        return 'docx';
      case 'application/vnd.ms-excel':
        return 'xls';
      case 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet':
        return 'xlsx';
      default:
        return null;
    }
  }

  void addFileSelectionListener() {
    final androidController = _androidWebViewController;
    if (androidController == null) return;

    if (wf_pi.WebViewPlatform.instance is wf_android.AndroidWebViewPlatform) {
      unawaited(androidController.setOnShowFileSelector(_androidFilePicker));
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
        controller: controller,
        backIconWidget: getBackIconWidget(
          themeType: overALLThemeType,
        ),
        isShowAppBar: true,
        body: [
          _showBodyContent(context),
          Obx(
            () => (controller.isLoading.value)
                ? dotCenter120HeightLoader!
                    .toResizeWidget(height: deviceHeight, color: Colors.white)
                : 0.toHeight(),
          ),
        ].toStack());
  }

  Widget _showBodyContent(BuildContext context) {
    return WebViewX(
      height: deviceHeight,
      width: deviceWidth,
      onWebViewCreated: (controller) {
        webviewController = controller as wvx.WebViewXController;
        _configureAndroidWebViewIfNeeded();
        controller.loadContent(
          Get.arguments["stripeConnectUrl"] ?? '',
        );
      },
      onProgress: (int progress) {
        if (progress != 100 && Get.currentRoute == "/PayoutWebView") {
          controller.isLoading.value = true;
        } else {
          controller.isLoading.value = false;
        }
      },
      onPageFinished: (src) {
        Future.delayed(Duration(milliseconds: 50)).then((value) {
          controller.isLoading.value = false;
        });
        debugPrint('The page has finished loading: $src\n');
      },
      navigationDelegate: (navigation) {
        String url = navigation.content.source;
        if (url.contains('/payout/success')) {
          controller.confirmPayout(Get.arguments["stripeAccountId"] ?? '');
          return NavigationDecision.prevent;
        } else if (url.toString().contains('/payout/failure')) {
          Get.back();
          webviewController.clearCache();
        }
        return NavigationDecision.navigate;
      },
    );
  }
}