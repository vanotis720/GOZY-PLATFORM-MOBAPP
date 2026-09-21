part of 'common_extension_functions.dart';

extension ListStringExtension on List<String> {
  Widget toBottomTabBar({GestureTapCallback? onTap,required bool isSelected, bool isShowDot = false, bool isshowBorderOnBottomBar = false,bool? isSelectIcon}){
    var updateSize = isSelected.obs;
    Duration animationDuration = const Duration(milliseconds: 250);
    List<Widget> children =  [
      Obx(() {
        var (width,height) = getHeight(updateSize, animationDuration);
        return
          [
            AnimatedContainer(
            decoration: isshowBorderOnBottomBar ? BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppColors.staticwhite : null,
                border: Border.all(color: !isSelected ? AppColors.staticwhite : Colors.transparent)
            ) : null,
            duration: animationDuration,
            width: width,
            height: height,
            padding: isshowBorderOnBottomBar ? pad(a:5) : pad(end: 1),
            child: this[0].toSVG(
                colour: isSelected &&(isSelectIcon ?? true) ? appColors.secondaryColor : appColors.customTextColor),
          ),
            if(isShowDot)
              Positioned(
                right: 0,
                top:2,
                child: Container(
                  decoration: BoxDecoration(shape: BoxShape.circle, color: appColors.errorRed),
                  width: 6,
                  height: 6,
                ),
              ),
          ].toStack()
        ;
      }
      ),

      5.toHeight(),
      CustomText(
        text: this[1],
        size:11,
        color: isSelected ? appColors.secondaryColor : appColors.customTextColor,
        fontWeight: FontWeight.w400,
        textAlign: TextAlign.center,
        maxLines: 1,
      ).toPad(horizontal: 3),
    ];

    return InkResponse(
      highlightColor: Colors.grey,
      onTap:(){
        updateSize.value = true;
        onTap!();
      },
      child:
      children.toColumn(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max)
          .toResizeWidget(width: deviceWidth/5, ),
    );
  }



  Widget toPopularLocationList({required double itemWidth ,required double itemHeight,double? borderRadius,String? AreaOfBorderRadius,String? parentWidget, bool isShimmerView = false, String? placeholderURL}){
    BorderRadiusGeometry? borderdadius;
    double? horizontalpad = 0;

    if(AreaOfBorderRadius == 'top'){
      borderdadius =   BorderRadius.only(
        topLeft: Radius.circular(borderRadius ?? AppDimen.appBorderRadius),
        topRight: Radius.circular(borderRadius ?? AppDimen.appBorderRadius),
      );
      itemHeight = itemHeight-60;
      horizontalpad = 10;
      itemWidth = itemWidth-horizontalpad;
    }

    Widget imageWidget = ClipRRect(
      borderRadius:  BorderRadius.only(topRight: Radius.circular(borderRadius ?? AppDimen.appBorderRadius), topLeft: Radius.circular(borderRadius ?? AppDimen.appBorderRadius)),
      child: CustomClipNetworkImage(
        imageUrl:this[0],
        width: itemWidth,
        height: itemHeight,
        isShimmerView: isShimmerView,
        placeholderURL: placeholderURL,
      ),
    );

    Widget textWidget  = isShimmerView ?
    CustomText(text: 6.toGenerateEmptyString(),
      color:  appColors.shimmerplaceholderColor ,
      size : AppDimen.textSize_16,
      isShimmerView: isShimmerView,
      maxLines:  1,
      textAlign: TextAlign.center,
      overflow: TextOverflow.ellipsis,
      fontWeight: AppFont.medium,) :
    CustomText(text:  this[1],
      color:  appColors.customTextColor,
      size : AppDimen.textSize_16,
      textAlign: TextAlign.center,
      overflow: TextOverflow.ellipsis,
      fontWeight: AppFont.medium,);
    if(parentWidget == 'column'){
      return [
        CustomContainer(
            margin: pad(w: horizontalpad),
            width: itemWidth,
            height: itemHeight,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(borderRadius ?? AppDimen.appBorderRadius),
                topRight: Radius.circular(borderRadius ?? AppDimen.appBorderRadius),
              ),
              boxShadow: [
                BoxShadow(
                  color: appColors.theme4AppBarBg,
                  offset: Offset(-6.30, 6.30),
                  blurRadius: 0,
                  spreadRadius: 0,
                )
              ],
            ),
            body: imageWidget),
        Align(
            alignment: Alignment.center,
            child: textWidget.toResizeWidget(width: itemWidth)).toStretch()
      ].toColumn(crossAxisAlignment: CrossAxisAlignment.center,mainAxisAlignment: MainAxisAlignment.start);
    } else {
      return [
        imageWidget,
        textWidget
            .toPad(bottom: 20, horizontal: 10.0)
            .toResizeWidget(width: itemWidth),
      ].toStack(alignment: AlignmentDirectional.bottomCenter);
    }
  }

  (double, double) getHeight(var updatesize, Duration animationDuration) {
    if(updatesize.value) {
      if(!isDisableForceUpdate) {
        Future.delayed(animationDuration).then((value) {
          updatesize.value = false;
        });
      } else {
        updatesize.value = false;
      }
    }
    return (updatesize.value ? 30 :  25 , updatesize.value ? 30 :  30);
  }

}

