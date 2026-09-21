import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:gozy/constant.dart';
import 'package:gozy/screens/views/base_controller.dart';


Widget showGoogleMap({required LatLng initialLatLng,Key? mapglobalkey,BuildContext? context, CameraPositionCallback? onCameraMove,  VoidCallback? onCameraIdle, GestureDragDownCallback? onDown,Set<Circle>? circles, MapCreatedCallback? onMapCreated,BaseController? controller, Set<Marker>? markers,EdgeInsets? padding,double? initialZoomLevel, bool? zoomControlsEnabled, double? borderRadius, bool? isTopOnly, bool? isBottomOnly}) {
  return ClipRRect(
    borderRadius: (isTopOnly ?? false) ? BorderRadiusDirectional.vertical(top: Radius.circular(borderRadius ?? 0),
    ) : (isBottomOnly ?? false) ? BorderRadiusDirectional.vertical(bottom: Radius.circular(borderRadius ?? 0),
    ) : BorderRadius.all(Radius.circular(borderRadius ?? 0),
    ),
    child: Transform.scale(
      scale: 1.005,
      child: hideGoogleMap ? const SizedBox.shrink() : GoogleMap(
        key:mapglobalkey,
        initialCameraPosition: CameraPosition(target: initialLatLng, zoom: initialZoomLevel ?? 12),
        myLocationEnabled: false,
        style: googleMapStyle,

        circles: circles ?? const <Circle>{},
        markers:  markers ?? <Marker>{},
        onCameraMove: onCameraMove,
        onCameraIdle: onCameraIdle,
        myLocationButtonEnabled: false,
        compassEnabled: false,
        mapToolbarEnabled: false,
        rotateGesturesEnabled: false,
        zoomControlsEnabled: zoomControlsEnabled ?? false,
        buildingsEnabled: false,
        padding: padding ?? EdgeInsets.zero,
        gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{}
          ..add(Factory<PanGestureRecognizer>(() => PanGestureRecognizer()..onUpdate = (_) {debugPrint("PanGestureRecognizer");}))
          ..add(Factory<ScaleGestureRecognizer>(() => ScaleGestureRecognizer()..onStart = (_) {debugPrint("PanGestureRecognizer");}))
          ..add(Factory<VerticalDragGestureRecognizer>(
                  () => VerticalDragGestureRecognizer()..onDown = onDown)),

        onMapCreated: onMapCreated,
        layoutDirection: TextDirection.ltr,
      ),
    ),
  );
}