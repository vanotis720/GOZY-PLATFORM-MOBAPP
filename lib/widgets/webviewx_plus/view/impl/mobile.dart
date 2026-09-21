import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:gozy/widgets/webviewx_plus/utils/utils.dart';

import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart'
    as wf_pi;
import 'package:webview_flutter/webview_flutter.dart' as wf;
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart'
    as wf_wk;
import 'package:webview_flutter_android/webview_flutter_android.dart'
    as wf_android;

import 'package:gozy/widgets/webviewx_plus/view/interface.dart' as view_interface;
import 'package:gozy/widgets/webviewx_plus/controller/interface.dart' as ctrl_interface;
import 'package:gozy/widgets/webviewx_plus/controller/impl/mobile.dart';
class WebViewX extends StatefulWidget implements view_interface.WebViewX {
  @override
  final String initialContent;
  @override
  final SourceType initialSourceType;

  @override
  final String? userAgent;

  @override
  final double width;

  @override
  final double height;

  @override
  final Function(ctrl_interface.WebViewXController controller)?
      onWebViewCreated;

  @override
  final Set<EmbeddedJsContent> jsContent;

  @override
  final Set<DartCallback> dartCallBacks;

  @override
  final bool ignoreAllGestures;

  @override
  final JavascriptMode javascriptMode;

  @override
  final AutoMediaPlaybackPolicy initialMediaPlaybackPolicy;

  @override
  final void Function(String src)? onPageStarted;

  @override
  final void Function(String src)? onPageFinished;


  final void Function(int progress)? onProgress;

  @override
  final NavigationDelegate? navigationDelegate;

  @override
  final void Function(WebResourceError error)? onWebResourceError;

  @override
  final MobileSpecificParams mobileSpecificParams;

  const WebViewX({
    super.key,
    this.initialContent = 'about:blank',
    this.initialSourceType = SourceType.url,
    this.userAgent,
    required this.width,
    required this.height,
    this.onWebViewCreated,
    this.jsContent = const {},
    this.dartCallBacks = const {},
    this.ignoreAllGestures = false,
    this.javascriptMode = JavascriptMode.unrestricted,
    this.initialMediaPlaybackPolicy =
        AutoMediaPlaybackPolicy.requireUserActionForAllMediaTypes,
    this.onPageStarted,
    this.onPageFinished,
    this.navigationDelegate,
    this.onWebResourceError,
    this.mobileSpecificParams = const MobileSpecificParams(),
    this.onProgress,
  });

  @override
  _WebViewXState createState() => _WebViewXState();
}

class _WebViewXState extends State<WebViewX> {
  late final wf.WebViewController originalWebViewController;
  late final WebViewXController webViewXController;

  late final RxBool _ignoreAllGestures;

  @override
  void initState() {
    super.initState();

    _ignoreAllGestures = widget.ignoreAllGestures.obs;
    originalWebViewController = _createOriginalController();
    _populateOriginalController();
    webViewXController = _createWebViewXController();

    widget.onWebViewCreated?.call(webViewXController);
  }