extension ListFocusNodeExtension on List<CustomFocusNode> {
  bool toFocus({List<CustomTextEditingController?>? textControllerList}){
    bool isFocusCleared = true;
    for (final (index, item) in indexed) {
      if(index+1 != length){


        if (item == currentFocusNode) {
          if(textControllerList !=null) {
            for(int i=index+1; i<textControllerList.length; i++){
              if( textControllerList[i]!=null && textControllerList[i]!.text.isEmpty) {
                isFocusCleared = false;
                this[i].requestFocus();
                break;
              }
            }
            break;

          } else{
            isFocusCleared = false;
            this[index + 1].requestFocus();
            break;
          }

        }
      }else{
        FocusManager.instance.primaryFocus?.unfocus();
        break;
      }
    }
    debugPrint("_isFocusCleared: $isFocusCleared");
    return isFocusCleared;
  }

  CustomFocusNode? toAddListener(){

    for (final item in this) {
      item.addListener(() {
        if (item.hasFocus) {
          currentFocusNode = item;
          debugPrint("ListFocusNodeExtension:  currentFocusNode  --- $currentFocusNode ");
        }
      });
    }
    return null;
  }
}

extension scrollExtension on ScrollController{
  Future<void> movetoposition({bool toTop = false,toBottom = false, double scrollposition = 0, int? duration}) async {
    await animateTo(
      toBottom ? position.maxScrollExtent : toTop ? 0.0 : scrollposition,
      duration: Duration(milliseconds: duration ?? 300),
      curve: Curves.easeOut,
    );

  }
}
extension flexWidgetsExtension on List<Widget> {
  Widget toFlexWidget({
    required String widgetType,
    MainAxisSize? mainAxisSize,
    MainAxisAlignment? mainAxisAlignment = MainAxisAlignment.center,
    TextDirection? textDirection,
    VerticalDirection? verticalDirection,
    TextBaseline? textBaseline,
    Clip? clipBehavior,
    CrossAxisAlignment? crossAxisAlignment,
    AlignmentGeometry? alignment,
    StackFit? fit,
  }) {
    switch (widgetType.toLowerCase()) {
      case 'column':
        return toColumn(
          mainAxisSize: mainAxisSize,
          mainAxisAlignment: mainAxisAlignment,
          textDirection: textDirection,
          verticalDirection: verticalDirection,
          textBaseline: textBaseline,
          clipBehavior: clipBehavior,
          crossAxisAlignment: crossAxisAlignment,
        );

      case 'row':
        return toRow(
          mainAxisSize: mainAxisSize,
          mainAxisAlignment: mainAxisAlignment,
          textDirection: textDirection,
          verticalDirection: verticalDirection,
          textBaseline: textBaseline,
          clipBehavior: clipBehavior,
          crossAxisAlignment: crossAxisAlignment,
        );

      case 'stack':
        return toStack(
          alignment: alignment,
          textDirection: textDirection,
          fit: fit,
          textBaseline: textBaseline,
          clipBehavior: clipBehavior,
          crossAxisAlignment: crossAxisAlignment,
        );

      default:
        return toScroll();
    }
  }

