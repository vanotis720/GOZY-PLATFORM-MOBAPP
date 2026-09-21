part of 'base_controller.dart';

extension BaseControllerPart2 on BaseController {
  List countryInitFun() {
    List<Map> jsonList = codes;
    List<CountryCode> elements = jsonList.map((s) =>
        CountryCode(
          name: s['name'],
          code: s['code'],
          dialCode: s['dial_code'],
          flagUri: 'res/drawable/flags/${s['code'].toLowerCase()}.png',
        )).toList();
    elementsItemVal = elements;
    return elementsItemVal;
  }


  Widget drawGridLines({double space = 12, Color? color, Widget? child}) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        double width = constraints.maxWidth;
        double height = constraints.maxHeight;
        var h = Container(width: 1, height: height,
            color: color ?? appColors.mapGridLineColor);
        var v = Container(width: width,
            height: 1,
            color: color ?? appColors.mapGridLineColor);
        return ColoredBox(
          color: appColors.mapGridFillColor,
          child: Stack(children: <Widget>[
            ...List.generate((width / space).round(), (index) =>
                Positioned(left: index * space, child: h)),
            ...List.generate((height / space).round(), (index) =>
                Positioned(top: index * space, child: v)),
            if(child != null) child,
          ],
          ),
        );
      },
    );
  }

  Future<void> getFCMToken() async {
    debugPrint("getFCMToken: ${appPreference.deviceID}");
    if (Platform.isIOS) {
      await FirebaseMessaging.instance.requestPermission(
        announcement: true,
        carPlay: true,
        criticalAlert: true,
        alert: true,
        badge: true,
        sound: true,
      );
    }
    FirebaseMessaging.instance.getToken().then(setToken);
    FirebaseMessaging.instance.onTokenRefresh.listen(setToken);
  }

  void setToken(String? token) {
    appPreference.deviceID = token ?? '';
    debugPrint("setToken: ${ appPreference.deviceID}");
  }

  Future<dynamic> uploadImage(
      { File? file, required String uploadUrl, int? listid, List<
          File>? filelist, List<
          String>? uploadingImages, bool isFromProfile = false }) async {
    List<http.MultipartFile> newList = [];

    if (file != null) {
      var stream = http.ByteStream(file.openRead().cast());
      //   isLoading.value = true;
      String filename = file.path
          .split("/")
          .last;
      filename = filename
          .split("_")
          .last;
      final mimeType = lookupMimeType(file.path);
      final type = mimeType?.split('/')[0] ?? 'application';
      final subtype = mimeType?.split('/')[1] ?? 'octet-stream';

      debugPrint('uploading file: ${filename
          .split(".")
          .last}---$filename');
      var length = await file.length();
      newList.add(http.MultipartFile('file',
          stream, length,
          filename: filename,
          contentType: MediaType(type, subtype)));
    } else if (filelist != null && filelist.isNotEmpty) {
      for (var pickfile in filelist) {
        var stream = http.ByteStream(pickfile.openRead().cast());
        //  isLoading.value = true;
        String filename = pickfile.path
            .split("/")
            .last;
        filename = filename
            .split("_")
            .last;
        final mimeType = lookupMimeType(pickfile.path);
        final type = mimeType?.split('/')[0] ?? 'application';
        final subtype = mimeType?.split('/')[1] ?? 'octet-stream';
        var length = await pickfile.length();
        newList.add(http.MultipartFile('file',
            stream, length,
            filename: filename,
            contentType: MediaType(type, subtype)));
      }
    }
    debugPrint("new file name: --$newList");

    previousprogress = 0.0;
    customMultipartRequest = CustomMultipartRequest(
        'POST', Uri.parse(uploadUrl),
        onProgress: (int bytes, int total) {
          final progress = bytes / total;
          double progressforpercentage = 100 * progress;
          String bytestransfer = "${(bytes / 1048576).toStringAsFixed(
              2)} MB / ${(total / 1048576).toStringAsFixed(2)} MB";
          print(
              'docuentuploaderrorauth uploadprogress: $bytestransfer === ${progressforpercentage
                  .toStringAsFixed(2)} ---$progress');
          uploadProgress?.value = progress.toString();
          previousprogress = progress;
          uploadingImages?.remove(file);
          if (progressforpercentage >= 100) {
            uploadProgress?.value = '1';
            Future.delayed(const Duration(milliseconds: 200)).then((value) {
              uploadProgress?.value = '101';
            });
          }
        });
    Map<String, String> headers = {
      "auth": appPreference.accessToken!,
      'Content-Type': 'multipart/form-data',
    };
    customMultipartRequest?.files.addAll(newList);
    customMultipartRequest?.headers.addAll(headers);
    if (listid != null) {
      customMultipartRequest?.fields['listId'] = listid.toString();
    }

    print("customMultipartRequest--> $customMultipartRequest");

    try {
      var res = await customMultipartRequest!.send();

      http.Response response;
      response = await http.Response.fromStream(res);
      final result = json.decode(response.body);
      print("Upload Res: $result");

      if (result["status"] == 200) {
        isLoading.value = false;
        change(rxVariable: isRxBottomSheetLoading, value: false);
        if (isFromProfile) {
          appPreference.profileImage = result["file"]["filename"];
          return result["file"]["filename"];
        }
        return result["files"][0];
      } else {
        isLoading.value = false;
        change(rxVariable: isRxBottomSheetLoading, value: false);
        showToast(result["errorMessage"],);
        return '';
      }
    } on Exception catch (e) {
      debugPrint('network exception: ${e.toString()}');
      return "network";
    }
  }

  Future<String?>? cropFile(String result) async {
    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: result,
      uiSettings: [
        AndroidUiSettings(
          activeControlsWidgetColor: AppColors().primaryColor,
          aspectRatioPresets: [
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.square,
          ],
        ),
        IOSUiSettings(
          aspectRatioPresets: [
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.square,
            CropAspectRatioPreset.ratio4x3,
          ],
        ),
      ],

    );
    return croppedFile?.path;
  }

  void showToast(String msg, [double seconds = 2]) {
    AppToast().show(message: msg);
    FocusManager.instance.primaryFocus!.unfocus();
  }

  Future<String> deletePhoto(String filename, Function callBackFun) async {
    try {
      isDeletingFile.value = true;
      debugPrint("Deleting photo: $filename");

      var response = await http.post(
        Uri.parse(Constants.removeClaimDamage),
        headers: {
          "auth": appPreference.accessToken!,
        },
        body: {
          "filename": filename
        }
      );

      debugPrint("Delete photo response: ${response.body}");

      var result = json.decode(response.body);
      isDeletingFile.value = false;
      if (result["status"] == 200) {
        callBackFun();
        return "success";
      } else {
        showToast(result["errorMessage"]);
        return "error";
      }
    } catch (e) {
      debugPrint("Delete photo error: $e");
      showToast("Something went wrong");
      return "error";
    }
  }


  Widget getLoader({required String loader, Color? color, bool? changed}) {
    debugPrint("loader show 2:${isLoading.value} -- $this");
    //  return 0.0.toHeight();
    String lottiekey = '${loader}_${color}_${Get.isPlatformDarkMode
        ? "dark"
        : "light"}';
    if (cachedWidgets[lottiekey] != null && !changed!) {
      return cachedWidgets[lottiekey]!;
    } else {
      LottieDelegates lottiedelegates = getLottieDelegates(loader, appColors.secondaryColor);
      return DotLottieLoader.fromAsset("res/loader/$loader.lottie",
          frameBuilder: (BuildContext ctx, DotLottie? dotlottie) {
            if (dotlottie != null) {
              cachedWidgets[lottiekey] =
                  Lottie.memory(dotlottie.animations.values.single,
                      backgroundLoading: false,
                      options: LottieOptions(enableMergePaths: true),
                      delegates: lottiedelegates);
              return cachedWidgets[lottiekey]!;
            } else {
              return const SizedBox.shrink();
            }
          });
    }
  }

  LottieDelegates getLottieDelegates(String loader, Color? color) {
    Color? lottieColor = color;
    if (loader == LottieLoaders.three_dots_loader.name) {
      return LottieDelegates(
        values: [
          ValueDelegate.color(
            const ['Shape Layer 3', 'Ellipse 1', '**'],
            value: darken(lottieColor!, .01),
          ),
          ValueDelegate.color(
            const ['Shape Layer 1', 'Ellipse 1', '**'],
            value: lighten(lottieColor, .1),
          ),
          ValueDelegate.color(
            const ['Shape Layer 2', 'Ellipse 1', '**'],
            value: lighten(lottieColor, .4),
          ),
        ],
      );
    } else {
      return LottieDelegates(
        values: [
          ValueDelegate.color(
            const ['pin/geoloc Silhouettes', 'Groupe 1', '**'],
            value: lottieColor,
          ),
          ValueDelegate.color(
            const ['speed/geoloc Silhouettes', 'Groupe 1', '**'],
            value: lottieColor,
          ),
          ValueDelegate.color(
            const ['speed/geoloc Silhouettes', 'Groupe 2', '**'],
            value: lottieColor,
          ),
          ValueDelegate.color(
            const ['speed/geoloc Silhouettes', 'Groupe 3', '**'],
            value: lottieColor,
          ),
          ValueDelegate.color(
            const ['wheels/geoloc Silhouettes', 'Groupe 1', '**'],
            value: darken(lottieColor ?? appColors.secondaryColor),
          ),
          ValueDelegate.color(
            const ['wheels/geoloc Silhouettes', 'Groupe 2', '**'],
            value: darken(lottieColor ?? appColors.secondaryColor),
          ),
          ValueDelegate.color(
            const ['wheels/geoloc Silhouettes', 'Groupe 3', '**'],
            value: lottieColor,
          ),
          ValueDelegate.color(
            const ['wheels/geoloc Silhouettes', 'Groupe 4', '**'],
            value: lottieColor,
          ),
          ValueDelegate.color(
            const ['car/geoloc Silhouettes', 'Groupe 1', '**'],
            value: appColors.primaryColor,
          ),
        ],
      );
    }
  }

  Color darken(Color color, [double amount = .1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }

  Color lighten(Color color, [double amount = .1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final hslLight =
    hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));
    return hslLight.toColor();
  }

  Future<map.Marker> placeToMarker(Place place,
      {required RxInt selectedId,
        required bool isMarkerSelected,
        VoidCallback? onTap}) async {
    ui.PictureRecorder recorder = ui.PictureRecorder();
    ui.Canvas canvas = ui.Canvas(recorder);
    CustomMapMarker customMarker = CustomMapMarker(
      fontSize: 34,
        place: place,
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        selectedId: selectedId,
        isChange: isMarkerSelected,
        borderRadius: 8);
    double width =
        customMarker.textPainter.width + customMarker.textPainteroffset.dx;
    final double height =
        customMarker.textPainter.height + customMarker.textPainteroffset.dy;
    final ui.Size size = ui.Size(width + 20, height + 50);
    customMarker.paint(canvas, size);
    ui.Picture picture = recorder.endRecording();
    final ui.Image image = await picture.toImage(
      size.width.toInt(),
      size.height.toInt(),
    );

    final ByteData? byteData = await image.toByteData(
      format: ui.ImageByteFormat.png,
    );
    var icon =
    map.BitmapDescriptor.bytes(
        byteData!.buffer.asUint8List(), imagePixelRatio: BaseController.imagePixelRatio);
    var marker = map.Marker(
        markerId: map.MarkerId(place.id),
        position: place.position,
        icon: icon,
        zIndex: selectedId.value == int.parse(place.id) ? 1.0 : 0.0,
        onTap: onTap);
    return marker;
  }

  bool createOverlay(TickerProvider tickerProvider,
      {GlobalKey<RectGetterState>? startkey,
        GlobalKey<RectGetterState>? endkey,
        required ReactiveVariable<bool> isOverlayAdded,
        required BaseController baseController,
        required BuildContext context}) {
    _startkey = startkey;
    _endkey = endkey;
    _buildContext = context;
    transitionOverlayEntry = OverlayEntry(
      builder: (context) {
        return AnimatedBuilder(
          animation: rectAnimation,
          builder: (context, child) {
            return Positioned(
                top: rectAnimation.value?.top,
                left: rectAnimation.value?.left,
                child: _transitionWidget.toResizeWidget(
                  height: rectAnimation.value?.height,
                  width: rectAnimation.value?.width,
                )
            );
          },
        );
      },
    );
    _animationController = AnimationController(
      vsync: tickerProvider,
      duration: const Duration(milliseconds: 400),
    );
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed ||
          status == AnimationStatus.dismissed) {
        transitionOverlayEntry.remove();
      }
      if (status == AnimationStatus.completed) {
        baseController.change(rxVariable: isOverlayAdded, value: true);
      } else if (status == AnimationStatus.reverse) {
        baseController.change(rxVariable: isOverlayAdded, value: false);
      }
    });

    return true;
  }

  void startTransition(bool toPageView,
      {required Widget transitionWidget}) async {
    if (_startkey != null && _endkey != null) {
      _transitionWidget = transitionWidget;
      Rect? startRect = RectGetter.getRectFromKey(_startkey!);
      Rect? endRect = RectGetter.getRectFromKey(_endkey!);
      rectAnimation = RectTween(
        begin: startRect,
        end: endRect,
      ).animate(_animationController);

      Overlay.of(_buildContext!).insert(transitionOverlayEntry);
      if (toPageView) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  AnimatedBuilder buildWhiteCurtain(
      {Color? bgColor, Widget? CustomWidget, bool isReverse = false}) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        if (CustomWidget != null) {
          return Visibility(
            visible: (isReverse
                ? (1 - _animationController.value)
                : _animationController.value) ==
                1.0,
            child: CustomWidget,
          );
        }
        return _animationController.isDismissed
            ? const SizedBox.shrink()
            : Positioned.fill(
          child: Opacity(
            opacity: _animationController.value,
            child: ColoredBox(color: bgColor ?? Colors.white),
          ),
        );
      },
    );
  }

  void resetLogin({required bool isLogin}) {
    Get.offAll(() => Login(),
        arguments: { "isNewRoute": true},
        binding: AuthBinding(),
        routeName: "/login");
  }


  void changeTheme({bool? isEnableForceUpdate}) {
    appThemeChanged.toggle();
    if (isDarkMode()) {
      rootBundle.loadString(Assets.assetsMapStyleDark).then((string) {
        googleMapStyle = string;
      });
    } else {
      rootBundle.loadString(Assets.assetsMapStyle).then((string) {
        googleMapStyle = string;
      });
    }
    debugPrint('isPopUpMenuOpen: $isPopUpMenuOpen');
    if (isPopUpMenuOpen) {
      Get.back();
      isPopUpMenuOpen = false;
    }
    Get.changeTheme(
        isDarkMode() ? appTheme.darkTheme() : appTheme.lightTheme());
    if (isEnableForceUpdate ?? true) {
      Get.forceAppUpdate();
    }
  }
}