  @override
  Widget build(BuildContext context) {
    late final wf.PlatformWebViewWidgetCreationParams widgetParams;
    if (Platform.isAndroid) {
      widgetParams = wf_android.AndroidWebViewWidgetCreationParams(
        controller: originalWebViewController.platform,
        gestureRecognizers:
            widget.mobileSpecificParams.mobileGestureRecognizers ?? const {},
        displayWithHybridComposition:
            widget.mobileSpecificParams.androidEnableHybridComposition,
      );
    } else if (Platform.isIOS || Platform.isMacOS) {
      widgetParams = wf_wk.WebKitWebViewWidgetCreationParams(
        controller: originalWebViewController.platform,
        gestureRecognizers:
            widget.mobileSpecificParams.mobileGestureRecognizers ?? const {},
      );
    }

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Obx(() => IgnorePointer(
        ignoring: _ignoreAllGestures.value,
        child: wf.WebViewWidget.fromPlatformCreationParams(
          key: widget.key,
          params: widgetParams,
        ),
      )),
    );
  }

  void _onWebResourceError(wf_pi.WebResourceError err) {
    String? domain;
    String? failingUrl;

    if (err is wf_wk.WebKitWebResourceError) {
      domain = err.domain;
    } else if (err is wf_android.AndroidWebResourceError) {
      failingUrl = err.failingUrl;
    }

    widget.onWebResourceError?.call(
      WebResourceError(
        description: err.description,
        errorCode: err.errorCode,
        domain: domain,
        errorType: WebResourceErrorType.values.singleWhere(
          (value) => value.toString() == err.errorType.toString(),
        ),
        failingUrl: failingUrl,
      ),
    );
  }

  FutureOr<wf.NavigationDecision> _onNavigationRequest(
    wf.NavigationRequest request,
  ) async {
    final navigationDelegate = widget.navigationDelegate;
    if (navigationDelegate == null) {
      webViewXController.value =
          webViewXController.value.copyWith(source: request.url);
      return wf.NavigationDecision.navigate;
    }

    final delegate = await navigationDelegate.call(
      NavigationRequest(
        content:
            NavigationContent(request.url, webViewXController.value.sourceType),
        isForMainFrame: request.isMainFrame,
      ),
    );

    switch (delegate) {
      case NavigationDecision.navigate:
        webViewXController.value = webViewXController.value.copyWith(
          source: request.url,
        );
        return wf.NavigationDecision.navigate;
      case NavigationDecision.prevent:
        return wf.NavigationDecision.prevent;
    }
  }
  WebViewContent _initialContent() {
    return WebViewContent(
      source: widget.initialContent,
      sourceType: widget.initialSourceType,
    );
  }

  wf.WebViewController _createOriginalController() {
    late final wf.PlatformWebViewControllerCreationParams params;
    if (wf.WebViewPlatform.instance is wf_wk.WebKitWebViewPlatform) {
      late final Set<wf_wk.PlaybackMediaTypes> mediaTypesRequiringUserAction;
      switch (widget.initialMediaPlaybackPolicy) {
        case AutoMediaPlaybackPolicy.alwaysAllow:
          mediaTypesRequiringUserAction = const <wf_wk.PlaybackMediaTypes>{};
          break;
        case AutoMediaPlaybackPolicy.requireUserActionForAllMediaTypes:
          mediaTypesRequiringUserAction =
              wf_wk.PlaybackMediaTypes.values.toSet();
          break;
      }
      params = wf_wk.WebKitWebViewControllerCreationParams(
        mediaTypesRequiringUserAction: mediaTypesRequiringUserAction,
      );
    } else {
      params = const wf.PlatformWebViewControllerCreationParams();
    }

    return wf.WebViewController.fromPlatformCreationParams(params);
  }
  void _populateOriginalController() {
    final javaScriptMode = widget.javascriptMode == JavascriptMode.unrestricted
        ? wf.JavaScriptMode.unrestricted
        : wf.JavaScriptMode.disabled;
    originalWebViewController.setJavaScriptMode(javaScriptMode);
    originalWebViewController.setUserAgent(widget.userAgent);
    originalWebViewController.setNavigationDelegate(
      wf.NavigationDelegate(
        onProgress: widget.onProgress,
        onNavigationRequest: _onNavigationRequest,
        onPageStarted: widget.onPageStarted,
        onPageFinished: widget.onPageFinished,
        onWebResourceError: _onWebResourceError,
      ),
    );
    for (final cb in widget.dartCallBacks) {
      originalWebViewController.addJavaScriptChannel(
        cb.name,
        onMessageReceived: (msg) => cb.callBack(msg.message),
      );
    }

    if (originalWebViewController.platform
        is wf_android.AndroidWebViewController) {
      wf_android.AndroidWebViewController.enableDebugging(
          widget.mobileSpecificParams.debuggingEnabled);
      (originalWebViewController.platform
              as wf_android.AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(
        widget.initialMediaPlaybackPolicy ==
            AutoMediaPlaybackPolicy.requireUserActionForAllMediaTypes,
      );
    } else if (originalWebViewController.platform
        is wf_wk.WebKitWebViewController) {
      (originalWebViewController.platform as wf_wk.WebKitWebViewController)
          .setAllowsBackForwardNavigationGestures(
        widget.mobileSpecificParams.gestureNavigationEnabled,
      );
    }

    _load(_initialContent());
  }
  WebViewXController _createWebViewXController() {
    return WebViewXController(
      initialContent: widget.initialContent,
      initialSourceType: widget.initialSourceType,
      ignoreAllGestures: _ignoreAllGestures.value,
    )
      ..addListener(_handleChange)
      ..addIgnoreGesturesListener(_handleIgnoreGesturesChange)
      ..connector = originalWebViewController;
  }
  void _handleChange() {
    _load(webViewXController.value);
  }

  Uint8List? _convertPostRequestBody(Object? body) {
    if (body == null) {
      return null;
    }

    if (body is Uint8List) {
      return body;
    }

    if (body is Map || body is List) {
      body = json.encode(body);
    }

    if (body is String) {
      body = utf8.encode(body);
    }

    if (body is List<int>) {
      return Uint8List.fromList(body);
    }

    return null;
  }

  void _load(WebViewContent model) {
    switch (model.sourceType) {
      case SourceType.html:
        originalWebViewController.loadHtmlString(HtmlUtils.preprocessSource(
          model.source,
          jsContent: widget.jsContent,
        ));
        break;
      case SourceType.url:
      case SourceType.urlBypass:
        originalWebViewController.loadRequest(
          Uri.parse(model.source),
          headers: model.headers ?? {},
          body: _convertPostRequestBody(model.webPostRequestBody),
        );
        break;
    }
  }
  void _handleIgnoreGesturesChange() {
    _ignoreAllGestures.value = webViewXController.ignoresAllGestures;
  }

  @override
  void dispose() {
    webViewXController.removeListener(_handleChange);
    webViewXController.removeIgnoreGesturesListener(
      _handleIgnoreGesturesChange,
    );
    super.dispose();
  }
}