  Widget toRow({MainAxisSize? mainAxisSize,
    MainAxisAlignment? mainAxisAlignment= MainAxisAlignment.center,
    TextDirection? textDirection,
    VerticalDirection? verticalDirection,
    TextBaseline? textBaseline,
    Clip? clipBehavior,
    CrossAxisAlignment? crossAxisAlignment,
    double? spacing,
  }){
    return flexWidget(
        direction: Axis.horizontal,
        spacing: spacing,
        mainAxisSize: mainAxisSize,
        mainAxisAlignment:mainAxisAlignment,
        textDirection:textDirection,
        verticalDirection:verticalDirection,
        textBaseline:textBaseline,
        clipBehavior:clipBehavior,
        crossAxisAlignment:crossAxisAlignment);
  }

  Widget toColumn({MainAxisSize? mainAxisSize,
    MainAxisAlignment? mainAxisAlignment,
    TextDirection? textDirection,
    VerticalDirection? verticalDirection,
    TextBaseline? textBaseline,
    Key? key,
    double? spacing,
    Clip? clipBehavior,
    CrossAxisAlignment? crossAxisAlignment = CrossAxisAlignment.start}){
    return flexWidget(
        direction: Axis.vertical,
        mainAxisSize: mainAxisSize,
        key: key,
        spacing: spacing,
        mainAxisAlignment:mainAxisAlignment,
        textDirection:textDirection,
        verticalDirection:verticalDirection,
        textBaseline:textBaseline,
        clipBehavior:clipBehavior,
        crossAxisAlignment:crossAxisAlignment);
  }

  Widget toStack({
    AlignmentGeometry? alignment,
    TextDirection? textDirection,
    StackFit? fit,
    TextBaseline? textBaseline,
    Clip? clipBehavior,
    CrossAxisAlignment? crossAxisAlignment}){
    return Stack(
      textDirection:textDirection,
      alignment :  alignment?? AlignmentDirectional.topStart,
      clipBehavior:clipBehavior ?? Clip.hardEdge,
      fit : fit ?? StackFit.loose,
      children: this,);
  }



  Widget flexWidget({
    required Axis direction,
    MainAxisSize? mainAxisSize,
    MainAxisAlignment? mainAxisAlignment,
    TextDirection? textDirection,
    VerticalDirection? verticalDirection,
    TextBaseline? textBaseline,
    Clip? clipBehavior,
    double? spacing,
    Key? key,
    CrossAxisAlignment? crossAxisAlignment}) {

    return Flex(
      direction: direction,
      key: key,
      spacing: spacing ?? 0.0,
      mainAxisSize:mainAxisSize ?? MainAxisSize.max ,
      mainAxisAlignment: mainAxisAlignment ??  MainAxisAlignment.start,
      crossAxisAlignment: crossAxisAlignment ??  CrossAxisAlignment.center,
      textDirection: textDirection,
      textBaseline: textBaseline,
      clipBehavior: clipBehavior ?? Clip.none,
      children: this,
    );
  }


  Widget toScroll({EdgeInsetsGeometry? padding,ScrollPhysics? physics , ScrollController? scrollController, Axis? scrollDirection , bool? shrinkWrap}) {
    return
      ListView(
        padding: padding ?? EdgeInsets.zero,
        physics: physics ?? const ClampingScrollPhysics(),
        cacheExtent: 99999,
        primary: false,
        scrollDirection: scrollDirection ?? Axis.vertical ,
        controller:scrollController ,
        shrinkWrap: shrinkWrap ?? true,
        children: this,
      ).addScrollConfig();
  }

  Widget toNestedScroll({double? expandedHeight, ScrollController? scrollController, double? toolbarHeight}){
    return CustomScrollView(
      physics:  const ClampingScrollPhysics(),
      controller: scrollController,
      slivers: <Widget>[
        SliverAppBar(
          expandedHeight: expandedHeight ?? 250.0,
          toolbarHeight: toolbarHeight ?? kToolbarHeight,
          floating: false,
          pinned: true,
          surfaceTintColor: Colors.transparent,
          automaticallyImplyLeading : false,
          backgroundColor: appColors.white,
          shadowColor: appColors.white,
          flexibleSpace: FlexibleSpaceBar(
            background: first,
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
                (context,index) =>last,
            childCount: 1,
          ),
        ),
      ],
    );
  }
}

extension CustomTextExtension on CustomText {
  Widget toScroll({Axis? scrollDirection}) {
    return
      SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        scrollDirection:scrollDirection ?? Axis.vertical,
        child: this,
      ).addScrollConfig();
  }
}
extension TextExtension on Text {
  Text toCurrencyText({ String? symbol}){
    if(symbol !=null && data!.contains(symbol) && !Platform.isIOS) {
      TextSpan textSpan = TextSpan(
        text: (data),
        style: (style ?? TextStyle()),
      );
      return Text.rich(
        TextSpan(children: textSpan.toCurrencyTextSpan(symbol: symbol)),
      );
    }else{
      return this;
    }
  }
}

extension imageExtension on Image{
  Widget combinedBuilder({
    required BaseController controller,
    double? deductionHeight,
    required Widget Function( BoxConstraints constraints,Size imagesize, bool isSpaceLess) builder,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxHeight = constraints.maxHeight;
        return FutureBuilder<Size>(
          future: controller.getImageSize(image: image),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return CircularProgressIndicator();
            final imageSize = snapshot.data!;
            final scaleFactor = constraints.maxWidth / imageSize.width;
            final scaledHeight = (imageSize.height * scaleFactor)+ (deductionHeight ?? 0);
            debugPrint("_getImageSize: $maxHeight -- $scaledHeight");
            return builder(constraints, snapshot.data!, scaledHeight < maxHeight);
          },
        );
      },
    );
  }
}

extension PaddingExtension on Widget {
  Widget toPad({double start=0,double end=0,double top=0,double bottom=0,double? horizontal,double? vertical,double? all, EdgeInsetsGeometry ?  edgeInsetsGeometry}){
    return Padding(
      padding: edgeInsetsGeometry ?? EdgeInsetsDirectional.only(start: all ?? horizontal?? start,end: all ?? horizontal?? end,top:all ?? vertical?? top,bottom: all ?? vertical??bottom),
      child: this,
    );
  }

  Widget toFadeSlideAnimateWidget({required ReactiveVariable rxbool, required GetxController controller, Offset? fromOffset, int? durationInmillisec}){
    return GetBuilder(
      id: rxbool.id,
      init: controller,
      builder: (context) => AnimatedOpacity(
        opacity:  rxbool.value ? 1 : 0,
        duration:  Duration(milliseconds: durationInmillisec ?? 1000),
        child: AnimatedSlide(
            offset:  rxbool.value ? Offset.zero : (fromOffset ?? Offset(0, 2)),
            duration:  Duration(milliseconds: durationInmillisec ?? 1000),
            child: this
        ),
      ),
    );
  }

  Widget toFadeScaleAnimateWidget({required RxBool rxbool, Offset? fromOffset, int? durationInmillisec }){
    return Obx(() =>AnimatedOpacity(
      opacity:  rxbool.value ? 1 : 0,
      duration:  Duration(milliseconds: durationInmillisec ?? 1000),
      child: AnimatedScale(
          scale: rxbool.value ? 1 : 0,
          duration:  Duration(milliseconds: durationInmillisec ?? 1000),
          child: this),
    ),
    );
  }

  Widget toLinearGradientShaderMask({ AlignmentGeometry? begin, AlignmentGeometry? end, List<Color>? colors,double? shaderborderRadius }){
    return ClipRRect(
      borderRadius: BorderRadius.all(Radius.circular(shaderborderRadius ?? 0.0)),
      child: ShaderMask(
        shaderCallback: (rect) {
          return LinearGradient(
            begin:begin ?? Alignment.topCenter,
            end: end ?? Alignment.bottomCenter,
            colors: colors ?? [Colors.transparent, Colors.black.withAlpha(200)],
          ).createShader(Rect.fromLTRB(0, 0, rect.width, rect.height));
        },
        blendMode: BlendMode.darken,
        child: this,
      ),
    );
  }


  Widget toReviewListItemContainer(
      {double? borderRadius,
      double? width,
      bool isDottedBorder = false,
      Color? borderColor,
      Color? fillColor}) {
    debugPrint("toReviewListItemContainer width:  $width");
    if(isDottedBorder){

      return DottedBorderView(
          borderRadius: borderRadius,
          dottedlineColor: appColors.colorCommonLinkColor,
          child: CustomBorderContainer(
              color: fillColor ?? appColors.white,
              borderColor: borderColor ?? appColors.filterDividerColor,
              borderWidth: 0,
              padding: pad(w:15),
              width: width,
              borderRadius: borderRadius ?? AppDimen.appBorderRadius,
              alignment: AlignmentDirectional.centerStart,
              body: this
          )).toPad(end: 2,start: 1,vertical: 1);
    } else {
      return CustomBorderContainer(
          padding: pad(w: 15),
          width: width,
          margin: pad(end: 2,start: 2,h: 2),
          color: fillColor ?? appColors.white,
          borderColor: borderColor ?? appColors.filterDividerColor,
          borderWidth: 1,
          borderRadius: borderRadius ?? AppDimen.appBorderRadius,
          alignment: AlignmentDirectional.centerStart,
          body: this
      );
    }
  }

  Widget toFutureBuilder({required String imageUrl,Widget? placeHolderWidget,String? key}){

    //  when imageURL is not 200 or invalid imageurl to avoid high cpu usage & Heat issue
    if(key !=null && cachedWidgets[key] !=null){
      return cachedWidgets[key]!;
    }

    var FutureWidget =   FutureBuilder<bool>(
      future: validateImage(imageUrl), // async work
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return placeHolderWidget ?? Text('');
          default:
            if (snapshot.hasError || (snapshot.data !=null && !snapshot.data!)) {
              return placeHolderWidget ?? 0.toHeight();
            } else {
              if(key !=null && cachedWidgets[key] ==null) {
                cachedWidgets[key] = this;
              }
              return this;
            }
        }
      },
    );
    if(key !=null && cachedWidgets[key] ==null) {
      cachedWidgets[key] = FutureWidget;
    }
    return FutureWidget;
  }


  Widget toRefresh({required RefreshCallback onRefresh,ScrollNotificationPredicate scrollpredicate = defaultScrollNotificationPredicate}){
    return RefreshIndicator(
        color: appColors.black,
        backgroundColor: appColors.white,
        onRefresh: onRefresh,
        notificationPredicate: scrollpredicate,
        child: this
    );
  }

  Widget toMaterialLocalization({bool? isStartOnLTR, String? content }){
    return Localizations(
        locale:  Locale('en', 'US'),
        delegates: const <LocalizationsDelegate<dynamic>>[
          DefaultWidgetsLocalizations.delegate,
          DefaultMaterialLocalizations.delegate,
        ],
        child: ConditionalParentWidget(
          condition: isStartOnLTR !=null,
          parentBuilder: (Widget child) {
            return Align(
              alignment: (isStartOnLTR! && intl.Bidi.isRtlLanguage(Get.locale?.languageCode)) ? AlignmentDirectional.centerEnd : AlignmentDirectional.centerStart,
            );
          },
          child: this,
        )
    );
  }

  Widget addScrollConfig(){
    return  ScrollConfiguration(
        behavior: ListViewScrollBehavior(),
        child: this
    );
  }

  Widget toOverlayWidget(ReactiveVariable isShowOverlay){
    return  Opacity(
      opacity: isShowOverlay.value ? 1 : 0,
      child: IgnorePointer(
        ignoring: !isShowOverlay.value,
        child: this,
      ),
    );
  }

  Widget toStretch({int flex=1, bool isExpanded = true,bool isReturnChild =false}){
    if(!isReturnChild) {
      return Flexible(
        flex: flex,
        fit: isExpanded ? FlexFit.tight : FlexFit.loose,
        child: this,
      );
    } else {
      return this;
    }
  }

  Widget toAnnotatedRegion({required BaseController controller}){
    bool isDarkMode = controller.isDarkMode();//
    return  AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarBrightness: isDarkMode ? Brightness.dark : Brightness.light,
        statusBarIconBrightness:isDarkMode ? Brightness.light : Brightness.dark,
        systemNavigationBarIconBrightness: isDarkMode ? Brightness.light :Brightness.dark,
      ), child: this,);
  }

  Widget toPositionedAlign({AlignmentGeometry? alignment}){
    return  Positioned.fill(
        child: Align(
            alignment: alignment ?? Alignment.center,
            child: this
        )
    );
  }

  Widget toResizeWidget({double? width, double? height, double? all, Color? color, bool isDeviceFit = false, Alignment? alignment}){
    if(isDeviceFit) {
      width = deviceWidth;
      height = deviceHeight;
    }
    return
      color ==null ?
      SizedBox(
        width: all ?? width ,
        height:all ?? height,
        child: this,
      ) : Container(
        width: all ?? width,
        height: all ?? height,
        color: color,
        alignment: alignment,
        child: this,
      );
  }
  Widget toTopCornerWidget({ Color? bgcolor, double? radius,bool? isAll}){
    var borderradius = BorderRadius.only(
      topLeft: Radius.circular(radius ?? 20),
      topRight: Radius.circular(radius ?? 20),
      bottomLeft: Radius.circular((isAll !=null && isAll)? radius ?? 20 : 0 ),
      bottomRight: Radius.circular((isAll !=null && isAll)? radius ?? 20 : 0 ),
    );
    return  ColoredBox(
      color: bgcolor ?? appColors.appBGColor,
      child: CustomContainer(
          width: deviceWidth,
          decoration: BoxDecoration(
            color:  bgcolor ?? appColors.appBGColor,
            border: Border(
              top: BorderSide(width: 2,
                  color: appColors.popularLocationShimmerPlaceholderColor.withAlpha(100)),
            ),
            borderRadius: borderradius,
          ),
          body: ClipRRect(
            borderRadius: borderradius,
            child: this,
          )
      ),
    );
  }


  Widget toShimmer({required BaseController controller}){
    return  Shimmer(
      controller: controller,
      child: this,
    );

  }

  Widget toShowEmpty ({required BaseController controller, required Widget emptyWidget,  bool  Function()? isShowEmpty, ScrollPhysics? physics} ){
    return GetBuilder(
        id: controller.isRxBottomSheetLoading.id,
        init: controller,
        builder: (context){
          bool isEmpty = isShowEmpty!=null ? isShowEmpty() : false;
          return
            !((Get.isBottomSheetOpen ?? false) ? controller.isRxBottomSheetLoading.value : controller.isLoading.value) && isEmpty ?
            emptyWidget.toScroll(physics: physics ?? AlwaysScrollableScrollPhysics()):
            this;
        });
  }

  Widget toCircle({
    GestureTapCallback? onTap,
    Color? color,
    BoxShape? shape,
    double? padding,
    double? margin,
    double? startMargin,
    double? borderWidth,
    double? borderRadius,
    bool? isBorderNeed,
    Color? borderColor,
    bool? isCard,
  }){
    return  isCard!=null && isCard ?
    Card(
      color: appColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(30.0),
        ),
      ),
      child: toPad(all: padding ?? 12),).toPad(end: startMargin !=null ? startMargin +(margin ?? 10) : (margin ?? 10), start: startMargin ?? 0) :
    isBorderNeed != null && isBorderNeed ?
    toOnTap(
      onTap: onTap,
      child: Container(
        child: this,
        padding: pad(a:padding ?? 12),
        margin: pad(end: startMargin !=null ? startMargin +(margin ?? 10) : (margin ?? 10), start: startMargin ?? 0),
        decoration: BoxDecoration(shape: shape ?? BoxShape.circle,
            borderRadius: shape == BoxShape.rectangle &&  borderRadius !=null ?BorderRadius.all(
              Radius.circular(borderRadius),
            ): null,
            border: Border.all(color: borderColor ?? appColors.myTripsBGColor, width: borderWidth ?? 1.0), color: color ?? appColors.white),
      ),
    )
        : CustomBorderContainer(
      body: this,
      padding: pad(a:padding ?? 12),
      margin: pad(end: startMargin !=null ? startMargin +(margin ?? 10) : (margin ?? 10), start: startMargin ?? 0),
      borderColor: borderColor,
      borderWidth: 1,
      shape: BoxShape.circle,
      color:  color,
      onTap: onTap,
    );
  }

  Widget toFitToDeviceWidth({double? width}){
    return OverflowBox(
      maxWidth: width ?? deviceWidth,
      child: this,);
  }

  Widget toClipTopRounded({required double radius}){
    if(radius <= 0) return this;
    return ClipPath(
      clipper: _TopRoundedClipper(radius: radius),
      child: this,
    );
  }

  Widget toRefreshSheet(){
    return GetBuilder<BottomSheetController>(
        builder: (newController){
          return this;
        }
    );

  }
  Widget toScroll({Axis? scrollDirection,ScrollPhysics? physics, ScrollController? controller }) {
    return
      SingleChildScrollView(
        physics: physics?? ClampingScrollPhysics(),
        controller: controller,
        scrollDirection:scrollDirection ?? Axis.vertical,
        child: this,
      ).addScrollConfig();
  }

}

Widget toRefreshingSheet({required Widget child}){
  return GetBuilder<BottomSheetController>(
      builder: (newController){
        debugPrint("toRefreshingSheet GetBuilder: ${newController.isRefresh.value}");
        return child;
      }
  );

}

extension TextStyleX on TextStyle {
  TextStyle underlined({
    Color? color,
    double distance = 1,
    double thickness = 1,
    TextDecorationStyle style = TextDecorationStyle.solid,
  }) {
    return copyWith(
      shadows: [
        Shadow(
          color: color ?? appColors.customTextColor,
          offset: Offset(0, -distance),
        )
      ],
      color: Colors.transparent,
      decoration: TextDecoration.underline,
      decorationThickness: thickness,
      decorationColor: color ??  appColors.customTextColor,
      decorationStyle: style,
    );
  }
}

extension PermissionbasedEvent on Permission {
  Future<void> toCheckPermission({required String content, required Function permissionEnabledFunction , required BaseController controller, String? additionalContent, bool? isNeedInsetPadding = true})async{
    if(await isGranted){
      permissionEnabledFunction();
    }else{
      showAlertDialog(
          title: label_permission_required.tr.toUpperLowerCase(),
          contentText: '${label_please_grant_the_permission.trParams({'field' :content.toLowerCase()})}${additionalContent ?? ''}',
          onOkPressed: () {
            openAppSettings().then((value)async{
              if(value){
                if(await isGranted){
                  permissionEnabledFunction();
                }
              }
            });
            Get.back();
          },
          cancelButtonContent :label_cancel.tr,
          okButtonContent: label_continue.tr);
    }
  }

}


EdgeInsetsGeometry pad({double start=0,double end=0,double top=0,double bottom=0,double? w,double? h,double? a}){
  return EdgeInsetsDirectional.only(start: a ?? w?? start,end:a ?? w?? end,top:a ?? h?? top,bottom: (a ?? h??bottom));
}

List<BoxShadow> getBoxShadow({Color? shadowColor }){
  return [
    BoxShadow(
      color: shadowColor ?? Colors.grey.withValues(alpha:0.1) ,
      spreadRadius:2,
      blurRadius: 3,
      offset: Offset(0, 1),
    ),
  ];
}

Widget toListView({
  Axis scrollDirection  = Axis.vertical,
  bool reverse = false,
  ScrollController? controller,
  bool primary = false,
  int? itemCount,
  required PageStorageKey? key,
  Widget? emptyWidget,
  bool isLoading = false,
  bool isShowShimmer =false,
  ScrollPhysics?  physics = const ClampingScrollPhysics(),
  bool shrinkWrap = false,
  EdgeInsetsGeometry? padding,
  required   NullableIndexedWidgetBuilder itemBuilder
}){
  return  itemCount!=null && itemCount >0 ?ListView.builder(
      itemCount: isLoading && isShowShimmer  ? 5 : itemCount,
      shrinkWrap: shrinkWrap,
      cacheExtent: 9999999,
      scrollDirection: scrollDirection,
      reverse: reverse,
      key: key,
      controller: controller,
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.manual,
      primary: primary,
      physics: physics,
      padding: padding,
      itemBuilder: itemBuilder).addScrollConfig() : emptyWidget ?? const SizedBox.shrink();
}

class _TopRoundedClipper extends CustomClipper<Path> {
  final double radius;
  _TopRoundedClipper({required this.radius});

  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, radius);
    path.quadraticBezierTo(0, 0, radius, 0);
    path.lineTo(size.width - radius, 0);
    path.quadraticBezierTo(size.width, 0, size.width, radius);
    path.lineTo(size.width, size.height + 200);
    path.lineTo(0, size.height + 200);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant _TopRoundedClipper oldClipper) => radius != oldClipper.radius;
}